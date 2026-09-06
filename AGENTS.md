AGENTS.md is a living document. When you notice a real gap or an out-of-date rule while working,
suggest an improvement, including structural changes to the document itself. Do not editorialize
about the document on every task.

For command-heavy or long-running work, agents may create a uniquely named session directory under
`/tmp/opencode/evidence/` and store command output, logs, downloaded metadata, and intermediate
analysis there. When doing so, tell the user that an evidence directory was created and provide its
path. In the final response, mention that the evidence exists, identify the relevant files, and
summarize key findings. Treat evidence as temporary, keep secrets out where possible, restrict
permissions for sensitive output, and never commit it.

The files in the "links" directory are symlinked to files according to the content of the
"linkdotfiles.yaml" file in the root of this repository.

Work-related OpenCode configs (including custom commands/agents) should live under
"~/.config/work/opencode" and be referenced via the OPENCODE_CONFIG_DIR environment variable.
Do not manage those paths via linkdotfiles.yaml.

The primary Neovim configuration lives in the "links/nvim" directory and uses Neovim's built-in
package manager.

Neovim module loading: use `require("module")` directly for both plugins and local modules. Do not
silence or wrap errors from `require` calls; missing modules should fail loudly.

When adding scripts to `links/bin`, ensure they are executable (e.g., `chmod +x`).

When a `links/bin` script needs sibling data or config files, put the script and its
companions in a `links/bin/<name>.d/` directory and add a relative symlink at
`links/bin/<name>` pointing to `<name>.d/<name>`. The script should locate its own directory
via `readlink -f "${BASH_SOURCE[0]}"` so it finds its companions regardless of how it was
invoked. See `links/bin/rp` / `links/bin/rp.d/` for the reference implementation.

Forward slashes (/) are valid in tmux session names. Do not suggest that they aren't.
