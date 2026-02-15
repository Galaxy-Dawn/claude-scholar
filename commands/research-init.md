---
name: research-init
description: Initialize a research project with Zotero-integrated literature review. Creates Zotero collections, searches and imports papers, analyzes content, and generates literature review and research proposal.
args:
  - name: topic
    description: Research topic or keywords
    required: true
  - name: scope
    description: Review scope (focused/broad)
    required: false
    default: focused
  - name: output_type
    description: Output type (review/proposal/both)
    required: false
    default: both
tags: [Research, Literature Review, Zotero, Paper Search]
---

# /research-init - Zotero-Integrated Research Startup Workflow

Launch a complete literature survey workflow for the research topic "$topic", with scope "$scope" and output type "$output_type".

## Usage

### Basic Usage

```bash
/research-init "transformer interpretability"
```

### Specify Scope

```bash
/research-init "few-shot learning" focused
```

### Specify All Parameters

```bash
/research-init "neural architecture search" broad both
```

## Workflow

Execute the following steps in order:

### Step 1: Create Zotero Research Collection

1. Call `mcp__zotero__create_collection` to create the main collection, named `Research-{Topic}-{YYYY-MM}` (extract a short PascalCase keyword from the topic, use the current year and month)
2. Create sub-collections under the main collection:
   - `Core Papers`
   - `Methods`
   - `Applications`
   - `Baselines`
   - `To-Read`
3. Record the `collection_key` for each sub-collection (needed for import in Step 2)

### Step 2: Literature Search and Import

1. Use WebSearch to find papers related to "$topic"
   - Search strategy: use the topic directly, plus variant combinations of key terms
   - Target sources: arXiv, Google Scholar, conference proceedings
   - Time range: focused mode searches the last 3 years, broad mode searches the last 5 years
   - Target paper count: 20-50 papers for focused scope, 50-100 for broad scope
2. Extract DOIs from search results
3. **Classify before import**: For each paper, determine which sub-collection it belongs to (Core Papers, Methods, Applications, Baselines, or To-Read) based on its title, abstract, and venue
4. **Pre-import deduplication (two-step)**:
   - Call `mcp__zotero__search_library` with the DOI string to find potential matches
   - Call `mcp__zotero__get_items_details` on results to confirm the DOI field matches exactly
   - If confirmed match → skip import, log ("Already exists: {DOI} → {item_key}")
   - For papers without DOI → search by title using token overlap ratio (lowercase both titles, remove punctuation, compute intersection of words / union of words). Ratio > 0.8 = duplicate
5. **Import with collection assignment**: Call `mcp__zotero__add_items_by_doi` with the target sub-collection's `collection_key` to add papers directly into the correct sub-collection
6. **Fallback for papers without DOI**: Call `mcp__zotero__add_web_item` with the paper URL (e.g., arXiv page) and the target `collection_key`
   - **Note**: Items added via `add_web_item` will have `itemType: webpage`. Prefer finding the DOI and using `add_items_by_doi` whenever possible for proper bibliographic metadata.
7. Collect all `item_key` values from the import results in Steps 2.5 and 2.6, then call `mcp__zotero__find_and_attach_pdfs({ item_keys: [...] })`. Note: `add_items_by_doi` already auto-attaches open-access PDFs by default (`auto_attach_pdf: true`), so this step primarily benefits `add_web_item` imports.

**Note**: Items cannot be moved between Zotero collections via MCP tools after import. Always classify papers and specify the target `collection_key` during import. Post-import reorganization requires manual action in the Zotero desktop client.

### Step 3: Paper Analysis

1. Call `mcp__zotero__get_collection_items` to list imported papers
2. Call `mcp__zotero__get_items_details` with `include_abstract: true` to get metadata and abstracts (ensures abstracts are available as fallback if full-text retrieval fails)
3. Call `mcp__zotero__get_item_fulltext` to read full text of papers with PDFs
3. For each paper, extract:
   - Research question and motivation
   - Core methodology
   - Key findings and contributions
   - Limitations and future work
