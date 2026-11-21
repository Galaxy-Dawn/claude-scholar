# Binding Layer

Repo-local binding metadata remains under:

```text
.codex/project-memory/registry.yaml
.codex/project-memory/<project_id>.md
```

This is the runtime binding layer only.

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
