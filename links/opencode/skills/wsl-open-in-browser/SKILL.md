---
name: wsl-open-in-browser
description: Use when opening a URL/file in Ian's browser (WSL).
---

# Open things in Ian's browser (Edge) from WSL

"Open it in the browser" means Microsoft Edge, Ian's default browser.

```bash
tabopen "https://dev.azure.com/..."           # URL; reuses its open tab
wslview "/path/to/file.html"                  # local file, plain path only
```

`tabopen` switches to the Edge tab already showing a PR or work item and opens a new tab only
when there is none. Use `wslview` for URLs when `tabopen` isn't installed.

A local file with a fragment or query (`arm-path.html#goal-5`) must go straight to Edge as a
`file://` URL. Never hand it to `wslview`: `wslview` treats the whole string as a Windows path,
finds no such file and opens File Explorer instead.

```bash
edge="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
"$edge" "file:///$(wslpath -w /path/to/file.html | sed 's|\\|/|g')#goal-5"
```

When unsure whether a string is a plain path, use the Edge form; it always lands in the browser.

Open several URLs with one `tabopen` or `wslview` call each, in the foreground. `wslview`
returns immediately; `tabopen` takes a second or two to search the open tabs.

## Never

- **Never run `explorer.exe <url-or-file>`.** It spawns stray File Explorer
  processes and windows, which Ian finds very disruptive. If it happened anyway,
  kill only the new `explorer` PIDs (compare StartTime with the long-lived shell process).
  Never kill his original shell.
- Don't use `cmd.exe /c start` or PowerShell `Start-Process` as a substitute.
- Never build a URL by gluing `wslpath -w` output or `#fragment` onto a `wslview` argument.
- Don't background the call with `&` in the terminal tool; it isn't needed.
