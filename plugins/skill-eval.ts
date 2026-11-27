/**
 * Obsidian guidance for the OpenCode V2 agent loop.
 */
import { Plugin } from "@opencode/plugin";
import { detectResearchRepoCandidate, getProjectMemoryBinding } from "./lib/common";

export default Plugin.define({
  id: "scholar-skill-eval",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      // The context hook is scoped to the current request location. Re-read so
      // a binding created during a session affects the next request.
      const cwd = ctx.location.directory;
      const binding = getProjectMemoryBinding(cwd);
      if (binding.bound) {
        const memoryPath = binding.memoryPath || ".opencode/project-memory/<project_id>.md";
        const vaultRoot = binding.vaultRoot || "unknown-vault";
        event.system.push({ type: "text",
          text: `This repository is bound to an Obsidian project knowledge base (project_id=${binding.projectId || "unknown-project"}, vault_root=${vaultRoot}). Treat obsidian-project-kb-core as the default curator path for research turns. Start narrowly from ${memoryPath}, 00-Hub.md, 01-Plan.md, today's Daily note, and the best matching canonical note before widening to broader repo exploration. When the user asks to import, summarize, review, update, fix, or synchronize project knowledge, do not stop at read-only exploration once you have enough evidence: finish by updating the minimum necessary canonical note(s) under ${vaultRoot}. Prefer updating existing canonical notes over creating siblings. Only create a new canonical note when no adequate durable note exists yet. For concrete canonical-note creation or update, prefer the deterministic helper path through obsidian-writeback or the compatibility writeback-note helper rather than ad-hoc manual vault edits. Use built-in file tools such as read, glob, and edit for vault files. Do not use shell commands like ls, cat, echo, touch, or sed just to inspect or modify the bound vault unless there is no file-tool alternative. Never add links in 00-Hub.md to notes that do not exist; render folder-only destinations as plain text paths instead.`,
        });
        return;
      }

      if (detectResearchRepoCandidate(cwd).candidate) {
        event.system.push({ type: "text",
          text: "This repository looks like a research-project candidate. When the user is doing project-planning, literature, experiment, result, or writing work, consider obsidian-project-kb-core as the default path to bind the repo into the Obsidian knowledge base.",
        });
      }
    });
  },
});
