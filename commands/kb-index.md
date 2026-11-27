---
name: kb-index
description: Refresh the auto index block inside 02-Index.md without overwriting curated content.
tags: [Research, Obsidian, KB]
---

# /kb-index

Load `obsidian-project-kb-core`; `skill_dir` is the directory of its active `SKILL.md`.

```bash
python3 "$skill_dir/scripts/project_kb.py" sync --cwd "$PWD" --scope index
```

The index is a human navigation note, not a registry mirror.
Only the auto-generated block should be refreshed here; curated sections must stay intact.
