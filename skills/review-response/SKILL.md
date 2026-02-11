---
name: review-response
description: Systematic review response workflow from comment analysis to professional rebuttal writing. Use when the user asks to "write rebuttal", "respond to reviewers", "draft review response", or "analyze review comments". Improves paper acceptance rates.
tags: [Research, Academic, Rebuttal, Paper Writing]
version: 0.1.0
---

# Review Response

A systematic review response workflow that helps researchers efficiently and professionally reply to reviewer comments.

## Core Features

1. **Review Analysis** - Parse and classify reviewer comments (Major/Minor/Typo/Misunderstanding)
2. **Response Strategy** - Develop response strategies for different comment types (Accept/Defend/Clarify/Experiment)
3. **Rebuttal Writing** - Write structured, professional rebuttal documents
4. **Tone Management** - Optimize tone to maintain professionalism, respect, and evidence-based arguments

## Workflow

```
Receive reviewer comments -> Parse and classify -> Develop strategy -> Write responses -> Tone check -> Final rebuttal
```

## When to Use

Use this skill when you need to:
- "Help me write a rebuttal"
- "How to respond to reviewer comments"
- "Analyze these review comments"
- "Develop a review response strategy"

## Usage Steps

1. **Provide reviewer comments** - Share the reviewer comments text or file with Claude
2. **Analysis and classification** - Claude automatically parses and classifies the comments
3. **Strategy recommendations** - Receive response strategy suggestions for each comment
4. **Write rebuttal** - Generate a structured rebuttal document based on the strategy
5. **Optimize tone** - Review and optimize the professionalism and politeness of responses

## Core Principles

- **Professionalism** - Maintain an academically professional tone and expression
- **Respectfulness** - Respect the reviewers' opinions and time
- **Evidence-based** - Support every response with sufficient reasoning and evidence
- **Completeness** - Ensure all reviewer comments receive a response

## Success Factors (Based on ICLR Spotlight Paper Analysis)

Key lessons extracted from successful rebuttal cases:

### 1. Acknowledge Strengths, Respond Positively to Criticism
- Reviewers will first acknowledge the paper's strengths (novelty, impact, practical applicability)
- Even spotlight papers receive constructive criticism
- **Strategy**: Thank reviewers for acknowledged strengths first, then address criticism specifically

### 2. Provide Clarity and Intuitive Understanding
- Even high-quality papers may have clarity issues
- Need to provide intuition and detailed explanations for readers with different backgrounds
- **Strategy**: Expand key sections, move technical details to appendix, add step-by-step walkthroughs

### 3. Thorough Justification of Experimental Setup
- Need to justify experimental setup choices
- Consider and discuss alternative metrics
- Provide comprehensive experiments to support claims
- **Strategy**: Add ablation studies, explain why specific experimental setups were chosen

### 4. Emphasis on Ethical Considerations
- For research involving privacy, security, and other sensitive topics, ethical considerations are crucial
- Reviewers pay special attention to ethical implications
- **Strategy**: Proactively discuss ethical considerations, even if reviewers don't explicitly request it

### 5. Highlight Practical Application Value
- Reviewers value practical applicability and scalability of methods
- "Easily applicable" and "scalable" are important strengths
- **Strategy**: Emphasize practical benefits and scalability in the rebuttal

## Reference Documents

For detailed guides, refer to:
- `references/review-classification.md` - Review comment classification criteria
- `references/response-strategies.md` - Response strategy library
- `references/rebuttal-templates.md` - Rebuttal templates and examples
- `references/tone-guidelines.md` - Tone and expression guidelines

## Related Tools

- **Agent**: `rebuttal-writer` - Dedicated agent for rebuttal writing and optimization
- **Command**: `/rebuttal <review_file>` - Quick-start the rebuttal workflow
