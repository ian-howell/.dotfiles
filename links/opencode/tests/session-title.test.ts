import assert from "node:assert/strict"
import { setImmediate } from "node:timers/promises"
import test from "node:test"
import plugin from "../plugins/session-title/tui.ts"

async function harness({ title = "Understanding session titles and read-only agent permissions" } = {}) {
  let command: any
  let release!: () => void
  const gate = new Promise<void>((resolve) => { release = resolve })
  const calls: { method: string; input: any }[] = []
  const toasts: any[] = []
  const session = { id: "parent", title: "Original title" }
  const route: { current: any } = { current: { type: "session", sessionID: "parent" } }
  const aborted = (signal: AbortSignal) =>
    new Promise((_, reject) => {
      if (signal.aborted) return reject(signal.reason)
      signal.addEventListener("abort", () => reject(signal.reason), { once: true })
    })
  const client = {
    session: {
      get: async (input: any) => {
        calls.push({ method: "get", input })
        return { ...session }
      },
      generate: async (input: any, options: { signal: AbortSignal }) => {
        calls.push({ method: "generate", input })
        await Promise.race([gate, aborted(options.signal)])
        return { text: title }
      },
      update: async (input: any) => {
        calls.push({ method: "update", input })
        Object.assign(session, { title: input.title })
      },
    },
  }
  const context = {
    client,
    keymap: { layer: (factory: () => any) => { [command] = factory().commands } },
    ui: {
      router: { current: () => route.current },
      toast: { show: (toast: any) => toasts.push(toast) },
      dialog: { clear() {} },
    },
  }
  const dispose = await plugin.setup(context)
  async function until(predicate: () => boolean) {
    for (let i = 0; i < 100; i++) {
      if (predicate()) return
      await setImmediate()
    }
    assert.fail("Background work did not reach the expected state")
  }
  return { command, dispose, release, calls, toasts, session, route, until }
}

test("palette action retitles the session it started on", async () => {
  const h = await harness()
  assert.equal(h.command.palette, true)
  assert.equal(h.command.slash.name, "retitle")
  assert.equal(h.command.enabled(), true)
  assert.equal(h.command.run(), undefined, "Menu action should return immediately")
  await h.until(() => h.calls.some((c) => c.method === "generate"))
  h.command.run()
  assert.match(h.toasts.at(-1).message, /Already generating/)
  h.route.current = { type: "session", sessionID: "other" }
  h.release()
  await h.until(() => h.toasts.some((t) => t.variant === "success"))

  const generates = h.calls.filter((c) => c.method === "generate")
  assert.equal(generates.length, 1)
  assert.equal(generates[0].input.sessionID, "parent")
  assert.match(generates[0].input.prompt, /whole conversation/)
  assert.doesNotMatch(generates[0].input.prompt, /guidance/)
  assert.deepEqual(h.calls.filter((c) => c.method === "update").map((c) => c.input), [
    { sessionID: "parent", title: "Understanding session titles and read-only agent permissions" },
  ])
  await h.dispose()
})

test("slash arguments become title guidance", async () => {
  const h = await harness()
  h.command.run("  focus on the plugin port  ")
  h.release()
  await h.until(() => h.toasts.some((t) => t.variant === "success"))
  const generate = h.calls.find((c) => c.method === "generate")
  assert.match(generate!.input.prompt, /Title guidance from Ian: focus on the plugin port\n/)
  await h.dispose()
})

test("manual rename during generation is preserved", async () => {
  const h = await harness()
  h.command.run()
  await h.until(() => h.calls.some((c) => c.method === "generate"))
  h.session.title = "My manual title"
  h.release()
  await h.until(() => h.toasts.some((t) => t.message.includes("kept the newer title")))
  assert.equal(h.session.title, "My manual title")
  assert.ok(!h.calls.some((c) => c.method === "update"))
  await h.dispose()
})

test("invalid title produces an error without renaming", async (t) => {
  t.mock.method(console, "error", () => {})
  const h = await harness({ title: "First line\nSecond line" })
  h.command.run()
  h.release()
  await h.until(() => h.toasts.some((t) => t.variant === "error"))
  assert.equal(h.session.title, "Original title")
  assert.ok(!h.calls.some((c) => c.method === "update"))
  await h.dispose()
})

test("disposal aborts title generation and prevents a late rename", async () => {
  const h = await harness()
  h.command.run()
  await h.until(() => h.calls.some((c) => c.method === "generate"))
  await h.dispose()
  assert.ok(!h.calls.some((c) => c.method === "update"))
  assert.deepEqual(h.toasts.map((t) => t.variant), ["info"])
})

test("home screen has no retitle target", async () => {
  const h = await harness()
  h.route.current = { type: "home" }
  assert.equal(h.command.enabled(), false)
  h.command.run()
  assert.equal(h.calls.length, 0)
  await h.dispose()
})
