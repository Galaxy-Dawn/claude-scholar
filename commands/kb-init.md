---
name: kb-init
description: Initialize or rebuild a vault-first, project-scoped Obsidian KB under Research/{project-slug}/ for the current repository.
args:
  - name: project
    description: Optional project name. Defaults to the repository name.
    required: false
  - name: vault_path
    description: Absolute Obsidian vault path. Defaults to OBSIDIAN_VAULT_PATH.
    required: false
  - name: force
    description: Force scaffold refresh when the project already exists.
    required: false
    default: false
tags: [Research, Obsidian, KB]
---

# /kb-init

Use the new KB scaffold under `Research/{project-slug}/`.

## Run

Load `obsidian-project-kb-core` and set `skill_dir` to the directory of its active `SKILL.md`. Use the repository root as `--cwd` and the vault's absolute path as `--vault-path`.

```bash
python3 "$skill_dir/scripts/project_kb.py" bootstrap \
  --cwd "$PWD" \
  --vault-path "$vault_path"
```

For PowerShell with Python on `PATH`:

```powershell
python (Join-Path $skill_dir 'scripts/project_kb.py') bootstrap --cwd $PWD.Path --vault-path $vault_path
```

If `project` is provided, add:

```bash
--project-name "$project"
```

If `force=true`, add:

```bash
--force
```

## Verify

The scaffold must contain:

```text
Research/{project-slug}/
  00-Hub.md
  01-Plan.md
  02-Index.md
  Sources/*
  Knowledge/
  Experiments/
  Results/Reports/
  Writing/
  Daily/
  Maps/
  Archive/
  _system/
```

It must also keep repo-local `.opencode/project-memory/*` as runtime binding metadata only.
