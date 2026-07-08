/**
 * Permission Gate
 *
 * Mirrors the opencode permission config:
 *   permission.bash: { "ssh": "ask", "az": "ask" }
 *   permission.external_directory: { "/tmp/**": "allow" }
 *
 * Pi has no built-in permission popups (everything runs by default), so this
 * re-adds "ask" gates for `ssh` and `az` invocations. Writes to /tmp are
 * implicitly allowed (Pi never blocks them), matching the external_directory rule.
 *
 * In non-interactive mode (no UI) the gated commands are blocked, since there is
 * no way to confirm.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Match `ssh`/`az` as the invoked program: at command start or after a
// shell separator (`;`, `&&`, `||`, `|`, newline, or command substitution).
const ASK_PROGRAMS: Array<{ name: string; re: RegExp }> = [
  { name: "ssh", re: /(^|[\n;&|(`]|&&|\|\|)\s*ssh\b/ },
  { name: "az", re: /(^|[\n;&|(`]|&&|\|\|)\s*az\b/ },
];

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command = String(event.input.command ?? "");
    const matched = ASK_PROGRAMS.find((p) => p.re.test(command));
    if (!matched) return undefined;

    if (!ctx.hasUI) {
      return {
        block: true,
        reason: `'${matched.name}' requires confirmation but no UI is available (non-interactive mode).`,
      };
    }

    const choice = await ctx.ui.select(
      `⚠️ This command runs \`${matched.name}\`:\n\n  ${command}\n\nAllow?`,
      ["Yes", "No"],
    );

    if (choice !== "Yes") {
      return { block: true, reason: `Blocked by user (${matched.name} gate)` };
    }

    return undefined;
  });
}
