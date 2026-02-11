---
name: research-init
description: Initialize a research project by conducting literature review and generating research proposal
args:
  - name: topic
    description: Research topic or keywords
    required: true
  - name: scope
    description: Review scope (focused/broad)
    required: false
    default: focused
  - name: output_type
    description: Output type (review/proposal/both)
    required: false
    default: both
---

```bash
#!/bin/bash

# Parse arguments
TOPIC="$1"
SCOPE="${2:-focused}"
OUTPUT_TYPE="${3:-both}"

# Validate topic
if [ -z "$TOPIC" ]; then
    echo "Error: Topic is required"
    echo "Usage: /research-init <topic> [scope] [output_type]"
    exit 1
fi

# Create output message
echo "Starting research initiation for topic: $TOPIC"
echo "Scope: $SCOPE"
echo "Output type: $OUTPUT_TYPE"
echo ""
echo "Invoking literature-reviewer agent..."

# The agent will be invoked by Claude Code automatically
# This command serves as a trigger and parameter passing mechanism
```

**Usage Examples:**

```bash
# Basic usage
/research-init "transformer interpretability"

# With scope
/research-init "few-shot learning" focused

# With all parameters
/research-init "neural architecture search" broad both
```

**What this command does:**

1. Validates the research topic parameter
2. Sets default values for optional parameters
3. Triggers the literature-reviewer agent
4. The agent will:
   - Search for relevant papers
   - Analyze and synthesize findings
   - Generate literature review and/or research proposal
   - Create BibTeX references

**Output files:**
- `literature-review.md` - Comprehensive literature review
- `research-proposal.md` - Research proposal (if requested)
- `references.bib` - BibTeX references

