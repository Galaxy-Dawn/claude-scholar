---
name: kb-lint
description: Run deterministic KB health checks and rewrite _system/lint-report.md.
tags: [Research, Obsidian, KB, Lint]
---

# /kb-lint

Load `obsidian-project-kb-core`; `skill_dir` is the directory of its active `SKILL.md`.

```bash
python3 "$skill_dir/scripts/kb_lint.py" --cwd "$PWD"
```

Checks include registry coverage, broken wikilinks, index coverage, canvas validity, and several KB consistency warnings.
