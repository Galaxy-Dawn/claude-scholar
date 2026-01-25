---
name: scientific-writing
description: "This skill should be used when the user asks to \"write a paper\", \"polish my manuscript\", \"review this scientific text\", \"improve my academic writing\", \"help with submission\", \"remove AI writing patterns\", \"humanize this text\", or mentions scientific writing tasks. Covers research papers, ML conference submissions (NeurIPS, ICML, ICLR, ACL, AAAI, COLM), CS conferences (KDD, CVPR), and journal submissions (Nature, Science, Cell, PNAS). Provides IMRAD structure, citation styles (APA/IEEE/Vancouver), figures/tables, anti-AI writing guidance, ML-specific workflows (narrative principle, citation verification, LaTeX templates), and reviewer-perspective polishing. Integrates with humanizer, humanizer-zh, and stop-slop skills for comprehensive AI-pattern removal. Includes ML writing philosophy from top researchers."
version: 1.0.0
---

# Scientific Writing

## Overview

Scientific writing is a process for communicating research with precision and clarity. Write manuscripts using IMRAD structure, citations (APA/AMA/Vancouver), figures/tables, and reporting guidelines (CONSORT/STROBE/PRISMA). Apply this skill for research papers and journal submissions.

**Critical Principle: Always write in full paragraphs with flowing prose. Never submit bullet points in the final manuscript.** Use a two-stage process: first create section outlines with key points, then convert those outlines into complete paragraphs.

## When to Use This Skill

This skill should be used when:
- Writing or revising any section of a scientific manuscript
- Structuring a research paper using IMRAD or CS conference formats
- Preparing submissions for top ML conferences (NeurIPS, ICML, ICLR, ACL, AAAI, COLM)
- Preparing submissions for CS conferences (KDD, CVPR, etc.)
- Writing for high-impact journals (Nature, Science, Cell, PNAS)
- Starting a paper from a research repository
- Verifying citations and preventing hallucinated references
- Using LaTeX templates for ML conference submissions
- Applying the Narrative Principle (What/Why/So What) to ML papers
- Formatting citations and references
- Creating or improving figures, tables, and data visualizations
- Applying study-specific reporting guidelines
- Drafting abstracts that meet journal/conference requirements
- Polishing manuscripts from reviewer perspective
- Improving writing clarity, conciseness, and precision
- Addressing reviewer comments and revising manuscripts

## Visual Enhancement Requirement

**Every scientific paper MUST include at least 1-2 AI-generated figures.**

Use the **scientific-schematics** skill to generate publication-quality diagrams. For comprehensive guidance, refer to the scientific-schematics skill documentation.

**When to add schematics:**
- Study design and methodology flowcharts
- Conceptual framework diagrams
- Experimental workflow illustrations
- Data analysis pipeline diagrams
- Any complex concept that benefits from visualization

## Core Capabilities

### 1. Manuscript Structure and Organization

**IMRAD Format**: Introduction, Methods, Results, And Discussion structure.

For detailed guidance, refer to `references/imrad_structure.md`.

### 2. Citation and Reference Management

**Major Citation Styles:**
- **Vancouver**: Numbered citations, biomedical standard
- **APA**: Author-date citations, social sciences
- **IEEE**: Numbered square brackets, engineering and computer science

For comprehensive style guides, refer to `references/citation_styles.md`.

### 3. Figures and Tables

**Design Principles:**
- Make each table/figure self-explanatory with complete captions
- Use consistent formatting and terminology
- Label all axes, columns, and rows with units
- Follow the "one table/figure per 1000 words" guideline

For detailed best practices, refer to `references/figures_tables.md`.

### 4. Reporting Guidelines

**Key Guidelines:**
- **CONSORT**: Randomized controlled trials
- **STROBE**: Observational studies
- **PRISMA**: Systematic reviews and meta-analyses

For comprehensive guideline details, refer to `references/reporting_guidelines.md`.

### 5. Writing Principles

**Natural Academic Prose**: Avoid AI-like writing patterns.

For comprehensive guidance on producing natural, human-like text, refer to `references/anti_ai_writing.md`.

**Key principles:**
- Vary sentence length and structure naturally
- Use simple, common transitions
- Avoid overuse of "furthermore," "moreover," "additionally"
- Maintain author voice and natural variation

### 6. ML Conference Writing

**ML Conference Focus**: NeurIPS, ICML, ICLR, ACL, AAAI, COLM with specialized workflows.

**Key ML-Specific Capabilities:**

For detailed ML conference guidance, refer to `references/ml/` directory:

