/**
 * Session Summary Plugin - Work log on session.deleted
 * OpenCode V2 event subscription.
 */
import { atLocation, getGitInfo, getProjectMemoryBinding, getTodoInfo } from "./lib/common";
import * as fs from "fs";
import * as path from "path";
import { Plugin } from "@opencode/plugin";

export default Plugin.define({
  id: "scholar-session-summary",
  setup(ctx) {
    const controller = new AbortController();
    // Deletion carries an optional location. Remember the latest observed
    // location for sessions hosted here; never assume the plugin load path.
    const locations = new Map<string, string>();
    const run = async () => {
      for await (const event of ctx.event.subscribe({
        types: ["session.created", "session.moved", "session.deleted"],
        signal: controller.signal,
      })) {
        const { sessionID } = event.data;
        if (event.type === "session.created") {
          const directory = event.data.location.directory;
          if (atLocation(directory, ctx.location.directory)) locations.set(sessionID, directory);
          continue;
        }
        if (event.type === "session.moved") {
          const directory = event.data.location.directory;
          if (locations.has(sessionID) && path.isAbsolute(directory)) locations.set(sessionID, directory);
          continue;
        }
        const tracked = locations.get(sessionID);
        const directory = event.location?.directory;
        const cwd = directory ? (atLocation(directory, ctx.location.directory) ? directory : undefined) : tracked;
        locations.delete(sessionID);
        if (!cwd) continue;
        try {
          writeSummary(cwd);
        } catch (error) {
          console.warn("[session-summary]", error);
        }
      }
    };
    void run().catch((error) => {
      if (!controller.signal.aborted) console.warn("[session-summary]", error);
    });
    return () => controller.abort();
  },
});

function writeSummary(cwd: string) {
  const logDir = path.join(cwd, ".opencode", "logs");
  fs.mkdirSync(logDir, { recursive: true });

  const now = new Date();
  const ds = now.toISOString().split("T")[0].replace(/-/g, "");
  const logFile = path.join(logDir, `session-${ds}.md`);

  const git = getGitInfo(cwd);
  const todo = getTodoInfo(cwd);
  const binding = getProjectMemoryBinding(cwd);

  let log = `# Work Log - ${path.basename(cwd)}\n\n`;
  log += `**Time**: ${now.toISOString()}\n\n`;
  log += `## Changes\n`;
  if (git.is_repo && git.has_changes) {
    for (const c of git.changes) log += `- ${c}\n`;
  } else {
    log += "No changes\n";
  }

  if (binding.bound) {
    log += `\n## Obsidian Minimum Write-back\n`;
    log += `- Daily/YYYY-MM-DD.md\n`;
    log += `- ${binding.memoryPath || '.opencode/project-memory/<project_id>.md'}\n`;
    log += `- 00-Hub.md (only when top-level project status changes)\n`;
  }

  log += `\n## Next Steps\n`;
  if (git.has_changes) log += `- Uncommitted: ${git.changes_count} files\n`;
  if (todo.found && todo.pending > 0) log += `- Todos: ${todo.pending} pending\n`;
  if (binding.bound) log += `- Verify bound Obsidian updates before leaving this research turn\n`;

  fs.writeFileSync(logFile, log, "utf8");
  console.log(`📝 Session summary saved to ${logFile}`);
}
