import type { Plugin } from "@opencode-ai/plugin"
import { stabilizeReminders } from "../lib/stable-mode-reminders.ts"

// OpenCode 1.18.34's legacy plugin client has no part.update method. Reuse its
// transport so embedded `opencode run`, server auth, and routing all still work.
type Transport = {
  patch(options: {
    url: string
    query: { directory: string }
    body: unknown
    headers: Record<string, string>
    throwOnError: true
  }): Promise<unknown>
}

export const StableModeRemindersPlugin: Plugin = async ({ client, directory }) => {
  const transport = (client as unknown as { _client: Transport })._client
  // Serialize overlapping transforms; reload/fork state comes from storage,
  // rather than a process-local cache of reminders.
  let pending = Promise.resolve()
  return {
    "experimental.chat.messages.transform": async (_, output) => {
      const next = pending.then(() =>
        stabilizeReminders(output.messages, {
          async read(sessionID, messageID) {
            const result = await client.session.message({
              path: { id: sessionID, messageID },
              query: { directory },
              throwOnError: true,
            })
            if (!result.data) throw new Error("stable-mode-reminders: message lookup returned no data")
            return result.data.parts
          },
          async save(part) {
            if (!transport?.patch) throw new Error("stable-mode-reminders: SDK transport changed")
            await transport.patch({
              url: `/session/${encodeURIComponent(part.sessionID)}/message/${encodeURIComponent(part.messageID)}/part/${encodeURIComponent(part.id)}`,
              query: { directory },
              body: part,
              headers: { "Content-Type": "application/json" },
              throwOnError: true,
            })
          },
        }),
      )
      pending = next.catch(() => {}) // Keep the queue usable; the caller still receives the error.
      await next
    },
  }
}
