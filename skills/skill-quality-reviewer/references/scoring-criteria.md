# Skill Quality Scoring Criteria

Detailed evaluation rubrics for each quality dimension assessed by the skill-quality-reviewer.

## 1. Description Quality (25% Weight)

Assesses the effectiveness of the frontmatter description in triggering the skill appropriately.

### Scoring Breakdown

#### Trigger Phrases Clarity (0-25 points)

**25 points (Excellent):**
- 5+ specific, concrete trigger phrases
- Phrases cover diverse use cases
- Each phrase is something a user would naturally say
- Phrases include both specific tasks and general scenarios

**Example:**
```yaml
description: This skill should be used when the user asks to "create a hook",
"add a PreToolUse hook", "validate tool use", "implement prompt-based hooks",
"set up event-driven automation", or mentions hook events (PreToolUse, PostToolUse,
Stop, SubagentStop).
```

**20 points (Good):**
- 3-4 specific trigger phrases
- Good variety of scenarios
- Most phrases are natural user language

**15 points (Acceptable):**
- 2-3 trigger phrases
- Some variety but may miss key scenarios
- Phrases are reasonably specific

**10 points (Needs Work):**
- 1-2 trigger phrases
- Limited variety
- Some phrases too generic

**5 points (Poor):**
- Single vague trigger phrase
- Missing common use cases

**0 points (Fail):**
- No trigger phrases
- Trigger phrases are meaningless

---

#### Third-Person Format (0-25 points)

**25 points (Excellent):**
- Consistently uses "This skill should be used when..."
- Never uses second person ("you", "your")
- Professional, objective tone

**20 points (Good):**
- Generally uses third person
- Minor inconsistencies but overall correct

**10 points (Needs Work):**
- Mix of third and second person
- Inconsistent formatting

**0 points (Fail):**
- Uses second person ("Use this when you want...")
- First person references

---

#### Description Length (0-25 points)

**25 points (Excellent):**
- 150-300 characters
- Concise yet comprehensive
- No unnecessary words

**20 points (Good):**
- 100-150 or 300-400 characters
- Slightly short or long but acceptable

**15 points (Acceptable):**
- 80-100 or 400-500 characters
- Beginning to be too concise or verbose

**10 points (Needs Work):**
- 50-80 or 500-700 characters
- Too brief or too verbose

**5 points (Poor):**
- Under 50 or over 700 characters

**0 points (Fail):**
- Effectively empty or extremely long

---

#### Specific Scenarios (0-25 points)

**25 points (Excellent):**
- Multiple concrete scenarios mentioned
- Clear scope boundaries (when NOT to use)
- Specific domains or use cases identified

**Example:**
```yaml
description: ... Use when designing new API endpoints, validating existing
contracts, or checking breaking changes. NOT for general API testing or
documentation generation.
```

**20 points (Good):**
- Good scenario coverage
- Clear use cases

**15 points (Acceptable):**
- Basic scenario descriptions
- Could be more specific

**10 points (Needs Work):**
- Vague scenarios
- Unclear when to use

**0 points (Fail):**
- No scenarios mentioned
- Purely generic description

---

## 2. Content Organization (30% Weight)

Evaluates adherence to progressive disclosure principles and effective content organization.

### Scoring Breakdown

#### Progressive Disclosure (0-30 points)

**30 points (Excellent):**
- SKILL.md under 2,000 words
- All detailed content in references/
- Clear separation of overview and details
- References/ properly organized with multiple files

**25 points (Good):**
- SKILL.md 2,000-3,000 words
- Most detailed content moved to references/
- Good separation of concerns

**20 points (Acceptable):**
- SKILL.md 3,000-5,000 words
- Some detailed content still in SKILL.md
- References/ used but could be better

**15 points (Needs Work):**
- SKILL.md 5,000-7,000 words
- Significant content should be moved
- Limited use of references/

**10 points (Poor):**
- SKILL.md over 7,000 words
- Minimal or no references/ usage

**0 points (Fail):**
- Everything in one large file
- No progressive disclosure

---

#### SKILL.md Length Control (0-25 points)

**25 points (Excellent):**
- 1,500-2,000 words (optimal)
- Every word serves a purpose
- No redundancy

**20 points (Good):**
- 1,000-1,500 or 2,000-3,000 words
- Generally concise

