---
name: kb-archive
description: Archive, detach, purge, or rename KB objects while keeping registry, index, and links consistent.
args:
  - name: action
    description: detach, archive, purge, rename
    required: true
  - name: target
    description: Project-relative note path when operating on a note.
    required: false
  - name: dest
    description: Destination note path for rename.
    required: false
tags: [Research, Obsidian, KB, Lifecycle]
---

# /kb-archive

Use this command for KB lifecycle actions.

Load `obsidian-project-kb-core`; `skill_dir` is the directory of its active `SKILL.md`.

## Project-level lifecycle

```bash
python3 "$skill_dir/scripts/project_kb.py" lifecycle --cwd "$PWD" --mode "$action"
```

Project archive means moving the whole project to:

```text
Research/_archived/{project-slug}-{date}/
```

## Note-level lifecycle

```bash
python3 "$skill_dir/scripts/project_kb.py" note-lifecycle --cwd "$PWD" --mode "$action" --note "$target"
```

If `action=rename`, also pass `--dest "$dest"`.

Note archive means moving a canonical note into:

```text
Research/{project-slug}/Archive/
```
