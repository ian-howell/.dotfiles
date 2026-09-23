import { type Plugin, tool } from "@opencode-ai/plugin"

type Job = { sessionID: string; messageID: string; directory: string; guidance: string }

export const SessionTitlePlugin = (async ({ client }) => {
  const latest = new Map<string, Job>()
  const pending = new Map<string, Promise<void>>()

  async function notify(job: Job, message: string, variant: "success" | "error") {
    // Notifications must never turn a successful rename into a reported failure.
    try {
      await client.tui.showToast({
        query: { directory: job.directory },
        body: { title: "Background retitle", message, variant },
        throwOnError: true,
        signal: AbortSignal.timeout(5_000),
      })
    } catch (error) {
      console.error("Background retitle notification failed", error)
    }
  }

  async function run(job: Job) {
    if (latest.get(job.sessionID) !== job) return
    const query = { directory: job.directory }
    const path = { id: job.sessionID }
    // Independent of the invoking turn: finishing that turn must not cancel us.
    const signal = AbortSignal.timeout(180_000)
    let childID: string | undefined
    try {
      const [session, history] = await Promise.all([
        client.session.get({ path, query, signal, throwOnError: true }),
        client.session.messages({ path, query, signal, throwOnError: true }),
      ])
      if (!session.data || !history.data) throw new Error("Could not capture the session")
      // Freeze the snapshot at the invoking message, even if the queue starts later.
      const end = history.data.findIndex(({ info }) => info.id === job.messageID)
      if (end < 0) throw new Error("Invoking message is missing from the conversation")
      const messages = history.data.slice(0, end + 1)
      const model = messages.findLast(({ info }) => info.role === "user")?.info
      const conversation = messages.flatMap(({ info, parts }) => {
        const text = parts
          .filter((part) => part.type === "text" && !part.ignored)
          .map((part) => part.type === "text" ? part.text : "")
          .join("\n")
        return text.trim() ? [{ role: info.role, summary: info.role === "assistant" && info.summary, text }] : []
      })
      if (!conversation.length) throw new Error("No conversation text is available")
      // Bound input while retaining coverage of early AND recent topics. Tool logs
      // and reasoning are excluded; compaction summaries remain ordinary text.
      const budget = Math.max(2, Math.floor(120_000 / conversation.length))
      const snapshot = conversation.map((message) => ({
        ...message,
        text: message.text.length <= budget ? message.text :
          `${message.text.slice(0, Math.floor(budget / 2))}\n[excerpt omitted]\n${message.text.slice(-Math.ceil(budget / 2))}`,
      }))
      if (latest.get(job.sessionID) !== job) return
      const child = await client.session.create({
        query, signal, throwOnError: true,
        body: { parentID: job.sessionID, title: "Background session retitle" },
      })
      if (!child.data?.id) throw new Error("Could not create the title agent session")
      childID = child.data.id
      const response = await client.session.prompt({
        path: { id: childID }, query, signal, throwOnError: true,
        body: {
          agent: "session-titler",
          ...(model?.role === "user" ? { model: model.model } : {}),
          parts: [{ type: "text", text: JSON.stringify({ guidance: job.guidance, conversation: snapshot }) }],
        },
      })
      if (response.data?.info.error) throw new Error(JSON.stringify(response.data.info.error))
      const title = response.data?.parts
        .filter((part) => part.type === "text")
        .map((part) => part.type === "text" ? part.text : "")
        .join("\n").trim()
      if (!title || title.length > 120 || /[\r\n]/.test(title)) {
        throw new Error("Title agent did not return a valid single-line title")
      }
      if (latest.get(job.sessionID) !== job) return
      const current = await client.session.get({ path, query, signal, throwOnError: true })
      if (latest.get(job.sessionID) !== job) return
      // Preserve a manual rename made while the title agent was working.
      if (current.data?.title !== session.data.title) return
      const result = await client.session.update({ path, query, signal, body: { title }, throwOnError: true })
      if (result.data?.id !== job.sessionID || result.data.title !== title) {
        throw new Error("OpenCode did not confirm the requested session title")
      }
      if (latest.get(job.sessionID) === job) await notify(job, title, "success")
    } catch (error) {
      if (childID) {
        try {
          await client.session.abort({
            path: { id: childID }, query, throwOnError: true, signal: AbortSignal.timeout(5_000),
          })
        } catch (abortError) {
          console.error("Could not stop title agent", abortError)
        }
      }
      console.error("Background retitle failed", job.sessionID, error)
      if (latest.get(job.sessionID) === job) {
        await notify(job, "Could not confirm the rename. See the OpenCode log for details.", "error")
      }
    }
  }

  return {
    tool: {
      session_title: tool({
        description: "Queue a background agent to rename the current session from its whole conversation. Use only when requested, including /retitle. Returns immediately after queueing.",
        args: {
          guidance: tool.schema.string().optional().describe("Optional user guidance for the title"),
        },
        async execute(args, context) {
          const job: Job = {
            sessionID: context.sessionID, messageID: context.messageID,
            directory: context.directory, guidance: args.guidance ?? "",
          }
          latest.set(job.sessionID, job)
          // Serialize per parent, including writes, so an older in-flight update
          // cannot land after a newer result. Superseded queued jobs are skipped.
          const work = (pending.get(job.sessionID) ?? Promise.resolve()).then(() => run(job))
          pending.set(job.sessionID, work)
          void work.finally(() => {
            if (pending.get(job.sessionID) === work) pending.delete(job.sessionID)
            if (latest.get(job.sessionID) === job) latest.delete(job.sessionID)
          }).catch((error) => console.error("Background retitle worker failed", error))
          return {
            title: "Retitling in background",
            output: JSON.stringify({ queued: true, sessionID: job.sessionID }),
          }
        },
      }),
    },
  }
}) satisfies Plugin
