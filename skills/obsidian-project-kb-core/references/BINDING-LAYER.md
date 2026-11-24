# Binding Layer

Repo-local binding metadata remains under:

```text
.opencode/project-memory/registry.yaml
.opencode/project-memory/<project_id>.md
```

This is the runtime binding layer only.

Earlier installations may store the same two files in `.claude/project-memory/`.
The helper reads both registries. An OpenCode entry takes precedence when the
same project ID appears in both. A sync updates the memory beside the selected
registry.

It may record:
- `project_id`
- `project_slug`
- `repo_roots`
- `vault_root`
- `hub_note`
- `note_language`
- `status`
- `auto_sync`
- recent sync summary

It must not be treated as the project knowledge layer.
The project knowledge layer lives inside:

```text
Research/{project-slug}/
```
