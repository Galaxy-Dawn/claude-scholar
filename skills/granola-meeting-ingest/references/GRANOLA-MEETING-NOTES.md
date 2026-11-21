# Import a Granola meeting into Obsidian

Use this workflow when the user selects a Granola note from a meeting,
interview, or talk and asks to save it in their project knowledge base.
The project's [source types](../../obsidian-source-ingestion/references/SOURCE-TYPES.md)
route interviews and transcripts to `Sources/Interviews/`. The Granola importer
registers that note once. Other interviews and web sources use the existing
source ingestion workflow.

## Read and summarize the meeting

1. Use the current repo's Obsidian binding. Check it with
   `project_kb.py detect` or `project_kb.py status`. Both commands can read
   `.codex/project-memory/registry.yaml` from a previous preview when
   `.claude/project-memory/registry.yaml` is absent. When both exist,
   Granola's `--project-id` can also select a project registered only in
   `.codex`. For a new project, use `obsidian-project-kb-core` to bind the repo
   to the intended vault.
2. Identify exactly one source using the entry point that matches the request.

   - **Note link.** Pass the supplied Granola `/d/` or `/t/` URL unchanged to
     `get_meetings`. Use the meeting UUID returned for that note.
   - **Title and date.** Use `search_meetings` with the title keywords and
     `from_date` and `to_date` for the requested day in the user's time zone.
     Check the candidates against the title, date and any other details the
     user supplied. Follow `next_cursor` while more candidates are available.
     Once the match is unique, read it with `get_meetings`.
     If several candidates remain, ask the user to choose or supply its link.
   - **Local export.** From a Granola CSV, select one row by title and date.
     For copied Markdown, use the selected note and its accompanying link.
     Convert the selected content to the summary JSON below. Use only a
     meeting UUID explicitly recorded in the export, confirmed by the user,
     or returned after resolving the note link in the connector. If the UUID
     is unavailable, obtain it before importing. A title, date, or opaque
     share ID cannot identify the meeting UUID.
     [Granola CSV export](https://docs.granola.ai/help-center/sharing/exporting-notes)
     [Granola Markdown copy and links](https://docs.granola.ai/help-center/sharing/sharing-notes)

3. Prepare a short source summary in the project's note language. Use the
   actual meeting date when available. For a lecture, capture the speaker's
   main points and examples. Use accessible transcript excerpts to verify
   wording, speaker or decisions when needed. If only the notes are
   accessible, set `source_kind` to `notes` and summarize those notes.
   Record exact quotations and speaker attribution only when the source
   supports them. Put agreed decisions in the summary. Keep outstanding
   actions and open questions under follow-ups, with owners and dates when known.

## Import the summary

```json
{
  "meeting_id": "a5c6d001-fd66-4e9c-b002-010203040506",
  "title": "Lab meeting - baseline experiment",
  "meeting_date": "2026-11-21",
  "source_kind": "notes-and-transcript",
  "participants": ["Researcher A", "Researcher B"],
  "summary": ["The baseline experiment needs the same evaluation split as the proposed method."],
  "decisions": ["Use the existing evaluation split for the baseline."],
  "action_items": [
    {"task": "Prepare the baseline configuration", "owner": "Researcher A", "due_date": null}
  ],
  "open_questions": ["How many seeds should the main table report?"]
}
```

`meeting_id`, `title`, `source_kind` and at least one `summary` item are
required. Use `notes`, `transcript` or `notes-and-transcript` to record what was
read. Add `source_url` if a `https://notes.granola.ai/d/…` or `/t/…` note link
is available. URL query parameters and fragments are omitted from the vault.
Use `YYYY-MM-DD` for dates. The example uses fictitious data. The existing
summary fields still work. Each optional section field accepts an array of non-empty
strings. Include each field only when you have evidence for it.

- `project_relevance` connects the source to a known project question or task.
- `context` describes the setting or background established by the source.
- `key_quotes` holds brief, verified excerpts. Name the speaker when the source
  confirms who spoke.
- `observed_needs` records needs expressed or directly observed in the source.

```bash
python3 ~/.codex/skills/granola-meeting-ingest/scripts/ingest_granola.py \
  --cwd . --input -
```

Pass one UTF-8 summary JSON object on standard input. If using a file, keep
it outside the repository and pass its path to `--input`. For a checkout,
use `skills/granola-meeting-ingest/scripts/ingest_granola.py` in place of the
installed script. Use `--project-id` when selecting a specific registered
project. The helper returns UTF-8 JSON, including non-ASCII note paths.

## Obsidian directory and note format

Use the project root from the binding. The default scaffold stores it under
`Research/<project-slug>/` in the vault. New notes use
`Sources/Interviews/Granola-<YY-MM-DD>-<topic>-<meeting UUID>.md`. The JSON
example above produces `Granola-26-11-21-Lab-meeting-baseline-experiment-a5c6d001-fd66-4e9c-b002-010203040506.md`.

The filename uses the meeting date (`undated` when unknown) and the full
Granola UUID. Spaces and punctuation in the title become hyphens. The topic
keeps up to 96 UTF-8 bytes and falls back to `note` when empty. The full title
remains in the note. Re-imports look up the UUID in the note's metadata. This
preserves the path and edits of existing notes, including older
`granola-<meeting UUID>.md` files. A hand-written interview without the Granola
UUID is a separate source, even when the titles match.

The helper returns the project ID, the note's current relative path, and a status.

| Status | What happens in the vault |
| --- | --- |
| `created` | The new note appears in `_system/registry.md` and `02-Index.md`. |
| `existing` | The helper recognizes the meeting UUID after a rename or move to a registered project folder. It keeps the saved Markdown and updates the registry and index. |
| `archived` | The helper returns the archived note's path. The note stays in the archive. |

Keep the `source_provider` and `granola_meeting_id` fields when editing the
note. If multiple notes have the same meeting UUID, the helper reports the
conflict so you can choose which copy to keep.

New notes use the [source interview template](../../../templates/notes/source-interview.md).
The example below uses an illustrative import time. The helper sets
`created` and `updated` when it creates the note. The project's note language
controls the section headings.

```markdown
---
type: source
source_type: interview
project: "guide-example"
status: active
created: 2026-11-21T10:00:00Z
updated: 2026-11-21T10:00:00Z
source_provider: granola
granola_meeting_id: a5c6d001-fd66-4e9c-b002-010203040506
source_kind: notes-and-transcript
title: "Lab meeting - baseline experiment"
meeting_date: 2026-11-21
---

# Lab meeting - baseline experiment

## Metadata

- Source: Granola
- Material reviewed: Notes and transcript
- Meeting date: 2026-11-21

## Project Relevance

- None recorded

## Summary

- The baseline experiment needs the same evaluation split as the proposed method.
- **Decision** Use the existing evaluation split for the baseline.

## Participants

- Researcher A
- Researcher B

## Context

- None recorded

## Key Quotes

- None recorded

## Observed Needs

- None recorded

## Follow-ups

### Action items

- [ ] Prepare the baseline configuration (Researcher A, Due date unspecified)

### Open questions

- How many seeds should the main table report?
```

When the input includes a source URL, the helper records it in the note
properties and links the source under **Metadata**. Empty sections use the
project's equivalent of “None recorded.”

A meeting note is a project source. Use the normal evidence workflow when a
claim from a discussion is needed in a paper or a durable knowledge note.
