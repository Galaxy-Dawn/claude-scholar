# CLI

Use the Obsidian CLI only as an optional helper for navigation, search, verification, or lightweight note actions. The filesystem remains the source of truth.

## Common uses

```bash
obsidian help
obsidian search query="diffusion" limit=10
obsidian read file="My Note"
obsidian daily:append content="- [ ] Follow up"
```

## Good uses in Kimi Scholar

- open a note after updating it
- search a vault for a known keyword
- append a short daily action item
- verify that CLI targeting works for a specific vault

## Do not rely on CLI for

- canonical registry truth
- project binding state
- lifecycle decisions
- sync logic that must work without Obsidian running

## Fallback rule

If CLI is unavailable or the Obsidian app toggle is off, continue with filesystem-only KB maintenance.
