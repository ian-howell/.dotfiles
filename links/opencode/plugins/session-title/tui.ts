// Regenerates a session's title from its whole conversation, including earlier work and
// compaction summaries. The built-in /rename regeneration only sees the first message and the
// most recent turns. session.generate reads the session's full context without adding to its
// history or running the agent.
// A plain object, because OpenCode does not resolve @opencode/plugin for local plugin files.

const instructions = `Write a title for this whole conversation. Don't continue the work, use tools, or answer any earlier request.

Consider the entire conversation, including earlier work and compaction summaries. Capture the overall goals and major workstreams, including substantial completed and ongoing work. Group related activities under a meaningful shared theme; when there are distinct topics, reflect the main topics in a compact phrase. Don't overweight the most recent exchange or make this request itself the topic.

Aim for 6-12 words and at most 120 characters. Use recognizable project or component names and specific, plain language. Avoid generic labels, a task-by-task inventory, transient debugging details, status claims, and secrets.

Return ONLY the title on one line, with no quotes, Markdown, or explanation.`

type Job = { controller: AbortController; work?: Promise<void> }

export default {
  id: "session-title",
  setup(context: any) {
    const pending = new Map<string, Job>()
    let disposed = false

    function notify(message: string, variant: string) {
      if (disposed) return
      // Notification failures must not turn a successful rename into a failure.
      try {
        context.ui.toast.show({ title: "Regenerate session title", message, variant })
      } catch (error) {
        console.error("Retitle notification failed", error)
      }
    }

    async function retitle(sessionID: string, guidance: string, signal: AbortSignal) {
      const options = { signal: AbortSignal.any([signal, AbortSignal.timeout(180_000)]) }
      try {
        const before = await context.client.session.get({ sessionID }, options)
        const prompt = guidance
          ? `${instructions}\n\nTitle guidance from Ian: ${guidance}\nHonor it without inventing details absent from the conversation.`
          : instructions
        const { text } = await context.client.session.generate({ sessionID, prompt }, options)
        const title = text.trim()
        if (!title || title.length > 120 || /[\r\n]/.test(title)) {
          throw new Error("The model did not return a valid single-line title")
        }
        const current = await context.client.session.get({ sessionID }, options)
        // Preserve a manual rename made while the title was being generated.
        if (current.title !== before.title) {
          notify("Title changed while generating; kept the newer title.", "info")
          return
        }
        options.signal.throwIfAborted()
        await context.client.session.update({ sessionID, title }, options)
        notify(title, "success")
      } catch (error) {
        if (disposed) return
        console.error("Background retitle failed", sessionID, error)
        notify(`Could not regenerate title: ${error instanceof Error ? error.message : String(error)}`, "error")
      } finally {
        pending.delete(sessionID)
      }
    }

    context.keymap.layer(() => ({
      // Reachable from the palette and prompt, not only the base input mode.
      mode: "global",
      commands: [{
        id: "session.regenerate-title",
        title: "Regenerate session title",
        group: "Session",
        palette: true,
        slash: { name: "retitle", arguments: true },
        enabled: () => context.ui.router.current().type === "session",
        run(input?: string) {
          const route = context.ui.router.current()
          if (disposed || route.type !== "session") return
          context.ui.dialog.clear()
          // Capture the target before the user navigates to another session.
          const sessionID = route.sessionID
          if (pending.has(sessionID)) {
            notify("Already generating a title for this session.", "info")
            return
          }
          const job: Job = { controller: new AbortController() }
          pending.set(sessionID, job)
          notify("Retitling in background.", "info")
          job.work = retitle(sessionID, input?.trim() ?? "", job.controller.signal)
        },
      }],
    }))

    return async () => {
      disposed = true
      const jobs = [...pending.values()]
      for (const job of jobs) job.controller.abort()
      await Promise.all(jobs.map((job) => job.work))
    }
  },
}
