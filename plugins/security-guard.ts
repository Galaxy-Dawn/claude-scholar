/**
 * Security Guard Plugin
 * Hook: tool.execute.before
 */
import { Plugin } from "@opencode/plugin";

const BLOCK_PATTERNS = [
  /rm\s+-rf\s+\/(\s|$)/,
  /rm\s+--no-preserve-root/,
  /dd\s+if=\/dev\/(zero|random)/,
  /mkfs\./,
];

const WARN_PATTERNS = [
  /git\s+push\s+.*(-f|--force)/,
  /git\s+reset\s+--hard/,
  /git\s+clean\s+-[a-z]*f/,
  /rm\s+-[rf]/,
  /chmod\s+(-R\s+)?777/,
  /DROP\s+(DATABASE|TABLE)/i,
];

export default Plugin.define({
  id: "scholar-security-guard",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", (event) => {
      const args = event.input as { command?: unknown; filePath?: unknown; file_path?: unknown } | undefined;

      if ((event.tool === "shell" || event.tool === "bash") && typeof args?.command === "string") {
        for (const p of BLOCK_PATTERNS) {
          if (p.test(args.command)) {
            console.warn("[security-guard] Blocked a shell command");
            args.command = "echo 'Blocked by security guard'";
            return;
          }
        }
        for (const p of WARN_PATTERNS) {
          if (p.test(args.command)) {
            console.warn("[security-guard] A shell command matched a warning pattern");
          }
        }
      }

      const fp = args?.filePath ?? args?.file_path;
      if ((event.tool === "write" || event.tool === "edit") && typeof fp === "string") {
        const sensitive = ["/etc/", "/usr/bin/", "/sbin/", "/System/"];
        for (const sp of sensitive) {
          if (fp.startsWith(sp)) {
            console.warn(`[security-guard] WARNING: system path ${sp}`);
            return;
          }
        }
      }
    });
  },
});
