---
name: kb-status
description: Summarize the current bound project KB status, including registry counts and key project note paths.
tags: [Research, Obsidian, KB]
---

# /kb-status

Load `obsidian-project-kb-core`; `skill_dir` is the directory of its active `SKILL.md`.

```bash
python3 "$skill_dir/scripts/project_kb.py" status --cwd "$PWD"
```

Optionally add `--project-id "$project_id"` when the repo has multiple bindings.
