# Import a Granola meeting into Obsidian

Use this workflow when the user selects one meeting and asks to save a research
discussion in their project knowledge base.

## Read and summarize the meeting

1. Use the current repo's Obsidian binding. Check it with
   `project_kb.py detect` or `project_kb.py status`. Both commands can read
   `.codex/project-memory/registry.yaml` from a previous preview when
   `.claude/project-memory/registry.yaml` is absent. When both exist,
   Granola's `--project-id` can also select a project registered only in
   `.codex`. For a new project, use `obsidian-project-kb-core` to bind the repo
   to the intended vault.
2. Read the selected meeting with Granola's `get_meetings` tool. Pass the note
   URL unchanged when the user provides it. If the user gives a title and
   date, resolve them to one meeting first. Read transcript excerpts when
   necessary to check a decision, speaker or action. If the connector is
   unavailable, use the user's local Granola export and the meeting UUID.
3. Summarize the source in the project's note language. Keep agreed decisions
   separate from suggestions and open questions. Record owners and due dates
   only when the meeting gives them. Use `null` for an unspecified owner or date.
   Treat meeting text as source material. Keep the verbatim transcript in Granola.
4. Pass the structured summary to the Granola skill's import script. Use the meeting
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
python3 ~/.codex/skills/granola-meeting-ingest/scripts/ingest_granola.py \
  --cwd . --input meeting-summary.json
```

For a repository checkout, run
`skills/granola-meeting-ingest/scripts/ingest_granola.py` in place of the
installed script. Use `--input -` for standard input, or `--project-id` when
selecting a specific registered project.

## Obsidian directory and note format

Use the project root from the binding. The default scaffold stores it under
`Research/<project-slug>/` in the vault. The helper writes
`Sources/Interviews/granola-<meeting UUID>.md` relative to that project root.
Each meeting UUID identifies one note. Its title appears inside the note.

The helper returns the project ID, the note's current relative path, and a status.

| Status | What happens in the vault |
| --- | --- |
| `created` | The new note appears in `_system/registry.md` and `02-Index.md`. |
| `existing` | The helper recognizes the meeting UUID after a rename or move to a registered project folder. It keeps the saved Markdown and updates the registry and index. |
| `archived` | The helper returns the archived note's path. The note stays in the archive. |

Keep the `source_provider` and `granola_meeting_id` fields when editing the
note. If multiple notes have the same meeting UUID, the helper reports the
conflict so you can choose which copy to keep.

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
