---
name: skill-quality-reviewer
description: This skill should be used when the user asks to "analyze skill quality", "evaluate this skill", "review skill quality", "check my skill", or "generate quality report". Evaluates local skills across description quality, content organization, writing style, and structural integrity.
version: 0.1.0
---

# Skill Quality Reviewer

## Overview

A meta-skill for evaluating the quality of Claude Skills. Perform comprehensive analysis across four key dimensions—description quality (25%), content organization (30%), writing style (20%), and structural integrity (25%)—to generate weighted scores, letter grades, and actionable improvement plans.

Use this skill to validate skills before sharing, identify improvement opportunities, or ensure compliance with skill development best practices.

## When to Use This Skill

**Invoke this skill when:**
- Analyzing a skill's quality before distribution
- Reviewing skill documentation for best practices
- Evaluating adherence to skill development standards
- Generating improvement recommendations for existing skills
- Validating skill structure and completeness

**Trigger phrases:**
- "Analyze skill quality for ./my-skill"
- "Evaluate this skill: ~/.claude/skills/api-helper"
- "Review skill quality of git-workflow"
- "Check my skill for best practices"
- "Generate quality report for this skill"

## Analysis Workflow

### Step 1: Load the Skill

Accept skill path as input. Verify the path exists and contains `SKILL.md`. Read the complete skill directory structure.

```bash
# Example invocation
ls -la ~/.claude/skills/target-skill/
```

**Validate:**
- SKILL.md exists
- Directory is readable
- Path points to a valid skill

### Step 2: Parse YAML Frontmatter

Extract and validate the YAML frontmatter from SKILL.md.

**Required fields:**
- `name` - Skill identifier
- `description` - Trigger description with phrases

**Check for:**
- Valid YAML syntax
- No prohibited fields
- Proper formatting

### Step 3: Evaluate Description Quality (25%)

Assess the quality and effectiveness of the frontmatter description.

**Scoring breakdown:**

| Criterion | Points | Evaluation |
|-----------|--------|------------|
| Trigger phrases clarity | 25 | 3-5 specific user phrases present |
| Third-person format | 25 | Uses "This skill should be used when..." |
| Description length | 25 | 100-300 characters optimal |
| Specific scenarios | 25 | Concrete use cases, not vague |

**Red flags:**
- Vague triggers like "helps with tasks"
- Second-person descriptions ("Use this when you...")
- Missing or generic descriptions
- No actionable trigger phrases

**Reference:** `references/examples-good.md` for exemplary descriptions

### Step 4: Evaluate Content Organization (30%)

Assess adherence to progressive disclosure principles.

**Scoring breakdown:**

| Criterion | Points | Evaluation |
|-----------|--------|------------|
| Progressive disclosure | 30 | SKILL.md lean, details in references/ |
| SKILL.md length | 25 | Under 5,000 words (1,500-2,000 ideal) |
| References/ usage | 25 | Detailed content properly moved |
| Logical organization | 20 | Clear sections, good flow |

**Check:**
- SKILL.md body is concise and focused
- Detailed content moved to `references/`
- Examples and templates in appropriate directories
- No information duplication across files

**Reference:** `references/scoring-criteria.md` for detailed rubrics

### Step 5: Evaluate Writing Style (20%)

Verify adherence to skill writing conventions.

**Scoring breakdown:**

| Criterion | Points | Evaluation |
|-----------|--------|------------|
| Imperative form | 40 | Verb-first instructions throughout |
| No second person | 30 | Avoids "you", "your", "should" |
| Objective language | 30 | Factual, instructional tone |

**Check for:**
- Imperative verbs: "Create the file", "Validate input", "Check structure"
- Absence of: "You should", "You can", "You need to"
- Objective, instructional language
- Consistent style throughout

**Good examples:**
```
Create the skill directory structure.
Validate the YAML frontmatter.
Check for required fields.
```

**Bad examples:**
```
You should create the directory.
You need to validate the frontmatter.
Check if the fields are there.
```

### Step 6: Evaluate Structural Integrity (25%)

Verify the skill's physical structure and completeness.

**Scoring breakdown:**

| Criterion | Points | Evaluation |
|-----------|--------|------------|
| YAML frontmatter | 30 | All required fields present |
| Directory structure | 30 | Proper organization |
| Resource references | 40 | All referenced files exist |

**Validate:**
- YAML frontmatter contains `name` and `description`
- Directory structure follows conventions:
  ```
  skill-name/
  ├── SKILL.md
  ├── references/ (optional)
  ├── examples/ (optional)
  └── scripts/ (optional)
  ```
- All files referenced in SKILL.md actually exist
- Examples are complete and working
- Scripts are executable

### Step 7: Calculate Weighted Score

Compute the overall quality score using weighted dimensions.

**Formula:**
```
Overall Score = (Description × 0.25) + (Organization × 0.30) +
                (Style × 0.20) + (Structure × 0.25)
```

**Letter grade mapping:**

| Score Range | Grade | Meaning |
|-------------|-------|---------|
| 97-100 | A+ | Exemplary |
| 93-96 | A | Excellent |
| 90-92 | A- | Very Good |
| 87-89 | B+ | Good |
| 83-86 | B | Above Average |
| 80-82 | B- | Solid |
| 77-79 | C+ | Acceptable |
| 73-76 | C | Satisfactory |
| 70-72 | C- | Minimal Acceptable |
| 67-69 | D+ | Below Standard |
| 63-66 | D | Poor |
| 60-62 | D- | Very Poor |
| 0-59 | F | Fail |