**15 points (Acceptable):**
- 800-1,000 or 3,000-4,000 words
- Some unnecessary content

**10 points (Needs Work):**
- 500-800 or 4,000-5,000 words
- Could be significantly trimmed

**5 points (Poor):**
- Under 500 or over 5,000 words
- Major length issues

---

#### References/ Usage (0-25 points)

**25 points (Excellent):**
- 3+ well-organized reference files
- Clear topics (patterns, advanced, examples, etc.)
- Properly referenced in SKILL.md
- Each file has clear purpose

**20 points (Good):**
- 2-3 reference files
- Good organization
- Referenced in SKILL.md

**15 points (Acceptable):**
- 1-2 reference files
- Basic organization

**10 points (Needs Work):**
- Single reference file or poorly organized
- Not well referenced

**5 points (Poor):**
- References/ exists but minimal content
- Not referenced from SKILL.md

**0 points (Fail):**
- No references/ directory when clearly needed

---

#### Logical Organization (0-20 points)

**20 points (Excellent):**
- Clear section hierarchy
- Logical flow from overview to details
- Easy to navigate
- Consistent structure

**15 points (Good):**
- Generally well organized
- Minor flow issues

**10 points (Acceptable):**
- Basic organization present
- Some structural confusion

**5 points (Needs Work):**
- Poor organization
- Difficult to follow

**0 points (Fail):**
- No clear structure
- Content randomly arranged

---

## 3. Writing Style (20% Weight)

Evaluates adherence to skill writing conventions and style consistency.

### Scoring Breakdown

#### Imperative Form Usage (0-40 points)

**40 points (Excellent):**
- 95%+ of instructions use imperative form
- Consistent throughout
- Natural, readable instructions

**Good examples:**
```
Create the skill directory structure.
Validate the YAML frontmatter.
Check for required fields.
Read the SKILL.md file.
Generate the quality report.
```

**30 points (Good):**
- 80-95% imperative form
- Generally consistent
- Minor exceptions

**20 points (Acceptable):**
- 60-80% imperative form
- Inconsistent usage

**10 points (Needs Work):**
- 40-60% imperative form
- Significant inconsistency

**0 points (Fail):**
- Less than 40% imperative form
- Mostly descriptive or second-person

---

#### No Second Person (0-30 points)

**30 points (Excellent):**
- Zero instances of "you", "your", "you're"
- Clean imperative style throughout

**20 points (Good):**
- 1-3 minor instances
- Generally avoids second person

**10 points (Acceptable):**
- 4-6 instances
- Some second person creeping in

**5 points (Needs Work):**
- 7-10 instances
- Frequent second person

**0 points (Fail):**
- 10+ instances
- Heavily uses second person

---

#### Objective Language (0-30 points)

**30 points (Excellent):**
- Factual, instructional tone
- No subjective opinions
- Professional language
- Clear and direct

**20 points (Good):**
- Generally objective
- Minor subjectivity

**15 points (Acceptable):**
- Mostly objective with some opinion
- Generally professional

**10 points (Needs Work):**
- Subjective language present
- Conversational tone

**0 points (Fail):**
- Highly subjective
- Unprofessional or casual tone

---

## 4. Structural Integrity (25% Weight)

Evaluates the physical structure, completeness, and correctness of the skill.

### Scoring Breakdown

#### YAML Frontmatter (0-30 points)

**30 points (Excellent):**
- All required fields present (name, description)
- Optional fields used appropriately (version)
- Valid YAML syntax
- No prohibited fields
- Well-formatted

**Example of excellent frontmatter:**
```yaml
---
name: skill-quality-reviewer
description: This skill should be used when the user asks to "analyze skill quality",
"evaluate this skill", "review skill quality", or mentions quality review of Claude Skills.
version: 0.1.0
---
```

**25 points (Good):**
- All required fields present
- Valid YAML
- Minor formatting issues

**20 points (Acceptable):**
- Required fields present
- Valid YAML
- Some missing recommended fields

**10 points (Needs Work):**
- Missing some required fields
- YAML issues present

**0 points (Fail):**
- Missing required fields
- Invalid YAML syntax
- Cannot parse frontmatter

---

#### Directory Structure (0-30 points)

