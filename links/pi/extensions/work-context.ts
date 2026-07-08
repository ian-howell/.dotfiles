import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Injects the work-specific AGENTS.md into the system prompt, mirroring how the
 * opencode config pulled it in via its `instructions` array.
 *
 * Source of truth stays unmanaged at ~/.config/work/opencode/AGENTS.md so this
 * dotfiles-managed extension carries no work-specific content. If the file is
 * absent (e.g. a personal machine), the extension is a no-op.
 */
const WORK_AGENTS_PATH = join(homedir(), ".config", "work", "opencode", "AGENTS.md");

function loadWorkContext(): string | null {
  try {
    const text = readFileSync(WORK_AGENTS_PATH, "utf8").trim();
    return text.length > 0 ? text : null;
  } catch {
    return null;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event) => {
    // Re-read each turn so edits to the work AGENTS.md take effect without a restart.
    const work = loadWorkContext();
    if (!work) return;
    return {
      systemPrompt: `${event.systemPrompt}\n\n<work-agents-md source="${WORK_AGENTS_PATH}">\n${work}\n</work-agents-md>`,
    };
  });
}
