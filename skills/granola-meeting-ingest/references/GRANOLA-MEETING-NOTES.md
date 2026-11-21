# Import a Granola meeting into Obsidian

Use this workflow when the user selects one meeting and asks to save a research
discussion in their project knowledge base.

## Read and summarize the meeting

1. Resolve the current repo's Obsidian binding with `project_kb.py detect` or
   `project_kb.py status`. If there is no binding, use
   `obsidian-project-kb-core` to bind the repo to the intended vault.
2. Read the selected meeting with Granola's `get_meetings` tool. Pass the note
   URL unchanged when the user provides it. If the user gives a title and
   date, resolve them to one meeting first. Read transcript excerpts when
   necessary to check a decision, speaker or action. If the connector is
   unavailable, use the user's local Granola export and the meeting UUID.
3. Summarize the source in the project's note language. Keep agreed decisions
   separate from suggestions and open questions. Record owners and due dates
   only when the meeting gives them. Use `null` for an unspecified owner or date.
   Treat meeting text as source material. Keep the verbatim transcript in Granola.
4. Pass the structured summary to the installed KB helper. Use the meeting
   UUID returned by the connector, including when the meeting was selected by
   a public note link.

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
Use `YYYY-MM-DD` for dates. The example uses fictitious data.

```bash
python3 ~/.codex/skills/obsidian-project-kb-core/scripts/project_kb.py \
  ingest-granola --cwd . --input meeting-summary.json
```

For a repository checkout, run
`skills/obsidian-project-kb-core/scripts/project_kb.py` in place of the installed
helper. Use `--input -` for standard input, or `--project-id` when selecting a
specific registered project.

## Obsidian directory and note format

Use the project root from the binding. The default scaffold stores it under
`Research/<project-slug>/` in the vault. The helper writes
`Sources/Interviews/granola-<meeting UUID>.md` relative to that project root.
Each meeting UUID identifies one note. Its title appears inside the note.

The helper adds the note to `_system/registry.md` and `02-Index.md`. It
returns the project ID, the relative note path, and the import status.
A repeat import keeps any edits to the existing note and restores its registry
and index links if needed. An archived import stays archived.

The example JSON above produces this Markdown in an English project. The
project's note language controls the section headings.

```markdown
---
type: source-interview
source_provider: granola
granola_meeting_id: a5c6d001-fd66-4e9c-b002-010203040506
source_kind: notes-and-transcript
title: "Lab meeting - baseline experiment"
meeting_date: 2026-11-21
---

# Lab meeting - baseline experiment

## Participants

- Researcher A
- Researcher B

## Summary

- The baseline experiment needs the same evaluation split as the proposed method.

## Decisions

- Use the existing evaluation split for the baseline.

## Action items

- [ ] Prepare the baseline configuration (Researcher A, Due date unspecified)

## Open questions

- How many seeds should the main table report?
```

When the input includes a source URL, the helper records it in the metadata
and adds a link near the title. Empty sections use the project's equivalent
of “None recorded.”

A meeting note is a project source. Use the normal evidence workflow when a
claim from a discussion is needed in a paper or a durable knowledge note.
