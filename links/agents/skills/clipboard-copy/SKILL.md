---
name: clipboard-copy
description: Copy exact text to the system clipboard reliably. Use when the user says "copy this to the clipboard", "put that on the clipboard", "copy it again", or otherwise asks to place text on the clipboard.
---

# Copy to Clipboard

Places exact, verbatim text on the system clipboard using `xclip`. Optimized for reliability:
the naive `cat <<'EOF' | xclip ...` heredoc/pipe approach has silently produced an empty
clipboard, so this skill uses a temp file plus a readback check.

## Method

1. Write the exact content to a temp file with the **write** tool (never shell echo/heredoc):
   `/tmp/opencode/clipboard.txt`. Writing via the tool avoids shell-quoting and heredoc pitfalls.
2. Load it into the clipboard:
   `xclip -selection clipboard -i /tmp/opencode/clipboard.txt`
3. Verify by reading it back and confirming it matches:
   `xclip -selection clipboard -o | head`

`/tmp/**` is pre-allowed via the `external_directory` permission, so the temp file won't prompt.

## Pitfalls (do not repeat)

- Do NOT chain heredocs with `||` (e.g. `cat <<'EOF' | xclip ... || cat <<'EOF' | wl-copy`);
  this has silently left the clipboard empty.
- Do NOT embed multi-line text directly in the bash command; write a temp file first, then feed
  the file to `xclip`.
- Always read the clipboard back to confirm before telling the user it's done.
