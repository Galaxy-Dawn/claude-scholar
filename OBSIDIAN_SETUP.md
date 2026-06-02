# Obsidian Project Knowledge Base Setup

Kimi Scholar ships with a built-in Obsidian research knowledge-base workflow. It does **not** require MCP or an API key.

## What this provides

Obsidian is treated as the default knowledge base for a research project, not just a paper library. A project knowledge base can store:

- stable project background and research questions
- paper notes and literature syntheses
- experiment runbooks and result summaries
- daily research logs, scratch notes, and sync queues
- writing assets such as drafts, slides, proposals, and rebuttal material
- archived project knowledge that should not stay on the main working surface

## Requirements

### Required
- A local Obsidian vault path
- `OBSIDIAN_VAULT_PATH` set in your environment, or passed explicitly when bootstrapping a project

### Optional
- Obsidian Desktop installed and open for navigation
- `obsidian` CLI available for open/search/daily actions
- `OBSIDIAN_VAULT_NAME` for cleaner `obsidian://` links and CLI targeting

## Built-in skills

Kimi Scholar includes a project-scoped Obsidian KB workflow.

Most relevant for the default workflow:

- `obsidian-project-kb-core`
- `obsidian-source-ingestion`
- `obsidian-literature-workflow`
- `obsidian-kb-artifacts`
- `defuddle`

Some optional graph-oriented helpers may still exist in the repo, but the default workflow does **not** depend on `.base`, MCP, or API services. The main default graph artifact is `Maps/literature.canvas`; additional `.base` views or project/experiment canvases are explicit-only.

## Default behavior

When Kimi Scholar is running inside a repository that contains `.kimi-code/project-memory/registry.yaml`, it should treat the repository as bound to an Obsidian project knowledge base and update it by default.

If the repository is not yet bound, but it looks like a research project (for example it contains `.git`, `README.md`, `docs/`, `notes/`, `plan/`, `results/`, `outputs/`, `src/`, or `scripts/`), Kimi Scholar should bootstrap a project knowledge base automatically.

## Project structure in the vault

```text
Research/{project-slug}/
  00-Hub.md
  01-Plan.md
  02-Index.md
  Sources/
    Papers/
    Web/
    Docs/
    Data/
    Interviews/
    Notes/
  Knowledge/
  Experiments/
  Results/
    Reports/
  Writing/
  Daily/
  Maps/
  Archive/
  _system/
    registry.md
    schema.md
    lint-report.md
```

Key generated files commonly include:

- `02-Index.md`
- `_system/registry.md`
- `_system/schema.md`
- `_system/lint-report.md`
- `.kimi-code/project-memory/{project_id}.md`
- `Maps/literature.canvas` when literature workflow needs it

## Repository-local memory binding

Each research repo gets a local binding under:

```text
.kimi-code/project-memory/
  registry.yaml
  {project_id}.md
```

- `registry.yaml` stores the repo ↔ vault binding
- `{project_id}.md` stores the assistant-facing project memory for incremental syncs

## Note language

Generated and synced notes resolve their language with this priority:
1. project config in `.kimi-code/project-memory/registry.yaml`
2. environment variable `OBSIDIAN_NOTE_LANGUAGE`
3. default `en`

Note: `registry.yaml` remains a repo-local runtime binding file. The visible project source of truth stays in `_system/registry.md`.

Supported values:
- `en`
- `zh-CN`

Per-project example:

```json
{
  "projects": {
    "my-project": {
      "project_id": "my-project",
      "vault_root": "/path/to/vault/Research/my-project",
      "note_language": "zh-CN"
    }
  }
}
```

Existing English and Chinese headings remain compatible during sync, so changing the configured language does not break older notes.

## Main workflows in Kimi

Kimi does not assume Claude Code-style slash commands. Use the same KB flows through natural-language requests plus the corresponding skills and helper scripts:

