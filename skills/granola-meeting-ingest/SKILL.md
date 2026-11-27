---
name: granola-meeting-ingest
description: Import one user-selected Granola note or transcript into the research project's bound Obsidian vault. Use for a meeting, interview, or talk already transcribed in Granola.
---

# Granola Meeting Ingest

Use this skill when the user selects a Granola note or provides a Granola
export and asks to save it in the current project's Obsidian knowledge base.
For a transcript or a video link supplied without a Granola note or export,
use [Obsidian Source Ingestion](../obsidian-source-ingestion/SKILL.md).

1. From the research repo, run this skill's `scripts/ingest_granola.py` with
   Python and the flags `--cwd . --show-target`. Identify the vault by its
   folder path and the project by its folder inside that vault. Match them to the user's intended project
   before fetching the meeting. Use their existing vault. If the binding is
   missing, ambiguous, or points elsewhere, ask which vault and project to
   use. If the binding points to a known test vault, use it only when the
   user chose that test destination.
   When Obsidian Desktop is available, check that the exact vault folder is
   registered using the vault switcher or `obsidian vaults verbose`. If it is
   missing, open the confirmed folder as a vault or give its exact location.
2. Read the selected meeting using the configured Granola MCP tools or a local
   export supplied by the user. Choose a short title from the content. For a talk, summarize the
   speaker's main points. Record decisions and actions only when the source provides them.
   If transcript access is unavailable, briefly summarize the accessible notes with
   `source_kind: notes` and include quotations or speaker attribution only when verified.
3. Pass `--project-id` and `--expect-vault` for the selected destination to
   this skill's `scripts/ingest_granola.py --input -` to write the Markdown note
   under the bound project's `Sources/Interviews/Granola-<YY-MM-DD>-<topic>.md`.
   The helper records the meeting UUID in the note properties, registers the
   source and refreshes the project index. It reuses a note with the same UUID
   and adds a numeric suffix when a different meeting needs the same filename.
4. Give the user the vault folder, the returned `vault_note` path and the
   `obsidian_uri` link. Verify the saved file and its index entry for an active
   note. For a request to open or verify it in Desktop, follow the link and
   check the displayed note and vault. Report what you verified. If Desktop
   is unavailable, report the local save and explain how to open the folder.

Follow the [meeting workflow and note format](references/GRANOLA-MEETING-NOTES.md)
for the connector call, input data, and directory conventions.
