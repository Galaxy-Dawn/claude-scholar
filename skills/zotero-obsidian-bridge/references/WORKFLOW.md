# Zotero -> Obsidian Workflow

## 1. Resolve the project

1. Run the Obsidian project-memory detect flow.
2. If the repo is bound, use its `Research/{project-slug}/` vault root.
3. If not bound but clearly a research repo, bootstrap first.

## 2. Read from Zotero

Preferred read path per paper:
1. `zotero_get_item_metadata`
2. `zotero_get_item_fulltext`
3. `zotero_get_annotations`
4. `zotero_get_notes`

Use metadata + abstract as the minimum fallback when PDF full text is unavailable.
If the MCP transport path is broken but a local `zotero-mcp` source checkout is available, use the local Python fallback to call the same metadata/fulltext functions instead of aborting.
Treat Zotero `webpage` items as weak-source entries unless they clearly expose full paper metadata and useful fulltext. Abstract-only pages and webpage placeholders may be kept for discovery, but they must remain `To-Read` or `weak-source` and cannot support `Knowledge` or manuscript claims until replaced by a full paper, preprint, or verified artifact.

## 3. Create/update the canonical paper note

Canonical destination:
- `Sources/Papers/{normalized-title-or-citekey}.md`

Update instead of duplicating when the note already exists.

## 4. Detailed reading note requirements

Each durable paper note should contain:
- claim
- research question / problem
- method
- evidence
- strengths
- limitation
- direct relevance to repo
- links to related papers and the best matching `Knowledge/` notes

## 5. Synthesize the stable literature knowledge

After a batch import, prefer agent-first synthesis into `Knowledge/`:
1. update `Knowledge/Literature Overview.md` when the batch yields a stable overview
2. update `Knowledge/Method Taxonomy.md` when method clusters are clear
3. update `Knowledge/Research Gaps.md` when open problems or tensions are stable enough to keep
4. if the source is a named Zotero collection, update a durable inventory note that records:
   - collection size,
   - triage buckets,
   - collection item -> canonical note mapping,
   - current coverage such as `16 / 16`

Apply the Claim Promotion Gate before creating or updating `Knowledge/`:
- every stable claim must cite a canonical paper note and an Evidence Record ID,
- `speculative` and `observed` claims stay as hypotheses, motivations, or open gaps,
- abstract-only or webpage-placeholder items can appear in coverage notes but not as support for durable conclusions,
- if the batch lacks enough evidence records, produce a warning/claim map instead of a polished synthesis.

## 6. Refresh the default literature canvas

After batch note creation or major note updates:
1. rebuild `Maps/literature.canvas`
2. ensure core paper notes have meaningful wikilinks into `Knowledge/`
3. keep the graph lightweight and project-facing
4. prefer semantic filtering and edge thinning over dense all-to-all paper links
5. prefer `paper + claim + method + gap` argument-map structure for the main graph
6. add `Maps/literature-main.canvas` only when a second lightweight display graph is genuinely useful
7. preserve edge evidence strength where possible; do not create all-to-all paper links or stable-looking claim edges without source-note support

## 7. Push downstream only when justified

- during Zotero ingestion, default to `Sources/Papers/` plus `Knowledge/`
- update `Writing/` only when the user asks for a review, comparison, or draft-facing synthesis and the promoted claims pass the Claim Promotion Gate
- treat `Experiments/` and `Results/` as later project workflows, not default Zotero-import targets

## 8. Verify before closing

After batch ingestion or schema refactors:
1. verify every expected paper has a canonical note
2. verify `zotero_key` coverage matches the imported collection
3. verify all covered notes use the same canonical section schema
4. update the project `Daily/` note and project memory with what changed

Recommended verification command:

```bash
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/zotero-obsidian-bridge/scripts/verify_paper_notes.py" \
  --papers-dir "/absolute/path/to/Sources/Papers" \
  --expected-zotero-keys "KEY1,KEY2,KEY3" \
  --inventory-note "/absolute/path/to/Knowledge/Zotero-Collection-collection-slug-Inventory.md"
```
