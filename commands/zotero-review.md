---
name: zotero-review
description: Read and analyze papers from an existing Zotero collection, generate structured notes and literature review
args:
  - name: collection
    description: Zotero collection name or keyword to search
    required: true
  - name: depth
    description: Analysis depth (quick/deep)
    required: false
    default: deep
tags: [Research, Zotero, Literature Review, Paper Analysis]
---

# /zotero-review - Zotero Collection Literature Analysis

Read and analyze papers in the Zotero collection "$collection", with analysis depth "$depth".

## Usage

### Basic Usage

```bash
/zotero-review "Sparse Attention"
```

### Quick Analysis

```bash
/zotero-review "Research-Transformer-2026-02" quick
```

## Workflow

### Step 1: Locate Collection

1. Call `mcp__zotero__get_collections` to list all collections
2. Find the collection matching "$collection"
3. Call `mcp__zotero__get_collection_items` to get all items in the collection

### Step 2: Read Papers

For each paper in the collection:
1. Call `mcp__zotero__get_items_details` with `include_abstract: true` to get metadata and abstracts (ensures abstracts are available as fallback if full-text retrieval fails)
2. Call `mcp__zotero__get_item_fulltext` to read full text (if PDF is available)
3. If depth is "quick": analyze only the abstract and introduction
4. If depth is "deep": analyze the complete paper content

### Step 3: Generate Notes

Create structured notes for each paper:
- **Research Question**: What problem does this paper address?
- **Core Method**: What method/approach is proposed?
- **Key Findings**: What are the main results?
- **Limitations**: What are the limitations?
- **Relevance to Our Research**: How does it relate to our work?

If depth is "deep": Create individual note files in the `paper-notes/` directory, one file per paper named `paper-notes/{paper-title}.md`. These notes serve as intermediate analysis that feeds into the final `literature-review.md`.

### Step 4: Synthesis

1. Group papers by theme/method
2. Identify common patterns and divergences
3. Generate comparison matrix
4. Update or create `literature-review.md`

Use TodoWrite to track progress.

## Analysis Depth

| Depth | Description | Use Case |
|-------|-------------|----------|
| `quick` | Analyze abstract and introduction only | Quick overview, initial screening |
| `deep` | Analyze complete paper content | In-depth understanding, writing reviews |

## Output Files

```
{project_dir}/
├── literature-review.md      # Structured literature review (with comparison analysis)
└── paper-notes/              # Individual notes per paper (deep mode)
    ├── {paper1-title}.md
    └── {paper2-title}.md
```

## Notes

- Ensure the Zotero MCP service is properly configured and running
- Full-text analysis depends on PDF attachments; papers without PDFs will use metadata only
- If user has local PDFs for papers missing attachments, use `mcp__zotero__import_pdf_to_zotero` to add them
- Deep mode takes longer; for large collections, consider processing in batches
- Collection names support fuzzy matching — entering keywords is sufficient

## Error Handling

If MCP tools fail during execution, use these fallback strategies:

1. **`get_item_fulltext` fails** → Use `WebFetch` on the paper's DOI URL → fall back to `abstractNote` from `get_items_details` + domain knowledge
2. **`get_collection_items` fails** → Use `search_library` with collection-related keywords as alternative. Note: `search_library` searches the entire library, not scoped to a specific collection. Filter results by comparing against the target collection's expected papers.
3. **Single paper fails** → Log error, skip, and continue to next paper
4. **API rate limit** → Wait 5 seconds and retry, up to 3 attempts

## Completion Checklist

Before finishing, verify:

- [ ] All papers in the collection have been read (or flagged if no PDF)
- [ ] Structured notes generated for each paper
- [ ] Individual `paper-notes/{paper-title}.md` files created (deep mode)
- [ ] `literature-review.md` generated with thematic grouping and comparison matrix
- [ ] Papers without PDFs listed for manual processing

## Related Resources

- **Commands**: `/research-init` - Create new research project, `/zotero-notes` - Batch generate reading notes
- **Agent**: `literature-reviewer` - Literature search and analysis
- **Skill**: `research-ideation` - Research ideation methodology
