import { test } from "node:test"
import assert from "node:assert/strict"
import { stabilizeReminders } from "../lib/stable-mode-reminders.ts"

const plan = "<system-reminder>\n# Plan Mode - System Reminder\n\nPlan instructions\n</system-reminder>"
const build = `<system-reminder>
Your operational mode has changed from plan to build.
You are no longer in read-only mode.
You are permitted to make file changes, run shell commands, and utilize your arsenal of tools as needed.
</system-reminder>`
function message(id = "msg_1", sessionID = "ses_1") {
  return { info: { role: "user", id, sessionID }, parts: [part("prompt", "Hello", false, id, sessionID)] }
}
function part(id: string, text: string, synthetic = true, messageID = "msg_1", sessionID = "ses_1") {
  return { id, text, synthetic, type: "text", messageID, sessionID }
}
function fixture() {
  const db = new Map<string, ReturnType<typeof part>[]>()
  const writes: ReturnType<typeof part>[] = []
  return {
    db, writes,
    store: {
      async read(s: string, m: string) { return structuredClone(db.get(`${s}/${m}`) ?? []) },
      async save(p: ReturnType<typeof part>) {
        writes.push(structuredClone(p))
        const key = `${p.sessionID}/${p.messageID}`
        db.set(key, [...(db.get(key) ?? []), structuredClone(p)])
      },
    },
  }
}

for (const [name, reminders] of Object.entries({ "plan to plan": [plan, plan], "plan to build": [plan, build], "build to build": [build, build] })) {
  test(`${name}: stable prefix, tool continuation and reload`, async () => {
    const f = fixture()
    const first = message()
    first.parts.push(part("reminder_1", reminders[0]))
    await stabilizeReminders([first], f.store)
    const original = structuredClone(first)
    const reloaded = message()
    reloaded.parts.push(...await f.store.read("ses_1", "msg_1"), part("duplicate", reminders[0]))
    await stabilizeReminders([reloaded], f.store)
    assert.deepEqual(reloaded, original)
    const second = message("msg_2")
    second.parts.push(part("reminder_2", reminders[1], true, "msg_2"))
    await stabilizeReminders([reloaded, second], f.store)
    assert.deepEqual(reloaded, original)
    assert.equal(f.writes.length, 2)
  })
}
test("upstream-persisted reminder is a no-op", async () => {
  const f = fixture(); const m = message(); m.parts.push(part("existing", plan))
  f.db.set("ses_1/msg_1", structuredClone(m.parts))
  const before = structuredClone(m)
  await stabilizeReminders([m], f.store)
  assert.deepEqual(m, before); assert.equal(f.writes.length, 0)
})
test("fork IDs, post-compaction history and unrelated synthetic/user text", async () => {
  const f = fixture(); const m = message("msg_fork", "ses_fork")
  m.parts.push(part("persist", build, true, "msg_fork", "ses_fork"))
  await stabilizeReminders([m], f.store)
  assert.equal(f.writes[0].sessionID, "ses_fork")
  const after = message("msg_after")
  after.parts.push(part("user_quote", plan, false), part("other", "<system-reminder>Other instructions</system-reminder>"))
  await stabilizeReminders([after], f.store)
  assert.equal(f.writes.length, 1)
})
test("persistence failure propagates without discarding reminder", async () => {
  const m = message(); m.parts.push(part("r", plan)); const before = structuredClone(m)
  await assert.rejects(stabilizeReminders([m], {
    async read() { return [] }, async save() { throw new Error("unavailable") },
  }), /unavailable/)
  assert.deepEqual(m, before)
})
test("overlapping stale snapshot reuses the persisted reminder instead of dropping it", async () => {
  const f = fixture(); const m = message(); m.parts.push(part("temporary", plan))
  f.db.set("ses_1/msg_1", [part("saved", plan)])
  await stabilizeReminders([m], f.store)
  assert.equal(m.parts[1].id, "saved")
  assert.equal(f.writes.length, 0)
})
