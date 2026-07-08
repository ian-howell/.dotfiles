/**
 * webfetch — keyless URL fetch tool (no API key required)
 *
 * Mirrors opencode's `webfetch`: fetch a URL and return its content as
 * markdown (default), text, or raw html. HTML is converted to markdown with a
 * compact, dependency-free converter so the extension works on a fresh machine
 * with no `npm install` step.
 *
 * Large responses are truncated for the model and the full body is written to a
 * temp file (path included in the result), matching Pi's built-in output guard.
 */

import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

const MAX_INLINE_BYTES = 50_000;
const REQUEST_TIMEOUT_MS = 30_000;

const WebfetchParams = Type.Object({
  url: Type.String({ description: "The URL to fetch (http/https)" }),
  format: Type.Optional(
    StringEnum(["markdown", "text", "html"] as const, {
      description: "Output format (default: markdown)",
    }),
  ),
});

interface WebfetchDetails {
  url: string;
  format: string;
  status?: number;
  contentType?: string;
  bytes?: number;
  truncated?: boolean;
  fullPath?: string;
  error?: string;
}

function stripTag(html: string, tag: string): string {
  return html.replace(new RegExp(`<${tag}[\\s\\S]*?</${tag}>`, "gi"), "");
}

function decodeEntities(s: string): string {
  return s
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&#(\d+);/g, (_m, n) => String.fromCodePoint(Number(n)))
    .replace(/&#x([0-9a-f]+);/gi, (_m, n) => String.fromCodePoint(Number.parseInt(n, 16)));
}

/** Compact HTML -> Markdown conversion. Not perfect, but good for agent reading. */
function htmlToMarkdown(html: string): string {
  let s = html;
  s = stripTag(s, "script");
  s = stripTag(s, "style");
  s = stripTag(s, "head");
  s = stripTag(s, "noscript");
  s = s.replace(/<!--[\s\S]*?-->/g, "");

  // Block-ish → newlines
  s = s.replace(/<\/(p|div|section|article|header|footer|ul|ol|table|tr)>/gi, "\n\n");
  s = s.replace(/<br\s*\/?>/gi, "\n");
  s = s.replace(/<hr\s*\/?>/gi, "\n---\n");

  // Headings
  for (let i = 1; i <= 6; i++) {
    s = s.replace(new RegExp(`<h${i}[^>]*>([\\s\\S]*?)</h${i}>`, "gi"), (_m, t) => `\n\n${"#".repeat(i)} ${t.trim()}\n\n`);
  }

  // Inline emphasis / code
  s = s.replace(/<(strong|b)[^>]*>([\s\S]*?)<\/\1>/gi, (_m, _t, t) => `**${t.trim()}**`);
  s = s.replace(/<(em|i)[^>]*>([\s\S]*?)<\/\1>/gi, (_m, _t, t) => `*${t.trim()}*`);
  s = s.replace(/<code[^>]*>([\s\S]*?)<\/code>/gi, (_m, t) => `\`${t.trim()}\``);

  // Links
  s = s.replace(/<a[^>]*href=["']([^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi, (_m, href, t) => {
    const text = t.replace(/<[^>]+>/g, "").trim();
    return text ? `[${text}](${href})` : href;
  });

  // List items
  s = s.replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_m, t) => `- ${t.replace(/<[^>]+>/g, "").trim()}\n`);

  // Drop remaining tags
  s = s.replace(/<[^>]+>/g, "");
  s = decodeEntities(s);

  // Collapse excess whitespace
  s = s.replace(/[ \t]+\n/g, "\n").replace(/\n{3,}/g, "\n\n");
  return s.trim();
}

function htmlToText(html: string): string {
  let s = stripTag(stripTag(html, "script"), "style");
  s = s.replace(/<[^>]+>/g, " ");
  s = decodeEntities(s);
  return s.replace(/[ \t]+/g, " ").replace(/\n{3,}/g, "\n\n").trim();
}

