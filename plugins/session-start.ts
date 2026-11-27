/**
 * Session Start Plugin - Display project status on session.created
 * OpenCode V2 event subscription.
 */
import { atLocation, detectResearchRepoCandidate, getGitInfo, getProjectMemoryBinding, getTodoInfo } from "./lib/common";
import { Plugin } from "@opencode/plugin";

export default Plugin.define({
  id: "scholar-session-start",
  setup(ctx) {
    const controller = new AbortController();
    const run = async () => {
      for await (const event of ctx.event.subscribe({ types: ["session.created"], signal: controller.signal })) {
        const cwd = event.data.location.directory;
        if (atLocation(cwd, ctx.location.directory)) report(cwd);
      }
    };
    void run().catch((error) => {
      if (!controller.signal.aborted) console.warn("[session-start]", error);
    });
    return () => controller.abort();
  },
});

function report(cwd: string) {
  const git = getGitInfo(cwd);
  const todo = getTodoInfo(cwd);
  const binding = getProjectMemoryBinding(cwd);
  const candidate = detectResearchRepoCandidate(cwd);

  let msg = `📂 ${cwd}\n`;
  if (git.is_repo) {
    msg += `Branch: ${git.branch}`;
    msg += git.has_changes ? ` | ${git.changes_count} uncommitted\n` : " | clean\n";
  }
  if (todo.found) {
    msg += `Todos: ${todo.pending} pending / ${todo.done} done\n`;
  }
  if (binding.bound) {
    msg += `🧠 Obsidian project memory: bound (${binding.projectId || "unknown-project"})\n`;
    if (binding.vaultRoot) msg += `  - Vault root: ${binding.vaultRoot}\n`;
    if (binding.memoryPath) msg += `  - Memory: ${binding.memoryPath}\n`;
    msg += "  - Suggested commands: /kb-sync, /kb-status\n";
  } else if (candidate.candidate) {
    msg += "🧠 Obsidian project memory: research repo candidate\n";
    msg += `  - Detected markers: ${candidate.markers.join(", ")}\n`;
    msg += "  - Suggested command: /kb-init\n";
  }
  console.log(msg.trimEnd());
}