- `ml_conferences.md`: Complete ML conference requirements (page limits, checklists, reviewer criteria)
- `citation_verification.md`: Citation verification workflow, API usage, preventing hallucinated references
- `latex_templates.md`: LaTeX template management, compilation, best practices
- `narrative_principle.md`: The Narrative Principle (What/Why/So What framework)
- `collaborative_writing.md`: Proactive drafting philosophy for research repositories
- `writing_philosophy.md`: Writing principles from top ML researchers (Gopen & Swan, Lipton, etc.)

**ML Conference Requirements:**

| Conference | Pages | Key Requirements |
|------------|-------|------------------|
| NeurIPS 2025 | 9 | Checklist, lay summary |
| ICML 2026 | 8+1 | Broader Impact Statement |
| ICLR 2026 | 9+1 | LLM disclosure, limitations |
| ACL 2025 | 8 | Limitations section mandatory |
| AAAI 2026 | 7+1 | Strict style compliance |
| COLM 2025 | 9+1 | Language model focus |

**The Narrative Principle** (from Neel Nanda):
- **The What**: 1-3 specific novel claims within cohesive theme
- **The Why**: Rigorous empirical evidence supporting claims
- **The So What**: Why readers should care

**Citation Verification** (Critical - ~40% AI error rate):
- NEVER generate BibTeX from memory
- ALWAYS fetch programmatically via APIs
- Use Semantic Scholar, CrossRef, arXiv APIs
- Mark unverified citations as [CITATION NEEDED]

**Proactive Writing Philosophy**:
- Deliver complete drafts, then iterate
- Ask questions WITH the draft, not before
- Make reasonable choices, flag for review
- Block only when genuinely uncertain

### 7. Field-Specific Language

Adapt language, terminology, and conventions to match the specific scientific discipline.

For detailed field-specific guidance, refer to `references/field_specific_language.md`.

## Writing Process: Two-Stage Approach

**CRITICAL: Always write in full paragraphs, never submit bullet points in scientific papers.**

**Stage 1: Create Section Outlines with Key Points**

1. Use the research-lookup skill to gather relevant literature
2. Create a structured outline with bullet points marking main arguments, key studies, data points
3. These bullet points serve as scaffolding—they are NOT the final manuscript

**Stage 2: Convert Key Points to Full Paragraphs**

1. Transform bullet points into complete sentences
2. Add transitions between sentences and ideas
3. Integrate citations naturally within sentences
4. Expand with context and explanation
5. Ensure logical flow from one sentence to the next

**Common Mistakes to Avoid:**
- Never leave bullet points in the final manuscript
- Never submit lists where paragraphs should be
- Don't use numbered or bulleted lists in Results or Discussion sections (except for specific cases like inclusion criteria)
- Do ensure every section flows as connected prose

## Targeted Polishing Workflow

**IMPORTANT: Before polishing or writing, always ask about the target venue**

1. **Ask for the target venue first**:
   - "Which journal or conference are you targeting?"
   - "What is the submission deadline?"

2. **Load the relevant reference** based on their response:
   - ML conferences → Load `references/ml/ml_conferences.md`
   - CS conferences → Load `references/cs_conferences.md`
   - High-impact journals → Load `references/nature_submissions.md`
   - Field-specific guidelines → Load appropriate reference

3. **Apply venue-specific requirements**:
   - Page/word limits
   - Format requirements
   - Structure requirements
   - Submission-specific content

4. **Use anti-AI writing guidelines**:
   - Always apply principles from `references/anti_ai_writing.md`
   - Vary sentence structure and length
   - Maintain natural academic prose

5. **Check logical flow**:
   - Load `references/logic_analysis.md` for detailed guidance
   - Analyze paragraph-level logical connections
   - Identify logical gaps and inconsistencies
   - Check transitions between paragraphs

## Submission-Specific Guidance

### Computer Science Conferences

For detailed guidance on CS conference submissions, refer to `references/cs_conferences.md`.

**Top CS Conferences:**
- **NeurIPS**: ML, AI, Neuroscience | 8 pages + refs
- **ICML**: ML theory and applications | 8 pages + refs
- **ICLR**: Deep learning, representations | 8 pages + refs
- **KDD**: Data mining | 10 pages + refs
- **CVPR**: Computer vision | 8 pages + refs
- **AAAI**: General AI | 7-8 pages + refs

**CS-Specific Requirements:**
- Double-blind anonymity
- LaTeX templates required
- Algorithm pseudocode for complex methods
- Ablation studies demonstrating component contributions
- Comparison with state-of-the-art baselines

### High-Impact Journals

For detailed guidance on Nature and other high-impact journals, refer to `references/nature_submissions.md`.

