---
name: granola-meeting-ingest
description: Import one user-selected Granola note or transcript into the research project's bound Obsidian vault. Use for a meeting, interview, or talk already transcribed in Granola.
---

# Granola Meeting Ingest

Use this skill when the user selects a Granola note or provides a Granola
export and asks to save it in the current project's Obsidian knowledge base.
For a transcript or a video link supplied without a Granola note or export,
use [Obsidian Source Ingestion](../obsidian-source-ingestion/SKILL.md).

1. Confirm the target project and its Obsidian binding.
2. Read the selected meeting through the user's Granola connector or local
   export. Choose a short title from the content. For a talk, summarize the
   speaker's main points. Record decisions and actions only when the source provides them.
3. Run this skill's `scripts/ingest_granola.py` to write the Markdown note
   under `Sources/Interviews/Granola-<YY-MM-DD>-<topic>-<meeting UUID>.md`
   and refresh the project index. This step also registers the source.
4. Return the note path and import status so the user can open it.

Follow the [meeting workflow and note format](references/GRANOLA-MEETING-NOTES.md)
for the connector call, input data, and directory conventions.
