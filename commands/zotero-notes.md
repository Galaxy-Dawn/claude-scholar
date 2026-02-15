---
name: zotero-notes
description: Batch read papers from Zotero collection and generate structured reading notes for each paper
args:
  - name: collection
    description: Zotero collection name or keyword
    required: true
  - name: format
    description: Note format (summary/detailed/comparison)
    required: false
    default: detailed
tags: [Research, Zotero, Reading Notes, Paper Analysis]
---

# /zotero-notes - Zotero Batch Reading Notes Generator

Generate structured reading notes for papers in the Zotero collection "$collection", in "$format" format.

## Usage

### Basic Usage

```bash
/zotero-notes "Core Papers"
```

### Summary Format

```bash
/zotero-notes "Research-Attention-2026-02" summary
```

### Comparison Format

```bash
/zotero-notes "Methods" comparison
```

## Workflow

### Step 1: Load Papers

1. Call `mcp__zotero__get_collections` to find the matching collection
2. Call `mcp__zotero__get_collection_items` to list all papers
3. Call `mcp__zotero__get_items_details` to get metadata

### Step 2: Read and Annotate

For each paper with a PDF:
1. Call `mcp__zotero__get_item_fulltext` to read content
2. Generate notes based on format:

**summary format:**
- One-paragraph summary per paper
- One-sentence core contribution

**detailed format (default):**
- One-sentence positioning
- Problem and motivation
- Method (core approach, key modules, essential differences from other methods)
- Experiment overview (datasets, metrics, overall performance, ablation findings)
- Limitations and questions (author-acknowledged + your critique)
- Relationship to other works (position in the literature landscape)
- Value for my research (reusable / pitfalls to avoid / experimental reference)

**comparison format:**
- Side-by-side comparison tables
- Method comparison matrix
- Performance comparison (if applicable)

### Step 3: Output

1. Create `reading-notes-{collection}.md` containing all notes
2. If format is "comparison", additionally create a comparison table
3. List papers that could not be read (no PDF) for manual processing

### Step 4: Write Notes to Zotero (Optional)

If the user requests writing notes to Zotero (rather than just generating markdown files), use the Zotero REST API to create child notes:

**Note**: The MCP server has no `add_note` tool — notes must be created via REST API.

```bash
curl -s -X POST \
  -H "Zotero-API-Key: {ZOTERO_API_KEY from environment variable}" \
  -H "Content-Type: application/json" \
  "https://api.zotero.org/users/{user_id}/items" \
  -d '[{"itemType": "note", "parentItem": "{item_key}", "note": "{html_content}", "tags": [{"tag": "auto-generated"}, {"tag": "claude-scholar"}]}]'
```

Process one paper at a time, each with an independent POST. Do not attempt to generate a single script for all notes at once.

**Content retrieval fallback chain**:
1. `get_item_fulltext` → extract method details and experimental results
2. Failure → `WebFetch(https://doi.org/{DOI})` → scrape paper page abstract
3. Failure → `abstractNote` + Claude domain knowledge

Use TodoWrite to track progress.

## Note Formats

| Format | Description | Use Case |
|--------|-------------|----------|
| `summary` | One paragraph + one core contribution per paper | Quick browsing, group meeting reports |
| `detailed` | Complete structured notes | Deep understanding, paper writing reference |
| `comparison` | Comparison matrix + side-by-side analysis | Method selection, Related Work writing |

## Output Files

```
{project_dir}/
├── reading-notes-{collection}.md    # Reading notes for all papers
└── comparison-matrix.md             # Comparison matrix (comparison format)
```

## Practical Lessons (from the Cross-Subject EEG project)

### Batch Processing: Validate 1 First, Then Process in Batches
- The first paper must complete the full pipeline (content retrieval → note generation → API POST → verify rendering in Zotero)
- **Template confirmation**: After generating the first note, have the user check the HTML rendering in the Zotero desktop client and confirm the template before batch processing the rest. Avoid generating everything only to start over.
- After confirmation, process 4-7 papers per batch, with a pause between batches for review

### macOS Python SSL Workaround
On macOS, `urllib` accessing the Zotero API triggers `SSLCertVerificationError`. You must add:
```python
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
# Pass context=ctx in urlopen
```

### Cross-Referencing in Notes
In the "Relationship to other works" section, reference other papers in the same collection using Zotero item keys (e.g., "extends the Riemannian geometry framework of Barachant (QFJRNJUR)"), forming a literature network rather than isolated entries.

### Content Retrieval Fallback Chain: Actual Performance
In practice, `get_item_fulltext` success rate depends on whether PDFs are attached. Most papers end up using the third path (abstractNote + domain knowledge), which works well enough for well-known papers in the field (e.g., EEGNet, LaBraM).

## Notes

- Ensure the Zotero MCP service is properly configured and running
- Full-text reading depends on PDF attachments; papers without PDFs will be flagged in the output
- If user has local PDFs for papers missing attachments, use `mcp__zotero__import_pdf_to_zotero` to add them before running this command
- Processing large numbers of papers takes time; consider processing by sub-collection in batches
- Collection names support fuzzy matching — entering keywords is sufficient
- If API rate limit is encountered, wait 5 seconds and retry, up to 3 attempts

## Completion Checklist

Before finishing, verify:

- [ ] All papers in the collection processed (or flagged if no PDF)
- [ ] Reading notes generated in requested format (summary/detailed/comparison)
- [ ] Output file `reading-notes-{collection}.md` created
- [ ] Comparison matrix created (if comparison format)
- [ ] Papers without PDFs listed for manual processing

## Error Handling

- **`get_item_fulltext` fails** → Use `WebFetch` on the paper's DOI URL → fall back to `abstractNote` from `get_items_details` + domain knowledge
- **REST API POST fails (Step 4)** → Check API key and user ID; verify item_key is valid
- **API rate limit** → Wait 5 seconds and retry, up to 3 attempts

## Completion Checklist

Before finishing, verify:

- [ ] All papers in the collection processed (or flagged if no PDF)
- [ ] Reading notes generated in requested format (summary/detailed/comparison)
- [ ] Output file `reading-notes-{collection}.md` created
- [ ] Comparison matrix created (if comparison format)
- [ ] Papers without PDFs listed for manual processing

## Related Resources

- **Commands**: `/research-init` - Create new research project, `/zotero-review` - Collection literature synthesis analysis
- **Agent**: `literature-reviewer` - Literature search and analysis
- **Skill**: `research-ideation` - Research ideation methodology