### Step 8: Generate Reports

Create two output documents in the current working directory.

**1. Quality Report** (`quality-report-{skill-name}.md`)
- Executive summary with overall score and grade
- Dimension-by-dimension breakdown
- Strengths and weaknesses for each dimension
- Grade breakdown table
- Link to improvement plan

**2. Improvement Plan** (`improvement-plan-{skill-name}.md`)
- Prioritized improvement list (High/Medium/Low)
- Specific file locations and line numbers for issues
- Current vs. suggested content comparisons
- Estimated impact on scores
- Time estimates for fixes
- Expected score improvement

## Output Templates

### Quality Report Template

```markdown
# Skill Quality Report: {skill-name}

## Executive Summary
- **Overall Score**: X/100 ({Grade})
- **Evaluated**: {Date}
- **Skill Path**: {path}

## Dimension Scores

### 1. Description Quality (25%)
**Score**: X/100

**Strengths**:
- ✅ {specific strength}

**Weaknesses**:
- ❌ {specific weakness}

**Recommendations**:
1. {actionable recommendation}

[Repeat for other dimensions...]

## Grade Breakdown
| Dimension | Score | Weight | Contribution |
|-----------|-------|--------|--------------|
| Description | X/100 | 25% | X.X |
| Organization | X/100 | 30% | X.X |
| Style | X/100 | 20% | X.X |
| Structure | X/100 | 25% | X.X |
| **Overall** | **X/100** | **100%** | **X.X ({Grade})** |

## Next Steps
See `improvement-plan-{skill-name}.md` for detailed improvement suggestions.
```

### Improvement Plan Template

```markdown
# Skill Improvement Plan: {skill-name}

## Priority Summary
- **High Priority**: {count} items
- **Medium Priority**: {count} items
- **Low Priority**: {count} items

## High Priority Improvements

### 1. [Issue Title]
**File**: SKILL.md:line:line
**Dimension**: Description Quality
**Impact**: +X points

**Current**:
```yaml
{current content}
```

**Suggested**:
```yaml
{suggested content}
```

**Reason**: {why this improves quality}

[Continue with all issues...]

## Quick Wins (Easy Fixes)
1. {quick fix}
2. {quick fix}

## Estimated Time to Complete
- High Priority: X hours
- Medium Priority: X hours
- Low Priority: X hours
- **Total**: X hours

## Expected Score Improvement
- Current: X/100 ({Grade})
- After High Priority: X/100 ({Grade})
- After All: X/100 ({Grade})
```

## Additional Resources

### Reference Files

For detailed evaluation criteria and examples, consult:

- **`references/scoring-criteria.md`** - Comprehensive scoring rubrics for each dimension
- **`references/examples-good.md`** - Exemplary skills demonstrating best practices
- **`references/examples-bad.md`** - Common anti-patterns to avoid

### Scripts

- **`scripts/extract-yaml.sh`** - Utility for extracting YAML frontmatter from SKILL.md

### Related Skills

- **`skill-development`** - Comprehensive guide for creating skills
- **`code-review-excellence`** - Best practices for code review

## Best Practices

### When Analyzing Skills

1. **Be objective and specific** - Base scores on observable criteria, not opinions
2. **Provide actionable feedback** - Each recommendation should be concrete and implementable
3. **Include examples** - Show current vs. suggested content for clarity
4. **Estimate impact** - Help users understand which changes matter most
5. **Be constructive** - Frame feedback as opportunities for improvement

### Common Quality Issues

**Description Quality:**
- Vague or generic trigger phrases
- Second-person descriptions
- Missing concrete use cases

**Content Organization:**
- SKILL.md too long (>5,000 words)
- Detailed content not moved to references/
- Poor information hierarchy

**Writing Style:**
- Second-person language ("you", "your")
- Mixed imperative and descriptive styles
- Subjective or conversational tone

**Structural Integrity:**
- Missing required YAML fields
- Referenced files don't exist
- Incomplete examples or broken scripts

### Grade Benchmarks

**A grade (90-100)**: Exemplary skills serving as templates for others
- All dimensions score 85+
- Clear, specific descriptions
- Excellent progressive disclosure
- Consistent imperative style
- Complete, well-organized structure

**B grade (80-89)**: High-quality skills with minor improvements needed
- Most dimensions score 75+
- Good descriptions and organization
- Generally follows best practices
- May have minor style inconsistencies

**C grade (70-79)**: Acceptable skills requiring moderate improvements
- Key areas meet minimum standards
- Some weaknesses in organization or style
- Functional but not exemplary

**D/F grade (below 70)**: Skills needing significant work
- Multiple dimensions below 70
- Major structural or style issues
- Requires comprehensive revision

## Usage Examples

**Example 1: Analyze a local skill**
```
User: "Analyze skill quality for ~/.claude/skills/git-workflow"

[Claude executes the 8-step workflow and generates:]
- quality-report-git-workflow.md
- improvement-plan-git-workflow.md
```

**Example 2: Review before sharing**
```
User: "Review my new skill before I publish it"

[Claude analyzes the skill and provides:]
- Detailed quality assessment
- Specific improvement recommendations
- Expected score after implementing fixes
```

**Example 3: Quality check for existing skill**
```
User: "Check skill quality of api-helper"

[Claude evaluates and reports:]
- Current grade and score
- Top improvement opportunities
- Quick wins for easy score gains
```