**Top Journals:**
- **Nature**: Multidisciplinary | 5-6 pages | ~8% acceptance
- **Science**: Multidisciplinary | 4500 words | ~7% acceptance
- **Cell**: Biology | Variable | ~10% acceptance
- **PNAS**: Multidisciplinary | 6 pages | ~20% acceptance

**High-Impact Journal Requirements:**
- Significance statement explaining broad impact
- Introduction accessible to non-specialists
- Methods in supplementary material allowed
- Clear statements of novelty and conceptual advance

### Reviewer-Perspective Polishing

For comprehensive guidance on polishing from a reviewer's perspective, refer to `references/reviewer_perspective_polishing.md`.

**Pre-Submission Checklist:**

**Content:**
- [ ] Novel contribution clearly stated
- [ ] Related work comprehensive
- [ ] Methods reproducible
- [ ] Results support all claims
- [ ] Limitations acknowledged

**Writing:**
- [ ] No grammar or spelling errors
- [ ] Consistent terminology throughout
- [ ] Clear, logical structure
- [ ] Transitions between sections

## Common Pitfalls to Avoid

**Top Rejection Reasons:**
1. Inappropriate or insufficiently described statistics
2. Over-interpretation of results or unsupported conclusions
3. Poorly described methods affecting reproducibility
4. Small, biased, or inappropriate samples
5. Poor writing quality or difficult-to-follow text
6. Inadequate literature review or context
7. Figures and tables that are unclear or poorly designed

**Writing Quality Issues:**
- Mixing tenses inappropriately (use past tense for methods/results, present for established facts)
- Excessive jargon or undefined acronyms
- Paragraph breaks that disrupt logical flow
- Missing transitions between sections

## References

**ML Conference Writing:**
- `references/ml/ml_conferences.md`: ML conference requirements (NeurIPS, ICML, ICLR, ACL, AAAI, COLM)
- `references/ml/citation_verification.md`: Citation verification workflow and API usage
- `references/ml/latex_templates.md`: LaTeX template management for ML conferences
- `templates/`: LaTeX templates directory with conference-specific README files
- `references/ml/narrative_principle.md`: The Narrative Principle (What/Why/So What)
- `references/ml/collaborative_writing.md`: Proactive drafting philosophy for research repos
- `references/ml/writing_philosophy.md`: Writing principles from top ML researchers
- `references/ml/checklists.md`: Conference paper checklists (NeurIPS 16-item, ICML, ICLR, ACL)
- `references/ml/reviewer_guidelines.md`: How reviewers evaluate papers at ML conferences
- `references/ml/sources.md`: Complete bibliography of authoritative sources

**General Writing:**
- `references/imrad_structure.md`: Detailed guide to IMRAD format
- `references/citation_styles.md`: Complete citation style guides
- `references/figures_tables.md`: Best practices for data visualizations
- `references/reporting_guidelines.md`: Study-specific reporting standards
- `references/writing_principles.md`: Core principles of scientific communication

**Natural Writing:**
- `references/anti_ai_writing.md`: Guidelines to avoid AI-like patterns

**AI Pattern Removal for Academic Writing:**

⚠️ **IMPORTANT**: Academic writing requires objectivity. Do NOT use skills that "inject personality" or "add soul."

**Recommended workflow for papers:**
1. **stop-slop** (English) - Remove mechanical patterns while maintaining objectivity
2. **humanizer-zh (pattern detection only)** - Use the 24-pattern checklist, skip "soul injection" section
3. **scientific-writing** - Ensure compliance with academic standards

**What to remove from academic text:**
- Filler phrases and throat-clearing openers
- Formulaic structures (rule of three, binary contrasts)
- Mechanical sentence patterns (all same length)
- Overused AI vocabulary ("furthermore", "moreover", "crucial", "pivotal")
- Excessive hedging ("potentially possibly", "could be argued that")

**What to maintain in academic text:**
- Objective third-person voice (no "I think", "I believe")
- Professional, formal tone
- Clear, precise technical language
- Proper academic conventions and terminology

**Usage:** When polishing manuscripts:
1. Apply stop-slop for English or humanizer-zh patterns for Chinese
2. Focus on removing mechanical/AI patterns only
3. Do NOT inject personality, opinions, or "soul"
4. Maintain academic rigor and objectivity throughout
5. Use scientific-writing principles for structure and flow

**Logic Analysis:**
- `references/logic_analysis.md`: Paragraph and section-level logic checking

**Submission Guidance:**
- `references/cs_conferences.md`: Top CS conference submission guide
- `references/nature_submissions.md`: High-impact journal submission guidelines
- `references/field_specific_language.md`: Field-specific terminology and conventions

**Polishing:**
- `references/reviewer_perspective_polishing.md`: Comprehensive polishing guide

Load these references as needed when working on specific aspects of scientific writing.
