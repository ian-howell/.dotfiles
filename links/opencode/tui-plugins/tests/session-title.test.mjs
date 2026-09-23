import assert from "node:assert/strict"
import { setImmediate } from "node:timers/promises"
import test from "node:test"
import { createOpencodeClient } from "@opencode-ai/sdk/v2"
import plugin from "../session-title.mjs"

async function harness({ title = "Understanding session titles and read-only agent permissions" } = {}) {
  let command, dispose, release
  const gate = new Promise((resolve) => { release = resolve })
  const requests = []
  const toasts = []
  const parent = { id: "parent", title: "Original title" }
  const model = { providerID: "test", modelID: "test-model" }
  const messages = [
    { info: { role: "user", model }, parts: [{ type: "text", text: "Explain session permissions" }] },
    { info: { role: "assistant", summary: true }, parts: [
      { type: "text", text: "Earlier work: session titles" },
      { type: "reasoning", text: "private reasoning" },
      { type: "tool", text: "tool log" },
      { type: "text", text: "ignored text", ignored: true },
    ] },
  ]
  const client = createOpencodeClient({
    baseUrl: "http://test.invalid",
    fetch: async (request) => {
      const url = new URL(request.url)
      const text = await request.text()
      const body = text ? JSON.parse(text) : undefined
      requests.push({ method: request.method, path: url.pathname, directory: url.searchParams.get("directory"), body })
      const route = `${request.method} ${url.pathname}`
      let data
      switch (route) {
        case "GET /session/parent": data = { ...parent }; break
        case "GET /session/parent/message": data = messages; break
        case "POST /session": data = { id: "child" }; break
        case "POST /session/child/message":
          await Promise.race([
            gate,
            new Promise((_, reject) => {
              if (request.signal.aborted) return reject(request.signal.reason)
              request.signal.addEventListener("abort", () => reject(request.signal.reason), { once: true })
            }),
          ])
          data = { info: {}, parts: [{ type: "text", text: title }] }
          break
        case "PATCH /session/parent": Object.assign(parent, body); data = { ...parent }; break
        case "POST /session/child/abort": data = true; break
        default: throw new Error(`Unexpected request: ${route}`)
      }
      return Response.json(data)
    },
  })
  const api = {
    client,
    keymap: { registerLayer: (layer) => { [command] = layer.commands } },
    route: { current: { name: "session", params: { sessionID: "parent" } } },
    state: { path: { directory: "/test/project" } },
    ui: { toast: (toast) => toasts.push(toast), dialog: { clear() {} } },
    lifecycle: { onDispose: (callback) => { dispose = callback } },
  }
  await plugin.tui(api)
  async function until(predicate) {
    for (let i = 0; i < 100; i++) {
      if (predicate()) return
      await setImmediate()
    }
    assert.fail("Background work did not reach the expected state")
  }
  return { api, command, dispose, release, requests, toasts, parent, model, until }
}

test("palette action runs independently of the primary agent and keeps its original target", async () => {
  const h = await harness()
  assert.equal(h.command.namespace, "palette")
  assert.equal(h.command.enabled(), true)
  assert.equal(h.command.run(), undefined, "Menu action should return immediately")
  await h.until(() => h.requests.some((r) => r.path === "/session/child/message"))
  h.command.run()
  assert.match(h.toasts.at(-1).message, /Already generating/)
  h.api.route.current = { name: "session", params: { sessionID: "other" } }
  h.release()
  await h.until(() => h.toasts.some((t) => t.variant === "success"))

  const prompts = h.requests.filter((r) => r.method === "POST" && r.path.endsWith("/message"))
  assert.equal(prompts.length, 1)
  assert.equal(prompts[0].path, "/session/child/message", "Never prompt the read-only primary agent")
  assert.equal(prompts[0].body.agent, "session-titler")
  assert.deepEqual(prompts[0].body.model, h.model)
  assert.deepEqual(JSON.parse(prompts[0].body.parts[0].text).conversation, [
    { role: "user", summary: false, text: "Explain session permissions" },
    { role: "assistant", summary: true, text: "Earlier work: session titles" },
  ])
  assert.equal(h.requests.filter((r) => r.method === "PATCH").length, 1)
  assert.ok(h.requests.every((r) => r.directory === "/test/project"))
  assert.notEqual(h.parent.title, "Original title")
  await h.dispose()
})

test("manual rename during generation is preserved", async () => {
  const h = await harness()
  h.command.run()
  await h.until(() => h.requests.some((r) => r.path === "/session/child/message"))
  h.parent.title = "My manual title"
  h.release()
  await h.until(() => h.toasts.some((t) => t.message.includes("kept the newer title")))
  assert.equal(h.parent.title, "My manual title")
  assert.ok(!h.requests.some((r) => r.method === "PATCH"))
  await h.dispose()
})

test("invalid title produces an error without renaming", async (t) => {
  t.mock.method(console, "error", () => {})
  const h = await harness({ title: "First line\nSecond line" })
  h.command.run()
  h.release()
  await h.until(() => h.toasts.some((t) => t.variant === "error"))
  assert.equal(h.parent.title, "Original title")
  assert.ok(!h.requests.some((r) => r.method === "PATCH"))
  assert.ok(h.requests.some((r) => r.path === "/session/child/abort"))
  await h.dispose()
})

test("disposal aborts title generation and prevents a late rename", async () => {
  const h = await harness()
  h.command.run()
  await h.until(() => h.requests.some((r) => r.path === "/session/child/message"))
  await h.dispose()
  assert.ok(h.requests.some((r) => r.path === "/session/child/abort"))
  assert.ok(!h.requests.some((r) => r.method === "PATCH"))
  assert.deepEqual(h.toasts.map((t) => t.variant), ["info"])
})

test("home screen has no retitle target", async () => {
  const h = await harness()
  h.api.route.current = { name: "home" }
  assert.equal(h.command.enabled(), false)
  h.command.run()
  assert.equal(h.requests.length, 0)
  await h.dispose()
})
