---
name: mine-writing-patterns
description: Read one or more papers and update the active installed paper-miner writing memory with reusable writing patterns, structure signals, reusable phrasing, venue-specific signals, and rebuttal-friendly language.
args:
  - name: source
    description: Paper source path, URL, arXiv link, or a short description of the target papers
    required: true
  - name: focus
    description: Optional focus area (general/introduction/method/results/rebuttal/venue)
    required: false
    default: general
tags: [Research, Writing, Paper Mining, Knowledge Extraction]
---

# /mine-writing-patterns - Installed Writing Memory Mining

Read the paper source "$source" and update the active installed **paper-miner writing memory**.

## Default target

Always write mined knowledge into the active installed skill memory, not the repository checkout copy:

```text
~/.claude/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md
```

This command does **not** create project-specific writing memory unless the user explicitly asks for a project-local writing memory.

## When to use

Use this command when you want to:
- learn reusable writing patterns from a strong paper,
- study how a venue frames introductions, methods, results, or rebuttals,
- mine phrasing and structure signals before drafting,
- enrich the writing memory shared by academic writing and response skills.

## Usage

### Basic usage

```bash
/mine-writing-patterns path/to/paper.pdf
```

### Mine from an arXiv paper

```bash
/mine-writing-patterns https://arxiv.org/abs/2301.xxxxx
```

### Focus on rebuttal or venue signals

```bash
/mine-writing-patterns path/to/paper.pdf rebuttal
/mine-writing-patterns path/to/paper.pdf venue
```

## Workflow

### Step 1: Resolve the paper source

Acceptable inputs:
- local PDF
- local DOCX
- arXiv URL
- readable web URL
- short natural-language request that identifies the paper(s)

If the source is ambiguous, narrow it before mining.

### Step 2: Invoke `paper-miner`

Use the `paper-miner` agent to:
- extract paper content,
- identify reusable writing knowledge,
- merge it into the active installed writing memory,
- avoid duplicate entries,
- preserve source attribution.

### Step 3: Respect the focus mode

Interpret `$focus` as follows:

| Focus | Priority |
|------|----------|
| `general` | Mine balanced signals across all major sections |
| `introduction` | Emphasize framing, motivation, and contribution setup |
| `method` | Emphasize exposition style, technical sequencing, and clarity |
| `results` | Emphasize result narration, claim-evidence language, and interpretation |
| `rebuttal` | Emphasize clarification phrases, response structure, and reviewer-facing tone |
| `venue` | Emphasize venue-specific style and convention signals |

### Step 4: Update the canonical memory only

The canonical write target is the active installed skill memory:

```text
~/.claude/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md
```

Update one or more of these sections:
- `Writing patterns mined`
- `Structure signals`
- `Reusable phrasing`
- `Venue-specific signals`
- `How this helps our writing`
- `Source index`

If that file is unavailable in the current runtime, use the configured installed skill home for the active runtime and state the exact path in the final summary. Do not silently fall back to the repository checkout.

Do not create project-local writing memory.
Do not scatter the mined result across multiple maintained knowledge files.

### Step 5: Return a standardized mining summary

The final response should follow the `paper-miner` standardized output format:
- metadata
- memory write summary
- new reusable patterns
- how we should reuse this
- blockers or limits

## Related integrations

- Academic writing and response skills read relevant entries from this active installed memory when structure, phrasing, or venue style matters.
- `paper-miner` is the agent that performs the actual mining work.

## Success criteria

- the target paper is read successfully,
- reusable writing knowledge is merged into the canonical memory,
- source attribution is preserved,
- no project-specific writing memory is created,
- the user receives a standardized mining summary.
