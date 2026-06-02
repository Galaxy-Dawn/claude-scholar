# Exemplary Skill Examples

Use these examples when reviewing or improving Kimi-installed skills.

## Example 1: research-ideation

Strong research skills make their evidence rules explicit.

Good traits:
- frontmatter names concrete trigger phrases such as "brainstorm research ideas" and "identify research gaps"
- SKILL.md defines the default research contract before giving optional methods
- references contain reusable templates instead of long ad hoc prose
- outputs separate claims, evidence, assumptions, and next decisions

## Example 2: obsidian-project-kb-core

Strong workflow skills define ownership boundaries.

Good traits:
- states the exact project-scoped KB root
- names durable destinations such as `Sources/`, `Knowledge/`, `Results/Reports/`, `Writing/`, and `Daily/`
- tells the agent when not to create new notes
- ships deterministic scripts for registry, sync, lint, and lifecycle actions

## Example 3: ui-ux-pro-max

Strong implementation-support skills expose helper scripts without loading all guidance by default.

Good traits:
- SKILL.md gives a compact workflow
- script examples use `${KIMI_HOME:-$HOME/.kimi}` for Kimi installs
- detailed design guidance is searched on demand
- verification asks for concrete screenshots or interaction checks when relevant

## Study These Skills

```bash
cat ~/.kimi/skills/research-ideation/SKILL.md
cat ~/.kimi/skills/obsidian-project-kb-core/SKILL.md
python3 ~/.kimi/skills/ui-ux-pro-max/scripts/search.py "dashboard accessibility" --domain ux
```

Use these as templates when creating or improving Kimi-native skills.