- initialize or import a project KB via `obsidian-project-kb-core`
- route external material into `Sources/*` via `obsidian-source-ingestion`
- run deterministic maintenance through `skills/obsidian-project-kb-core/scripts/project_kb.py`
- repair wikilinks and derived artifacts through `obsidian-kb-artifacts`
- generate literature synthesis from `Sources/Papers` through `obsidian-literature-workflow`
- archive, purge, rename, detach, or rebuild KB objects through the lifecycle helpers

## Minimum bound-repo maintenance

When a repo is already bound through `.kimi-code/project-memory/registry.yaml`, Kimi Scholar should keep automatic maintenance conservative:

- always verify `Daily/YYYY-MM-DD.md` when the turn changes research state,
- update `00-Hub.md` only when top-level project status actually changes,
- update `.kimi-code/project-memory/{project_id}.md` whenever project state changes,
- keep `Knowledge/`, `Experiments/`, `Results/`, and `Writing/` agent-first rather than automatically rewriting them every turn.

## Optional Obsidian CLI installation

The official Obsidian CLI is built into newer desktop installers. To use `obsidian ...` commands:

1. Use an Obsidian desktop build that supports CLI registration.
2. In Obsidian Desktop, open `Settings -> General -> Advanced`.
3. Turn on **Command line interface**.
4. Ensure `/Applications/Obsidian.app/Contents/MacOS` is on your `PATH` on macOS (for example via `~/.zprofile`).
5. Restart your terminal, then verify:

```bash
obsidian help
obsidian search query="diffusion" limit=5
```

If you see `Command line interface is not enabled`, the shell path is fine but the Obsidian in-app toggle is still off.

## Lifecycle actions

### Detach
- stop automatic syncing
- keep vault content
- keep project memory file

### Archive
- **note archive** moves a canonical note into `Research/{project-slug}/Archive/`
- **project archive** moves the whole project into `Research/_archived/{project-slug}-{date}/`
- archive keeps history and disables syncing for project-level archive

### Purge
- permanently delete the binding, project memory, and vault project folder
- only use when the user explicitly asks for permanent deletion

## Optional CLI and URI usage

Kimi Scholar can optionally use the official Obsidian CLI and URI scheme:

- CLI docs: <https://help.obsidian.md/cli>
- URI docs: <https://help.obsidian.md/uri>

Examples:

```bash
obsidian help
obsidian search query="diffusion" limit=10
obsidian daily:append content="- [ ] Follow up on experiment"
```

```text
obsidian://open?vault=My%20Vault&file=Research%2Fproject-slug%2F00-Hub
obsidian://search?vault=My%20Vault&query=%23experiment
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bootstrap fails with missing vault path | Set `OBSIDIAN_VAULT_PATH` or pass a vault path explicitly |
| Project keeps re-importing | Check `.kimi-code/project-memory/registry.yaml` exists and points to the correct repo root |
| The vault still shows older topologies | Those are from older docs or older project generations; the current default workflow uses the structure above and only keeps `Maps/literature.canvas` by default |
| CLI commands fail | Check that `Settings -> General -> Advanced -> Command line interface` is enabled; otherwise continue with filesystem-only sync |
| “Remove project knowledge” is too destructive | Use archive or detach; purge is only for permanent deletion |

## WSL -> Windows mirror workflow

If you run Kimi Scholar inside WSL but prefer opening Obsidian through native Windows for more stable window behavior, use a two-copy setup:

- keep the WSL vault as the source of truth (for example `<repo-root>/obsidian-vault`)
- keep a Windows-local mirror directory mounted in WSL (for example `<wsl-mounted-windows-vault-path>`)
- open the mirrored Windows-local directory in Windows Obsidian

Sync with:

```bash
bash scripts/sync_obsidian_to_windows.sh   --windows-path <wsl-mounted-windows-vault-path>
```

Preview first if needed:

```bash
bash scripts/sync_obsidian_to_windows.sh   --windows-path <wsl-mounted-windows-vault-path>   --dry-run
```

By default the sync deletes mirror-only files that no longer exist in the WSL source. Add `--no-delete` if you want to keep extra files in the Windows mirror.
