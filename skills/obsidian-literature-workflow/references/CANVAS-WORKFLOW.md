# Literature Canvas Workflow

## Default output

- `Maps/literature.canvas`

## Purpose

Provide a default Obsidian literature graph that:
- keeps `Sources/Papers/` as the canonical paper-note surface,
- keeps `Knowledge/` as the canonical synthesis surface,
- visualizes paper-to-paper and paper-to-knowledge relationships,
- stays lightweight enough to refresh after each major Zotero ingestion.

## Default behavior

- Use paper-note frontmatter and wikilinks as the primary graph source.
- Use `Sources/Papers/*.md` and relevant `Knowledge/*.md` as file nodes.
- Create `.canvas` by default for literature ingestion and review workflows.
- Treat Mermaid or markdown graph notes as optional legacy companions, not the default graph artifact.
- Prefer argument-map structure with `paper`, `claim`, `method`, and `gap` nodes over raw all-to-all paper linking.
- Thin edges aggressively; keep only the main reasoning chain and a small number of explicit semantic paper-to-paper relations.
- Hide or down-rank side branches when they clutter the display graph.

## Refresh triggers

Refresh the literature canvas when:
- new Zotero-sourced paper notes are added,
- paper notes gain new `linked_knowledge` edges or meaningful wikilinks,
- knowledge synthesis notes are updated after a literature pass,
- a batch Zotero review or note-ingestion pass finishes,
- a full-collection normalization pass changes many paper-note relationships.

## Recommended command

```bash
python3 "${KIMI_HOME:-$HOME/.kimi}/skills/obsidian-literature-workflow/scripts/build_literature_canvas.py" --cwd "$PWD"
```

## Display rule

- If a second lightweight showcase graph is useful, maintain `Maps/literature-main.canvas` as a filtered presentation copy rather than bloating the default working canvas.
