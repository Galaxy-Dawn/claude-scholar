---
name: zotero-notes
description: Batch read papers from Zotero and create/update detailed reading notes, preferably inside the bound Obsidian project knowledge base
args:
  - name: collection
    description: Zotero collection name or keyword
    required: true
  - name: format
    description: Note format (summary/detailed/comparison)
    required: false
    default: detailed
tags: [Research, Zotero, Obsidian, Reading Notes, Paper Analysis]
---

# /zotero-notes - Zotero to Obsidian Reading Notes

Read papers from the Zotero collection "$collection" and create or update detailed reading notes.

## Default target

- **Preferred target**: the bound Obsidian project knowledge base (`Sources/Papers/*.md`)
- **Fallback target**: `reading-notes-{collection}.md` in the working directory if the current repo is not bound to Obsidian

## Workflow

### Step 0: Resolve whether the current repo is Obsidian-bound

1. If `.opencode/project-memory/registry.yaml` exists for the current repo, treat the bound vault as the primary output target.
2. If the repo is a research project but not yet bound, bootstrap it first.
3. If there is no bound project context, fall back to a plain markdown output in the working directory.
4. Treat this command as an explicit agent-first ingestion pass under `$zotero-obsidian-bridge`.

### Step 1: Load papers from Zotero

1. Call `mcp__zotero__zotero_get_collections` to find the matching collection.
2. Call `mcp__zotero__zotero_get_collection_items` to list the papers.
3. For each item, call:
   - `mcp__zotero__zotero_get_item_metadata`
   - `mcp__zotero__zotero_get_item_fulltext` when a PDF is available
   - `mcp__zotero__zotero_get_annotations` when helpful
   - `mcp__zotero__zotero_get_notes` when helpful
4. If MCP transport fails but a local `zotero-mcp` checkout is available, use the local Python fallback instead of stopping the pass.
5. Treat Zotero `webpage` items as valid inputs when they still expose meaningful metadata or full text.

### Step 2: Create/update the canonical paper note

If the project is Obsidian-bound, create or update one canonical note per paper under `Sources/Papers/`.

Each detailed note should contain:
- `Claim`
- `Research question`
- `Method`
- `Evidence`
- `Strengths`
- `Limitation`
- `Direct relevance to repo`
- `Relation to other papers`
- `Knowledge links`
- `Optional downstream hooks`

Recommended frontmatter fields:
- `title`, `authors`, `year`, `venue`, `doi`, `url`, `citekey`, `zotero_key`
- `keywords`, `concepts`, `methods`
- `related_papers`, `linked_knowledge`, `argument_claims`, `argument_methods`, `argument_gaps`, `paper_relationships`

Prefer updating the existing note over creating a sibling note.

### Step 3: Collection coverage and synthesis

After the paper-note pass:
- update a collection inventory note when the source is a named collection
- record item -> canonical note mapping and coverage counts such as `16 / 16`
- synthesize durable literature knowledge under `Knowledge/`, for example:
  - `Knowledge/Literature Overview.md`
  - `Knowledge/Method Taxonomy.md`
  - `Knowledge/Research Gaps.md`

Prefer updating existing canonical knowledge notes over creating parallel summaries.

### Step 4: Refresh the default literature canvas

After batch note creation or substantial note updates, load `obsidian-literature-workflow`, set `skill_dir` to the directory of its active `SKILL.md`, and refresh:

```bash
python3 "$skill_dir/scripts/build_literature_canvas.py" --cwd "$PWD"
```

This rebuilds `Maps/literature.canvas` from paper-note and knowledge-note links.

### Step 5: Optional synthesis outputs

- If `format=comparison`, also update `Writing/comparison-matrix.md`.
- If the paper batch already supports a thematic synthesis, update `Writing/literature-review.md`.

### Step 6: Minimal write-back

Always update:
- today's `Daily/YYYY-MM-DD.md`
- repo-local project memory when project state changes

### Step 7: Final response

Include:
- collection size and coverage summary
- created / updated note paths
- optional `obsidian://open` links
- optional `obsidian open ...` suggestions when CLI is available

## Fallback behavior

If the repo is not bound to Obsidian:
- create `reading-notes-{collection}.md`
- if `format=comparison`, also create `comparison-matrix.md`

## Notes

- Zotero remains the source of truth for collection structure, metadata, attachments, PDF full text, and annotations.
- Obsidian remains the source of truth for durable reading notes, project relevance, and cross-note linking.
- Default bridge targets are `Sources/Papers/` and `Knowledge/`.
- Do not dump raw full text into Obsidian paper notes.
- Do not create `Concepts/` or `Datasets/` trees by default.
- Refresh `Maps/literature.canvas` by default after a substantial Zotero ingestion pass.
- Treat `Experiments/` and `Results/` as later project workflows, not the default Zotero-import destination.