4. Use these structured notes as intermediate analysis to inform the final `literature-review.md` (they are not a separate output file)

### Step 4: Gap Analysis and Synthesis

1. Analyze all collected papers for:
   - Research trends and directions
   - Methodological gaps
   - Unexplored application domains
   - Contradictions in research findings
2. Identify 2-3 concrete research gaps
3. Formulate potential research questions

### Step 5: Generate Outputs

Generate corresponding files based on output_type "$output_type":

1. **literature-review.md** - Structured literature review with real citations from Zotero
2. **research-proposal.md** - Research proposal (generated when output_type is "proposal" or "both")
3. **references.bib** - BibTeX references from Zotero data
   - **Primary method**: Use Zotero REST API with `?format=bibtex` to export accurate, complete BibTeX entries
     ```
     GET https://api.zotero.org/users/{user_id}/collections/{collection_key}/items?format=bibtex
     ```
     **Note**: The REST API `?format=bibtex` on a collection only exports items directly in that collection, not items in sub-collections. You must iterate each sub-collection key individually, or collect all item keys and use the items endpoint: `GET https://api.zotero.org/users/{user_id}/items?itemKey=KEY1,KEY2,...&format=bibtex`
   - **Fallback**: Construct BibTeX manually from `get_items_details` metadata (note: volume, issue, pages, and publisher fields are not available via this tool — entries will be incomplete)

Use TodoWrite to track progress throughout the workflow.

## Error Handling

If MCP tools fail during execution, use these fallback strategies:

1. **`create_collection` fails** → Create via Zotero REST API directly
2. **`add_items_by_doi` fails** → Fetch metadata via CrossRef API (`https://api.crossref.org/works/{DOI}`) + import via `add_web_item` or Zotero REST API
3. **`get_item_fulltext` fails** → Use `WebFetch` on the paper's DOI URL to scrape abstract → fall back to `abstractNote` from `get_items_details` + domain knowledge
4. **`find_and_attach_pdfs` fails** → Log and continue; PDFs are not required for analysis. If user has local PDFs, use `import_pdf_to_zotero`
5. **Single paper fails** → Log error, skip, and continue to next paper
6. **API rate limit** → Wait 5 seconds and retry, up to 3 attempts

## Completion Checklist

Before finishing, verify:

- [ ] Zotero collection `Research-{Topic}-{YYYY-MM}` created with sub-collections
- [ ] Papers imported and organized into sub-collections (target: 20-50 focused / 50-100 broad)
- [ ] PDFs attached for available open-access papers
- [ ] Full-text analysis completed for core papers
- [ ] Gap analysis identifies at least 2-3 concrete research gaps
- [ ] Output files generated: `literature-review.md`, `references.bib`, and optionally `research-proposal.md`
- [ ] All citations in review correspond to actual Zotero library entries

## Output Files

The command generates the following files:

```
{project_dir}/
├── literature-review.md      # Structured literature review (with Zotero citations)
├── research-proposal.md      # Research proposal (if requested)
└── references.bib            # BibTeX references
```

## Integration Notes

This command will:
1. Use **Zotero MCP** tools to manage literature collections and metadata
2. Trigger the **literature-reviewer agent** for literature analysis
3. Use the **research-ideation skill** methodology (5W1H, Gap Analysis)
4. Search for latest papers via **WebSearch**

## Notes

- Ensure the Zotero MCP service is properly configured and running
- DOI import depends on network connectivity and Zotero's metadata resolution capability
- PDF attachment is limited to open-access papers; paywalled papers must be added manually
- Generated literature reviews and research proposals require manual review and refinement

## Related Resources

- **Skill**: `research-ideation` - Research ideation methodology
- **Agent**: `literature-reviewer` - Literature search and analysis
- **Commands**: `/zotero-review` - Analyze existing Zotero collections, `/zotero-notes` - Batch generate reading notes
