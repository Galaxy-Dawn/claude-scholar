---
name: ui-ux-pro-max
description: This skill should be used when the user asks to design or review a UI, create a landing page or dashboard, choose colors or typography, improve accessibility, or implement polished frontend interfaces with a clear design system.
version: 0.2.0
---

# UI/UX Pro Max

Use this skill to turn a vague UI request into a **concrete design system plus implementation guidance**.

## Role

This skill is for:
- design-system selection,
- palette and typography choices,
- UX review and remediation,
- stack-aware frontend implementation guidance,
- lightweight design-system persistence for multi-page work.

It is **not** a replacement for product strategy or user research. Use it to make execution sharper after the product direction is already roughly known.

## Core workflow

### 1. Infer the request shape

Extract the minimum design signals first:
- product type,
- industry,
- style keywords,
- target platform,
- implementation stack.

If the user does not specify a stack, default to `html-tailwind`.

### 2. Generate the design system first

Use the helper script to produce a compact design recommendation:

```bash
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "<product_type> <industry> <keywords>" --design-system -p "Project Name"
```

This produces:
- recommended style direction,
- palette family,
- typography direction,
- interaction / visual effects,
- landing or layout bias,
- anti-patterns to avoid.

If the work spans multiple turns or pages, persist the design system:

```bash
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "<query>" --design-system --persist -p "Project Name"
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "<query>" --design-system --persist -p "Project Name" --page "dashboard"
```

This creates:
- `design-system/MASTER.md`
- optional page-level override notes under `design-system/pages/`

### 3. Pull targeted guidance only when needed

Use a focused search instead of loading everything at once:

```bash
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "glassmorphism dark" --domain style
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "animation accessibility" --domain ux
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "real-time dashboard" --domain chart
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "elegant luxury serif" --domain typography
```

Supported domains:
- `product`
- `style`
- `color`
- `typography`
- `landing`
- `chart`
- `ux`

### 4. Add stack-specific guidance before coding

```bash
python3 "${KIMI_HOME:-$HOME/.kimi-code}/skills/ui-ux-pro-max/scripts/search.py" "forms table responsive" --stack html-tailwind
```

Supported stacks:
- `html-tailwind`
- `react`
- `nextjs`
- `vue`
- `svelte`
- `swiftui`
- `react-native`
- `flutter`
- `shadcn`
- `jetpack-compose`

### 5. Synthesize before implementation

After gathering the design system, convert it into:
- layout structure,
- component rules,
- visual tokens,
- interaction rules,
- accessibility constraints,
- implementation notes for the chosen stack.

Do not dump raw search output into the final answer. Use it to justify a coherent design direction.

## Default output shape

A good response should usually include:
1. product and UI framing,
2. recommended style system,
3. palette and typography,
4. component and layout rules,
5. accessibility and interaction checks,
6. stack-aware implementation notes.

## Safety rules

- Do not hardcode a design language without connecting it to the product type.
- Do not use emoji as primary UI iconography.
- Do not weaken text contrast for visual flair.
- Do not scale interactive cards on hover if it destabilizes layout.
- Do not use animation that violates `prefers-reduced-motion`.
- Do not invent unsupported helper scripts or datasets; use the bundled `search.py` and `data/ui-reasoning.csv` only.

## References

Load only what is needed:
- `references/USAGE.md` - recommended command patterns and retrieval flow
- `data/ui-reasoning.csv` - compact product-to-design heuristics used by the helper script
- `scripts/search.py` - deterministic helper for design-system, domain, and stack lookup
