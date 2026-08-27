---
name: promote
description: Draft research promotion content and optionally publish approved X posts
---

# Generate Promotion Content

Use the `post-acceptance` skill to prepare accurate promotion content for an
accepted paper.

## Workflow

1. Ask for the paper, acceptance venue, public links, key result, and target
   platforms.
2. Separate claims supported by the paper from broader promotional language.
3. Draft platform-specific content for X, LinkedIn, blogs, or news pages.
4. Check names, links, numbers, image rights, and accessibility text.
5. Return editable drafts before offering any publishing step.

## Optional Xquik workflow

Use Xquik only when the user asks for live X context, draft analysis, or
publishing. Load `references/xquik-promotion.md` from the `post-acceptance`
skill before using it.

- Keep public searches bounded by query, dates, and result count.
- Treat posts as public context, not scholarly evidence.
- Draft locally when Xquik MCP is unavailable.
- Show the complete account, text, links, media, and public effect before a
  write.
- Publish only after explicit approval for that exact payload.
- Never retry a write automatically.

## Delivery

Return each draft under its target platform. Include a short fact-check list
and any unresolved placeholders. If an approved X post succeeds, return its
action status and public URL when available.
