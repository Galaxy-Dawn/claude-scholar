---
name: obsidian-source-ingestion
description: Ingest external materials, including selected Granola meeting notes, into the current project-scoped Obsidian KB under Sources/Papers, Sources/Web, Sources/Docs, Sources/Data, Sources/Interviews, or Sources/Notes.
---

# Obsidian Source Ingestion

Use this skill when external material should become a project-local source note.

## Targets

- `Sources/Papers/`
- `Sources/Web/`
- `Sources/Docs/`
- `Sources/Data/`
- `Sources/Interviews/`
- `Sources/Notes/`

## Core rules

- source notes are source-centered, not synthesis-centered
- every new canonical source note must update `_system/registry.md`
- important sources should update `02-Index.md`
- if the source arrived during an active work session, append a short note to today's `Daily/`
- do not create a top-level `Papers/`

## Granola meetings

For a selected meeting, use the existing Granola connector or a local export
provided by the user. Follow [Granola meeting ingestion](references/GRANOLA-MEETING-NOTES.md)
to create a source note with decisions, actions and open questions in the bound
project. Use the Granola meeting UUID to find an existing import.

## Read next

- `references/SOURCE-TYPES.md`
- `references/PAPER-SOURCE-NOTES.md`
- `references/WEB-SOURCE-NOTES.md`
- `references/DATA-SOURCE-NOTES.md`
- `references/INTERVIEW-SOURCE-NOTES.md`
