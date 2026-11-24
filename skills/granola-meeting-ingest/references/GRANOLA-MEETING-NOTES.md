# Import a Granola meeting into Obsidian

Use this workflow when the user selects a Granola note from a meeting,
interview, or talk and asks to save it in their project knowledge base.
The project's [source types](../../obsidian-source-ingestion/references/SOURCE-TYPES.md)
route interviews and transcripts to `Sources/Interviews/`. The Granola importer
registers that note once. Other interviews and web sources use the existing
source ingestion workflow.

## Configure the source

Use a local Granola export, or configure the Granola MCP server in your active
OpenCode configuration. With OpenCode V1, add a `granola` entry under your
existing `mcp` object. If you installed Scholar into `~/.opencode`, point
`OPENCODE_CONFIG_DIR` at that directory when launching OpenCode unless it
is already your active config directory.

```json
{
  "mcp": {
    "granola": {
      "type": "remote",
      "url": "https://mcp.granola.ai/mcp"
    }
  }
}
```

Run `opencode mcp auth granola` with the same config and sign in to Granola.
For OpenCode V2, run `opencode mcp add granola --url https://mcp.granola.ai/mcp`
from your project, then authenticate. The
[OpenCode MCP guide](https://opencode.ai/docs/mcp-servers/) documents V2's
`mcp.servers` layout. If you did not connect it, provide a local export and
a verified meeting UUID instead.
[Granola MCP endpoint](https://docs.granola.ai/help-center/sharing/integrations/mcp)

## Read and summarize the meeting

1. **Resolve the destination before reading a meeting.** From the research
   repo, run the helper with `--cwd . --show-target`. This read-only command
   returns the vault folder (`vault_path`), project ID and vault-relative
   project folder. An unambiguous binding to the intended project can be
   reused immediately. If several projects match, show their locations using
   `--project-id <id> --show-target` and ask which to use. If a binding is
   missing, stale or conflicts with the user's chosen destination, get the
   intended vault and project before writing. Use the existing Obsidian
   project setup for a new binding. If a previous test left a demo vault
   bound to the repo, confirm that destination or bind the intended vault.

   If Desktop is available, compare the **full vault folder path** with the
   vault switcher's registered locations or the output of `obsidian vaults verbose`.
   Identically named vaults can have different paths. If the intended folder
   is missing from that list, use **Manage vaults → Open folder as vault** on
   the confirmed `vault_path`. Select the folder that contains `Research/`.
   If Desktop is unavailable, use an explicitly identified or already known
   destination and give the same folder-opening instructions with the result.
   [Manage vaults](https://obsidian.md/help/Files%20and%20folders/Manage%20vaults)

   OpenCode reads `.opencode/project-memory/registry.yaml` and existing
   bindings in `.claude/project-memory/registry.yaml`. If both contain the
   same project ID, the OpenCode entry takes precedence. Use `--project-id`
   to choose between distinct matching projects and confirm the full vault path.
2. Identify exactly one source using the entry point that matches the request.
   Use the equivalent search, listing and reading tools available in the current
   client. When the client cannot read the note, use the local export path.
   [Granola MCP tool list](https://docs.granola.ai/help-center/sharing/integrations/mcp)

   - **Note link.** Pass the supplied Granola `/d/` or `/t/` URL unchanged to
     a reader that accepts note links, such as `get_meetings`. If it requires
     an ID, use a verified meeting UUID from discovery results or the user.
   - **Title and date.** Search the title and the requested day in the user's
     time zone. For example, use `keywords`, `from_date` and `to_date` with
     `search_meetings`. If search is unavailable, use `list_meetings` or the
     client's list tool and check the same details in its results. Check candidates
     against the other details the user supplied. Follow continuation cursors
     such as `next_cursor` to confirm one match before reading the note. When
     several meetings match, show their titles and times and ask the user to
     choose one. If results remain incomplete, narrow the date or use another known filter
     and search again. If that search is still incomplete or cannot confirm one
     source, ask for its link or verified UUID.
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
   meeting UUID verified in step 2 and the meeting date when available.
   For a lecture, capture the speaker's
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
python3 "${OPENCODE_CONFIG_DIR:-$HOME/.opencode}/skills/granola-meeting-ingest/scripts/ingest_granola.py" \
  --cwd . --project-id "guide-example" --expect-vault "/path/to/the/selected/vault" --input -
```

Pass one UTF-8 summary JSON object on standard input. If using a file, keep
it outside the repository and pass its path to `--input`. The command uses
the OpenCode V1 global install. With a project-scoped install, run
`.opencode/skills/granola-meeting-ingest/scripts/ingest_granola.py` with
Python from the project root. In a custom install or checkout, locate the
script next to the loaded skill under `scripts/`. Substitute the selected project ID and vault folder in the
command. A vault-path mismatch stops the import before writing. The helper
returns UTF-8 JSON, including non-ASCII note paths.

## Obsidian directory and note format

Use the project root from the binding. The default scaffold stores each project
under `Research/<project-slug>/` in the vault. The importer appends
`Sources/Interviews/Granola-<YY-MM-DD>-<topic>.md` to that project's root.
The JSON example above produces `Granola-26-11-21-Lab-meeting-baseline-experiment.md`.

The filename uses the meeting date (`undated` when unknown) and a short topic.
Spaces and punctuation become hyphens. The topic keeps up to 96 UTF-8 bytes
and falls back to `note` when empty. The full title and meeting UUID stay in
the note properties. If another note already has the desired filename, the new
note takes the first available suffix (`-2.md`, `-3.md`, and so on).

Re-imports find the saved `granola_meeting_id` even if the title or filename
has changed. Older names such as `granola-<meeting UUID>.md` and
`Granola-<YY-MM-DD>-<topic>-<meeting UUID>.md` still resolve to the original
note. To shorten an existing name and update its project links, use
`project_kb.py note-lifecycle --mode rename --note <old-path> --dest <new-path>`
with project-relative paths and an available destination name.

For delivery, give the vault folder (`vault_path`), the complete path inside it
(`vault_note`, including the project), and the local `obsidian_uri` returned
by the helper. The `note` field is relative to the project for existing
scripts. The link uses the absolute file path so two vaults with the same name
can be distinguished on this device. Opening the link requires the vault to
be registered in Desktop. A successful write establishes that the file is on
disk. To confirm it is visible, open the link and verify the note's title and
path in the app. [Obsidian URI](https://obsidian.md/help/uri)

| Status | What happens in the vault |
| --- | --- |
| `created` | The new note appears in `_system/registry.md` and `02-Index.md`. |
| `existing` | The helper recognizes the meeting UUID after a rename or move to a registered project folder. It keeps the saved Markdown and updates the registry and index. |
| `archived` | The helper returns the archived note's path. The note stays in the archive. |

Keep the `source_provider` and `granola_meeting_id` fields when editing the
note. The importer reads saved Markdown with or without a UTF-8 BOM. The
registry stores the meeting UUID in a hidden row comment. After a manual
rename, re-import directly to keep the source ID and refresh the index link.
If the new path is registered to a different meeting, re-import that meeting
at its current path first. A new import skips filenames still used in the
registry.

For a legacy registry entry that has no UUID comment, re-import can recover
the ID from its current path or an old filename containing the UUID. If the old
path cannot be confirmed automatically, add `--previous-note Sources/Interviews/<old-name>.md`
to the import command. Use the exact old path of that meeting's missing file.

If multiple notes have the same meeting UUID, the helper reports the
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
