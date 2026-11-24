# Academic Writing Knowledge Base

This knowledge base contains reusable academic writing knowledge mined from papers.

## Canonical maintained memory

The canonical paper-miner memory is:

- `paper-miner-writing-memory.md`

This is the **only maintained paper-miner writing memory per project install**.
Academic writing skills in that project may read relevant entries from it.

It stores:
- writing patterns mined,
- structure signals,
- reusable phrasing,
- venue-specific signals,
- how those signals help future writing,
- and a source index.

## Maintenance rule

`paper-miner` always writes mined writing knowledge into `paper-miner-writing-memory.md`.

This memory is:
- stored under the project's installed `ml-paper-writing` skill,
- shared by writing skills in that project, not by other projects automatically.

The installer must preserve this file across updates, and the uninstaller must
leave it in place. It contains user-mined data, even though the repository also
ships a starter template at the same relative path.
When updating by hand with `cp -r`, back up this file first and restore it
after the copy. The installer's preservation rule does not apply to manual copies.

`paper-miner` may use project context to understand relevance. It writes only to the project's installed skill memory, not a separate file at the project root or in a global directory.

## Legacy files

Older files such as:
- `structure.md`
- `writing-techniques.md`
- `submission-guides.md`
- `review-response.md`

may still exist as historical material, but new paper-miner updates should treat `paper-miner-writing-memory.md` as the canonical maintained memory.

## Usage

Use this knowledge base when:
- drafting papers,
- improving section structure,
- borrowing reusable phrasing patterns,
- preparing rebuttals,
- studying venue-facing writing signals.

## Contributing

When `paper-miner` analyzes a new paper:
1. extract actionable writing knowledge,
2. merge it into `paper-miner-writing-memory.md`,
3. preserve source attribution,
4. avoid duplicate patterns,
5. keep the memory compact and reusable.
