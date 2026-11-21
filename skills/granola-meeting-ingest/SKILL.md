---
name: granola-meeting-ingest
description: Review one user-selected Granola meeting and organize the discussion, decisions, and actions in the research project's bound Obsidian vault.
---

# Granola Meeting Ingest

Use this skill when the user selects a Granola meeting and asks to save the
discussion in the current project's Obsidian knowledge base.

1. Confirm the target project and its Obsidian binding.
2. Read the selected meeting through the user's Granola connector or local
   export. Keep decisions, action items, and open questions distinct.
3. Run this skill's `scripts/ingest_granola.py` to write the Markdown note
   under `Sources/Interviews/granola-<meeting UUID>.md` and refresh the project index.
4. Return the note path and import status so the user can open it.

Follow the [meeting workflow and note format](references/GRANOLA-MEETING-NOTES.md)
for the connector call, input data, and directory conventions.
