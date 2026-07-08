/**
 * Plan / Build modes
 *
 * Recreates the opencode two-agent workflow:
 *   - plan  (default): read-only exploration + planning. Write tools disabled,
 *            thinking level "xhigh". Mirrors opencode `default_agent: plan`,
 *            model github-copilot/claude-opus-4.8 @ variant xhigh.
 *   - build: full access (edit/write enabled), thinking level "medium".
 *            Mirrors opencode `build` agent.
 *
 * Both modes use the same model (github-copilot/claude-opus-4.8); only the tool
 * set, thinking level, and system-prompt guidance change — opencode's
 * claude-opus-4.8-fast alias does not exist in Pi's Copilot catalog.
 *
 * Commands:  /plan  /build  /mode
 * Shortcut:  Ctrl+Alt+P toggles between plan and build
 * Flag:      --build starts a session in build mode
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";

type Mode = "plan" | "build";

// Built-in write tools disabled in plan mode. Everything else (read, bash, grep,
// find, ls, and custom tools like question/todo/webfetch/subagent/mcp) stays on.
const WRITE_TOOLS = new Set<string>(["edit", "write"]);

const THINKING: Record<Mode, string> = { plan: "xhigh", build: "medium" };

const PLAN_GUIDANCE = `
<mode name="plan">
You are in PLAN mode. Focus on understanding and planning, not doing.

- Investigate the codebase, read files, run read-only shell commands, and reason
  about the problem.
- Do NOT modify files. The edit and write tools are disabled in this mode.
- Produce a clear, concrete plan: what you will change, where, and why, including
  tradeoffs and risks.
- When the user is ready to execute, they will switch to build mode (/build).
</mode>`.trim();

export default function modeExtension(pi: ExtensionAPI) {
  let mode: Mode = "plan";

  pi.registerFlag("build", {
    description: "Start the session in build mode (full read/write access)",
    type: "boolean",
    default: false,
  });

  function applyTools() {
    const all = pi.getAllTools().map((t) => t.name);
    if (mode === "plan") {
      pi.setActiveTools(all.filter((name) => !WRITE_TOOLS.has(name)));
    } else {
      pi.setActiveTools(all);
    }
  }

  function applyMode(ctx: ExtensionContext | undefined, notify: boolean) {
    applyTools();
    pi.setThinkingLevel(THINKING[mode]);
    if (ctx?.hasUI) {
      const color = mode === "plan" ? "warning" : "success";
      const icon = mode === "plan" ? "⏸" : "▶";
      ctx.ui.setStatus("mode", ctx.ui.theme.fg(color, `${icon} ${mode}`));
      if (notify) {
        ctx.ui.notify(
          mode === "plan"
            ? "Plan mode: read-only exploration (edit/write disabled), thinking xhigh."
            : "Build mode: full read/write access, thinking medium.",
          "info",
        );
      }
    }
  }

  function setMode(next: Mode, ctx: ExtensionContext) {
    mode = next;
    applyMode(ctx, true);
  }

  pi.registerCommand("plan", {
    description: "Switch to plan mode (read-only exploration + planning)",
    handler: async (_args, ctx) => setMode("plan", ctx),
  });

  pi.registerCommand("build", {
    description: "Switch to build mode (full read/write access)",
    handler: async (_args, ctx) => setMode("build", ctx),
  });

  pi.registerCommand("mode", {
    description: "Show the current mode (plan or build)",
    handler: async (_args, ctx) => {
      ctx.ui.notify(`Current mode: ${mode}`, "info");
    },
  });

  pi.registerShortcut(Key.ctrlAlt("p"), {
    description: "Toggle plan/build mode",
    handler: async (ctx) => setMode(mode === "plan" ? "build" : "plan", ctx),
  });

  // Establish the mode on every session start (default: plan, mirroring
  // opencode's default_agent). --build flips the initial mode to build.
  pi.on("session_start", async (_event, ctx) => {
    mode = pi.getFlag("build") ? "build" : "plan";
    applyMode(ctx, false);
  });

  // Inject planning guidance while in plan mode.
  pi.on("before_agent_start", async (event) => {
    if (mode !== "plan") return;
    return { systemPrompt: `${event.systemPrompt}\n\n${PLAN_GUIDANCE}` };
  });

  // Safety net: hard-block write tools if something re-enables them mid-plan.
  pi.on("tool_call", async (event) => {
    if (mode === "plan" && WRITE_TOOLS.has(event.toolName)) {
      return {
        block: true,
        reason: "Plan mode is read-only. Switch to build mode (/build) to modify files.",
      };
    }
    return undefined;
  });
}
