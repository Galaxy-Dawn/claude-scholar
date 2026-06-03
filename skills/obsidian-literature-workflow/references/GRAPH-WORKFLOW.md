# Legacy Literature Map Workflow

This reference is kept for backwards compatibility only.

## Legacy output

- `Knowledge/Literature-Map.md`

## Current default

- Use `CANVAS-WORKFLOW.md` for the current default literature graph artifact.
- The default graph is now `Maps/literature.canvas`, not a Mermaid note.
- Keep this markdown workflow only when a note-based map is specifically requested or needed for compatibility.

## Refresh triggers

Refresh the markdown map only when:
- new Zotero-sourced paper notes are added,
- paper-note links or metadata materially change,
- a batch literature review finishes.

## Recommended command

```bash
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/obsidian-literature-workflow/scripts/build_literature_graph.py" --cwd "$PWD"
```