**30 points (Excellent):**
- Proper skill structure:
  ```
  skill-name/
  ├── SKILL.md
  ├── references/
  ├── examples/
  └── scripts/
  ```
- Each subdirectory has clear purpose
- No unnecessary files
- Clean naming conventions

**25 points (Good):**
- Core structure correct
- Minor organization issues

**20 points (Acceptable):**
- Basic structure present
- Some organizational issues

**10 points (Needs Work):**
- Missing key directories
- Poor organization

**0 points (Fail):**
- No clear structure
- Chaotic organization

---

#### Resource References (0-40 points)

**40 points (Excellent):**
- All referenced files exist
- References are accurate and specific
- Examples are complete and working
- Scripts are executable
- No broken links or references

**Check method:**
- Read SKILL.md
- Extract all references to files (e.g., `references/patterns.md`)
- Verify each file exists
- Verify examples/ and scripts/ contents

**30 points (Good):**
- All references exist
- Minor issues with completeness

**20 points (Acceptable):**
- Most references valid
- Some broken or incomplete references

**10 points (Needs Work):**
- Multiple broken references
- Incomplete examples

**0 points (Fail):**
- Many broken references
- Examples don't work
- Scripts not executable

---

## Grade Calculation

### Weighted Score Formula

```
Overall Score = (Description Quality × 0.25) +
                (Content Organization × 0.30) +
                (Writing Style × 0.20) +
                (Structural Integrity × 0.25)
```

### Letter Grade Mapping

| Score Range | Grade | Quality Level | Certification |
|-------------|-------|---------------|--------------|
| 97-100 | A+ | Exemplary | Certified |
| 93-96 | A | Excellent | Certified |
| 90-92 | A- | Very Good | Certified |
| 87-89 | B+ | Good | Certified |
| 83-86 | B | Above Average | Certified |
| 80-82 | B- | Solid | Certified |
| 77-79 | C+ | Acceptable | Review |
| 73-76 | C | Satisfactory | Review |
| 70-72 | C- | Minimal | Review |
| 67-69 | D+ | Below Standard | Reject |
| 63-66 | D | Poor | Reject |
| 60-62 | D- | Very Poor | Reject |
| 0-59 | F | Fail | Reject |

### Certification Thresholds

For "Certified" status (recommended for sharing):
- Overall score: ≥80/100
- Description Quality: ≥75/100
- Content Organization: ≥75/100
- Writing Style: ≥70/100
- Structural Integrity: ≥80/100

---

## Quick Reference Scoring Guide

### Description Quality Quick Checks

- [ ] Description has 3-5 specific trigger phrases
- [ ] Uses third person ("This skill should be used when...")
- [ ] Length is 100-300 characters
- [ ] Mentions concrete use cases

### Content Organization Quick Checks

- [ ] SKILL.md under 5,000 words (ideally 1,500-2,000)
- [ ] Detailed content in references/
- [ ] Examples in examples/ directory
- [ ] Scripts in scripts/ directory

### Writing Style Quick Checks

- [ ] Instructions use verbs (Create, Validate, Check)
- [ ] No "you", "your", "you're" in body
- [ ] Objective, instructional tone
- [ ] Consistent style throughout

### Structural Integrity Quick Checks

- [ ] YAML has name and description
- [ ] All referenced files exist
- [ ] Examples are complete
- [ ] Scripts are executable

---

## Common Scenarios

### Scenario 1: New Skill Submission

**Context:** Developer submits a new skill for review.

**Evaluation Focus:**
- Description quality (is it clear when to use?)
- Progressive disclosure (is content organized?)
- Writing style (does it follow conventions?)

**Passing Criteria:** B- (80) or higher overall

---

### Scenario 2: Skill Quality Audit

**Context:** Periodic review of existing skills.

**Evaluation Focus:**
- All dimensions equally
- Identify improvement opportunities
- Track quality over time

**Passing Criteria:** C (73) or higher overall

---

### Scenario 3: Pre-Publication Check

**Context:** Final check before sharing skill publicly.

**Evaluation Focus:**
- Structural integrity (must be complete)
- Description quality (must be discoverable)
- No critical issues

**Passing Criteria:** B (83) or higher overall

---

This scoring criteria document provides the detailed rubrics used by skill-quality-reviewer to evaluate Claude Skills. Use this as a reference when interpreting quality reports or planning improvements.
