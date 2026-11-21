# Binding Layer

The default repo-local binding and project memory use the same directory.

```text
.claude/project-memory/registry.yaml
.claude/project-memory/<project_id>.md
```

If the default registry is absent, the KB uses an existing
`.codex/project-memory/registry.yaml` and keeps the project memory beside it.
When both registries exist, ordinary KB commands use the `.claude` registry.

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