export default function webfetchExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "webfetch",
    label: "WebFetch",
    description:
      "Fetch a URL and return its content as markdown (default), text, or html. No API key required. Use to read web pages, docs, and raw files.",
    parameters: WebfetchParams,

    async execute(_id, params, signal, _onUpdate, _ctx) {
      const format = params.format ?? "markdown";
      const url = params.url.trim();

      if (!/^https?:\/\//i.test(url)) {
        return {
          content: [{ type: "text", text: `Error: URL must start with http:// or https:// (got: ${url})` }],
          details: { url, format, error: "invalid url" } as WebfetchDetails,
        };
      }

      const timeout = new AbortController();
      const timer = setTimeout(() => timeout.abort(), REQUEST_TIMEOUT_MS);
      // Abort if either the tool signal or our timeout fires.
      const onAbort = () => timeout.abort();
      signal?.addEventListener("abort", onAbort);

      try {
        const res = await fetch(url, {
          redirect: "follow",
          signal: timeout.signal,
          headers: {
            "User-Agent": "pi-webfetch/1.0 (+https://pi.dev)",
            Accept: "text/html,application/xhtml+xml,text/plain,application/json;q=0.9,*/*;q=0.8",
          },
        });

        const contentType = res.headers.get("content-type") ?? "";
        const raw = await res.text();

        let body: string;
        const isHtml = /html/i.test(contentType) || /^\s*<(?:!doctype|html)/i.test(raw);
        if (format === "html" || !isHtml) {
          // Non-HTML (JSON, plain text, raw files) is returned as-is regardless of format.
          body = format === "text" && isHtml ? htmlToText(raw) : raw;
        } else if (format === "text") {
          body = htmlToText(raw);
        } else {
          body = htmlToMarkdown(raw);
        }

        const bytes = Buffer.byteLength(body, "utf8");
        let truncated = false;
        let fullPath: string | undefined;
        let out = body;

        if (bytes > MAX_INLINE_BYTES) {
          truncated = true;
          const dir = mkdtempSync(join(tmpdir(), "pi-webfetch-"));
          fullPath = join(dir, "content");
          writeFileSync(fullPath, body, "utf8");
          out = `${body.slice(0, MAX_INLINE_BYTES)}\n\n[...truncated ${bytes - MAX_INLINE_BYTES} bytes. Full content saved to ${fullPath} — use read/grep on it.]`;
        }

        const header = `# ${url}\n_status: ${res.status} • type: ${contentType || "unknown"} • ${bytes} bytes${truncated ? " (truncated)" : ""}_\n\n`;

        return {
          content: [{ type: "text", text: header + out }],
          details: {
            url,
            format,
            status: res.status,
            contentType,
            bytes,
            truncated,
            fullPath,
          } as WebfetchDetails,
          isError: !res.ok,
        };
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        const aborted = timeout.signal.aborted;
        return {
          content: [
            {
              type: "text",
              text: aborted ? `Error: request timed out or was cancelled fetching ${url}` : `Error fetching ${url}: ${message}`,
            },
          ],
          details: { url, format, error: message } as WebfetchDetails,
          isError: true,
        };
      } finally {
        clearTimeout(timer);
        signal?.removeEventListener("abort", onAbort);
      }
    },

    renderCall(args, theme) {
      const fmt = args.format ?? "markdown";
      return new Text(
        theme.fg("toolTitle", theme.bold("webfetch ")) + theme.fg("muted", args.url) + theme.fg("dim", ` (${fmt})`),
        0,
        0,
      );
    },

    renderResult(result, _opts, theme) {
      const d = result.details as WebfetchDetails | undefined;
      if (!d) return new Text("", 0, 0);
      if (d.error) return new Text(theme.fg("error", `✗ ${d.error}`), 0, 0);
      let line = theme.fg("success", "✓ ") + theme.fg("muted", `${d.status} `) + theme.fg("dim", `${d.bytes ?? 0}b`);
      if (d.truncated) line += theme.fg("warning", " (truncated)");
      return new Text(line, 0, 0);
    },
  });
}
