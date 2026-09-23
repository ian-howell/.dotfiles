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

## Base configuration and work overlay

This repository is the complete, general-purpose, open source base configuration.
`~/.config/work` is a separate repository containing only work-specific additions
layered on top. Choose ownership by what a feature does, not where it was developed,
which session requested it, or the current value of an environment variable.

- General OpenCode plugins, agents, commands, skills, and themes belong in
  `links/opencode`, linked to `~/.config/opencode`. Tmux integration, retitling,
  explanation agents, theme switching, and general Git policy are base features.
- Only work-specific OpenCode additions belong in `~/.config/work/opencode`, loaded
  through `OPENCODE_CONFIG_DIR`. It augments the base; it is not a generic install target.
- Base installers must not copy shared features into or edit the work overlay.
  Do not manage work paths through `linkdotfiles.yaml` or require the work repo for
  the base configuration to function.
- Split mixed features into shared base functionality and distinct work extensions;
  do not duplicate or shadow the base skill/plugin under the same name.
- Azure/lab/simdev tooling, ADO work-item policy, Teams/work TODO integration, and
  `repo-catalog` are intentionally work-owned. Keep work inventory and private data there.
- When a change spans the repositories, identify both scopes before editing and
  preserve unrelated changes in each. Commit/push authorization remains separate
  from implementation authorization.

The primary Neovim configuration lives in the "links/nvim" directory and uses Neovim's built-in
package manager.

Neovim module loading: use `require("module")` directly for both plugins and local modules. Do not
silence or wrap errors from `require` calls; missing modules should fail loudly.

When adding scripts to `links/bin`, ensure they are executable (e.g., `chmod +x`).

When a `links/bin` script needs sibling data or config files, put the script and its
companions in a `links/bin/<name>.d/` directory. Related commands that share helpers
may instead use a tool-family directory, such as `links/bin/pickers/`. Expose entry
points through relative symlinks in `links/bin`; keep libraries, preview helpers,
config, and tests inside the bundle, off PATH. Scripts should locate their own
directory via `readlink -f "${BASH_SOURCE[0]}"` so companions resolve through symlinks.
See `links/bin/theme.d/` and `links/bin/pickers/` for examples.

Forward slashes (/) are valid in tmux session names. Do not suggest that they aren't.
