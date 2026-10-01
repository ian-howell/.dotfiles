type Part = {
  id: string
  sessionID: string
  messageID: string
  type: string
  text?: string
  synthetic?: boolean
}
type Message = { info: { role: string; id: string; sessionID: string }; parts: Part[] }
type Store = {
  read(sessionID: string, messageID: string): Promise<Part[]>
  save(part: Part): Promise<void>
}

const buildReminder = `<system-reminder>
Your operational mode has changed from plan to build.
You are no longer in read-only mode.
You are permitted to make file changes, run shell commands, and utilize your arsenal of tools as needed.
</system-reminder>`

function isReminder(part: Part) {
  if (part.type !== "text" || part.synthetic !== true) return false
  const text = part.text?.trim()
  return (
    text === buildReminder ||
    (text?.startsWith("<system-reminder>\n# Plan Mode - System Reminder\n") === true &&
      text.endsWith("</system-reminder>"))
  )
}

// Runs after core's transient injection, before serialization. Only save the
// latest message's recognized reminders; never backfill or rewrite old turns.
export async function stabilizeReminders(messages: Message[], store: Store) {
  const message = messages.findLast((item) => item.info.role === "user")
  if (!message || !message.parts.some(isReminder)) return
  const saved = await store.read(message.info.sessionID, message.info.id)
  const remove = new Set<string>()
  for (const part of message.parts.filter(isReminder)) {
    if (saved.some((item) => item.id === part.id)) continue
    const existing = saved.find((item) => isReminder(item) && item.text === part.text)
    if (existing) {
      if (message.parts.some((item) => item.id === existing.id)) remove.add(part.id)
      else message.parts[message.parts.indexOf(part)] = existing
      continue
    }
    await store.save(part)
    saved.push(part)
  }
  message.parts = message.parts.filter((part) => !remove.has(part.id))
}
