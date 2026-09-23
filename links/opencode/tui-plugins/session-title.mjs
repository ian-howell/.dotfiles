// A user-invoked UI action: the selected agent never receives a retitle prompt.
export default {
  id: "session-title",
  async tui(api) {
    const pending = new Map()
    let disposed = false

    function notify(message, variant) {
      if (disposed) return
      // Notification failures must not turn a successful rename into a failure.
      try {
        api.ui.toast({ title: "Regenerate session title", message, variant })
      } catch (error) {
        console.error("Retitle notification failed", error)
      }
    }

    async function run(job) {
      const { sessionID, directory } = job
      const target = { sessionID, directory }
      const options = {
        throwOnError: true,
        signal: AbortSignal.any([job.controller.signal, AbortSignal.timeout(180_000)]),
      }
      let childID
      try {
        const [session, history] = await Promise.all([
          api.client.session.get(target, options),
          api.client.session.messages(target, options),
        ])
        if (!session.data || !history.data) throw new Error("Could not capture the session")
        const model = history.data.findLast(({ info }) => info.role === "user")?.info.model
        const conversation = history.data.flatMap(({ info, parts }) => {
          const text = parts
            .filter((part) => part.type === "text" && !part.ignored)
            .map((part) => part.text)
            .join("\n")
          return text.trim() ? [{ role: info.role, summary: info.role === "assistant" && info.summary, text }] : []
        })
        if (!conversation.length) throw new Error("No conversation text is available")
        // Retain early and recent topics, including compaction summaries, without
        // passing tool logs or reasoning to the title agent.
        const budget = Math.max(2, Math.floor(120_000 / conversation.length))
        const snapshot = conversation.map((message) => ({
          ...message,
          text: message.text.length <= budget ? message.text :
            `${message.text.slice(0, Math.floor(budget / 2))}\n[excerpt omitted]\n${message.text.slice(-Math.ceil(budget / 2))}`,
        }))
        options.signal.throwIfAborted()
        const child = await api.client.session.create({
          directory, parentID: sessionID, title: "Background session retitle",
        }, options)
        if (!child.data?.id) throw new Error("Could not create the title agent session")
        childID = child.data.id
        const response = await api.client.session.prompt({
          sessionID: childID, directory, agent: "session-titler",
          ...(model ? { model } : {}),
          parts: [{ type: "text", text: JSON.stringify({ conversation: snapshot }) }],
        }, options)
        if (response.data?.info.error) throw new Error(JSON.stringify(response.data.info.error))
        const title = response.data?.parts
          .filter((part) => part.type === "text")
          .map((part) => part.text)
          .join("\n").trim()
        if (!title || title.length > 120 || /[\r\n]/.test(title)) {
          throw new Error("Title agent did not return a valid single-line title")
        }
        const current = await api.client.session.get(target, options)
        // Preserve a manual rename made while the title agent was working.
        if (current.data?.title !== session.data.title) {
          notify("Title changed while generating; kept the newer title.", "info")
          return
        }
        options.signal.throwIfAborted()
        const result = await api.client.session.update({ ...target, title }, options)
        if (result.data?.id !== sessionID || result.data.title !== title) {
          throw new Error("OpenCode did not confirm the requested session title")
        }
        notify(title, "success")
      } catch (error) {
        if (childID) {
          try {
            await api.client.session.abort({ sessionID: childID, directory }, {
              throwOnError: true, signal: AbortSignal.timeout(5_000),
            })
          } catch (abortError) {
            console.error("Could not stop title agent", abortError)
          }
        }
        if (!disposed) {
          console.error("Background retitle failed", sessionID, error)
          notify(`Could not regenerate title: ${error instanceof Error ? error.message : String(error)}`, "error")
        }
      } finally {
        pending.delete(sessionID)
      }
    }

    api.keymap.registerLayer({
      commands: [{
        name: "session.regenerate-title",
        title: "Regenerate session title",
        category: "Session",
        namespace: "palette",
        enabled: () => api.route.current.name === "session",
        run() {
          const route = api.route.current
          if (disposed || route.name !== "session" || !route.params?.sessionID) return
          api.ui.dialog.clear()
          const sessionID = route.params.sessionID
          if (pending.has(sessionID)) {
            notify("Already generating a title for this session.", "info")
            return
          }
          // Capture the target before the user navigates to another session.
          const job = {
            sessionID, directory: api.state.path.directory, controller: new AbortController(),
          }
          pending.set(sessionID, job)
          notify("Retitling in background.", "info")
          job.work = run(job)
        },
      }],
    })

    api.lifecycle.onDispose(async () => {
      disposed = true
      const jobs = [...pending.values()]
      for (const job of jobs) job.controller.abort()
      await Promise.all(jobs.map((job) => job.work))
    })
  },
}
