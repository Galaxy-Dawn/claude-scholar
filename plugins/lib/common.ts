/**
 * Shared plugin utilities for OpenCode plugins.
 */
import { execFileSync, execSync } from "child_process";
import * as fs from "fs";
import { homedir } from "node:os";
import * as path from "path";
import { YAML } from "bun";

export function atLocation(a: string | undefined, b: string): a is string {
  if (!a || !path.isAbsolute(a)) return false;
  const normalize = (value: string) => process.platform === "win32"
    ? path.resolve(value).toLowerCase() : path.resolve(value);
  return normalize(a) === normalize(b);
}

export interface GitInfo {
  is_repo: boolean;
  branch: string;
  changes_count: number;
  has_changes: boolean;
  changes: string[];
}

export function getGitInfo(cwd: string): GitInfo {
  try {
    execSync("git rev-parse --git-dir", { cwd, stdio: "pipe" });
    let branch = "unknown";
    try {
      branch = execSync("git branch --show-current", { cwd, encoding: "utf8", stdio: "pipe" }).trim();
    } catch {}
    let changes = "";
    try {
      changes = execSync("git status --porcelain", { cwd, encoding: "utf8", stdio: "pipe" });
    } catch {}
    const changeList = changes.trim().split("\n").filter(Boolean);
    return { is_repo: true, branch, changes_count: changeList.length, has_changes: changeList.length > 0, changes: changeList };
  } catch {
    return { is_repo: false, branch: "unknown", changes_count: 0, has_changes: false, changes: [] };
  }
}

export interface TodoInfo {
  found: boolean;
  file: string | null;
  path: string | null;
  total: number;
  done: number;
  pending: number;
}

export function getTodoInfo(cwd: string): TodoInfo {
  const todoFiles = [
    path.join(cwd, "docs", "todo.md"),
    path.join(cwd, "TODO.md"),
    path.join(cwd, ".opencode", "todos.md"),
    path.join(cwd, "TODO"),
    path.join(cwd, "notes", "todo.md"),
  ];
  for (const file of todoFiles) {
    if (fs.existsSync(file)) {
      try {
        const content = fs.readFileSync(file, "utf8");
        const total = (content.match(/^[-*] \[[ x]\]/gim) || []).length;
        const done = (content.match(/^[-*] \[x\]/gim) || []).length;
        return { found: true, file: path.basename(file), path: file, total, done, pending: total - done };
      } catch { continue; }
    }
  }
  return { found: false, file: null, path: null, total: 0, done: 0, pending: 0 };
}


export interface ProjectMemoryBinding {
  bound: boolean;
  registryPath: string | null;
  memoryPath: string | null;
  projectId: string | null;
  vaultRoot: string | null;
}

export interface ResearchRepoCandidate {
  candidate: boolean;
  markers: string[];
}

export function getProjectMemoryBinding(cwd: string): ProjectMemoryBinding {
  let repo = cwd;
  try {
    repo = execFileSync("git", ["rev-parse", "--show-toplevel"], { cwd, encoding: "utf8", stdio: "pipe" }).trim() || cwd;
  } catch {}
  type Entry = { vault_root?: string; project_root?: string; vault_path?: string; repo_roots?: string[] };
  const projects = new Map<string, { registryPath: string; entry: Entry }>();
  for (const dir of [".opencode", ".claude"]) {
    const registryPath = path.join(repo, dir, "project-memory", "registry.yaml");
    if (!fs.existsSync(registryPath)) continue;
    try {
      const raw = fs.readFileSync(registryPath, "utf8").trim();
      const data = (raw.startsWith("{") ? JSON.parse(raw) : YAML.parse(raw)) as {
        projects?: Record<string, Entry>;
      } | undefined;
      for (const [id, entry] of Object.entries(data?.projects || {})) {
        if (entry && /^[a-z\d][a-z\d_-]*$/i.test(id) && !projects.has(id)) {
          projects.set(id, { registryPath, entry });
        }
      }
    } catch {
      return { bound: false, registryPath, memoryPath: null, projectId: null, vaultRoot: null };
    }
  }
  const entries = [...projects];
  const match = entries.length === 1 ? entries[0] : entries.find(([, { entry }]) =>
    Array.isArray(entry.repo_roots) && entry.repo_roots.some((root) =>
      typeof root === "string" && atLocation(root.replace(/^~(?=[\\/]|$)/, () => homedir()), repo)));
  if (match) {
    const [id, { registryPath, entry }] = match;
    return {
      bound: true,
      registryPath,
      memoryPath: path.join(path.dirname(registryPath), `${id}.md`),
      projectId: id,
      vaultRoot: entry.vault_root || entry.project_root || entry.vault_path || null,
    };
  }
  return { bound: false, registryPath: null, memoryPath: null, projectId: null, vaultRoot: null };
}

export function detectResearchRepoCandidate(cwd: string): ResearchRepoCandidate {
  const markers: string[] = [];
  const checks = [
    ".git",
    "README.md",
    path.join("docs"),
    path.join("notes"),
    path.join("plan"),
    path.join("results"),
    path.join("outputs"),
    path.join("src"),
    path.join("scripts"),
  ];
  for (const rel of checks) {
    if (fs.existsSync(path.join(cwd, rel))) markers.push(rel);
  }
  return { candidate: markers.length >= 3, markers };
}
