# LaTeX Templates Guide for ML Conferences

## Overview

This guide provides information on obtaining and using official LaTeX templates for ML conferences. **Always use the official template for your target venue**—using wrong templates can result in desk rejection.

## 🚨 Critical Rule: Copy Entire Template Directory

**Never copy only `main.tex`**

Templates include multiple files:
- `.sty` files - Style definitions (REQUIRED)
- `.bst` files - Bibliography styles (REQUIRED)
- Makefiles - Compilation automation
- Example content - Formatting reference

---

## Quick Download Guide

### Method 1: Official Conference Websites

| Conference | Download URL | File |
|------------|--------------|------|
| **NeurIPS 2025** | [Link](https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles) | `neurips2025.zip` |
| **ICML 2026** | [Link](https://icml.cc/Conferences/2025/AuthorInstructions) | `icml2026.zip` |
| **ICLR 2026** | [Link](https://iclr.cc/Conferences/2026/AuthorGuide) | `iclr2026.zip` |
| **ACL** | [GitHub](https://github.com/acl-org/acl-style-files) | `acl.zip` |
| **AAAI 2026** | [Link](https://aaai.org/authorkit26/) | `aaai2026.zip` |
| **COLM 2025** | [GitHub](https://github.com/COLM-org/Template) | `colm2025.zip` |

### Method 2: Clone from GitHub (Recommended for ACL/COLM)

```bash
# ACL templates
git clone https://github.com/acl-org/acl-style-files.git

# COLM templates
git clone https://github.com/COLM-org/Template.git
```

---

## Template Setup Checklist

```
- [ ] Step 1: Download official template for target venue
- [ ] Step 2: Extract ENTIRE directory (not just main.tex)
- [ ] Step 3: Verify template compiles as-is
- [ ] Step 4: Copy to your paper directory
- [ ] Step 5: Replace content section by section
- [ ] Step 6: Clean up template artifacts at the end
```

---

## Conference-Specific Templates

### NeurIPS 2025

**Download:**
```bash
# From NeurIPS website
wget https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles/neurips_2025.zip
unzip neurips_2025.zip
```

**Expected structure:**
```
neurips2025/
├── neurips_2025.sty       # Style file (REQUIRED)
├── main.tex               # Main document
├── Makefile               # Compilation script
└── README.md              # Instructions
```

**Key features:**
- 9-page limit (excluding references)
- Strict double-blind review
- Checklist must be included

### ICML 2026

**Download:**
```bash
# From ICML website
wget https://icml.cc/Conferences/2025/AuthorInstructions/icml2026.zip
unzip icml2026.zip
```

**Expected structure:**
```
icml2026/
├── icml2026.sty           # Style file (REQUIRED)
├── example_paper.tex      # Main document
├── icml.bst               # Bibliography style (REQUIRED)
├── README.md              # Instructions
└── example_content/       # Example figures/tables
```

**Key features:**
- 8-page limit + 1 page camera-ready
- Broader Impact Statement required
- `icml.bst` for bibliography formatting

### ICLR 2026

**Download:**
```bash
# From ICLR website
wget https://iclr.cc/Conferences/2026/AuthorGuide/iclr2026.zip
unzip iclr2026.zip
```

**Expected structure:**
```
iclr2026/
├── iclr2026_conference.sty    # Style file (REQUIRED)
├── iclr2026_conference.tex     # Main document
├── math_commands.tex           # Math macros (useful)
└── README.md                   # Instructions
```

**Key features:**
- 9-page limit + 1 page camera-ready
- LLM disclosure required
- `math_commands.tex` has useful math macros

### ACL / EMNLP

**Download:**
```bash
# From GitHub
git clone https://github.com/acl-org/acl-style-files.git
cd acl-style-files
```

**Expected structure:**
```
acl/
├── acl.sty               # Style file (REQUIRED)
├── acl_latex.tex         # Main document
├── acl.bst               # Bibliography style (REQUIRED)
├── README.md             # Instructions
└── example_PDFs/         # Example outputs
```

**Key features:**
- 8-page limit (long papers)
- Limitations section mandatory
- Very strict formatting compliance

### AAAI 2026

**Download:**
```bash
# From AAAI website
wget https://aaai.org/authorkit26/aaai2026.zip
unzip aaai2026.zip
```

**Expected structure:**
```
aaai2026/
├── aaai2026.sty                    # Style file (DO NOT MODIFY)
├── aaai2026-unified-template.tex   # Main document
├── README.md                        # Instructions
└── templates/                      # Additional templates
```

**Key features:**
- **MOST STRICT** template compliance
- Automatic formatting checks during submission
- 7-page limit + 1 page camera-ready

### COLM 2025

**Download:**
```bash
# From GitHub
git clone https://github.com/COLM-org/Template.git
cd Template
```

**Expected structure:**
```
colm2025/
├── colm2025_conference.sty   # Style file (REQUIRED)
├── colm2025_conference.tex    # Main document
├── README.md                  # Instructions
└── examples/                  # Example content
```

**Key features:**
- 9-page limit + 1 page camera-ready
- Language model focus
- Similar to ICLR template

---

## Common Pitfalls to Avoid

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Copying only `main.tex` | Missing `.sty`, won't compile | Copy entire directory |
| Modifying `.sty` files | Breaks conference formatting | Never edit style files |
| Adding random packages | Conflicts, breaks template | Only add if necessary |
| Deleting template content too early | Lose formatting reference | Keep as comments until done |
| Not compiling frequently | Errors accumulate | Compile after each section |
| Using old template | Wrong format for year | Download current year's template |

---

## Compilation Methods

### Method 1: latexmk (Recommended)

```bash
# Automatic compilation with dependencies
latexmk -pdf main.tex

# Clean auxiliary files
latexmk -c

# Force full recompilation
latexmk -pdf -f main.tex
```

### Method 2: Manual Compilation

```bash
# First pass
pdflatex main.tex

# Bibliography
bibtex main

# Second pass (resolve citations)
pdflatex main.tex

# Third pass (resolve all references)
pdflatex main.tex
```

### Method 3: VS Code / LaTeX Workshop

**Install:**
1. LaTeX Workshop extension
2. TeX Live distribution

**Configure:** Save to auto-compile.

### Method 4: Overleaf (Online)

**Steps:**
1. Upload template directory to Overleaf
2. Set compiler to pdfLaTeX
3. Enable auto-compile
4. Edit in browser

---

## Template Migration: Converting Between Venues

When resubmitting to a different conference:

**DO:**
- Copy ONLY content sections (between `\section{}` commands)
- Paste into new template structure
- Adjust page limits accordingly
- Update conference-specific required sections

**DON'T:**
- Copy LaTeX preambles (causes conflicts)
- Copy old conference's header/footer commands
- Modify style files
- Keep old conference's specific formatting

**Example Conversion (NeurIPS → ICML):**

```bash
# 1. Start fresh with ICML template
cp -r templates/icml2026/ new_submission/

# 2. Copy ONLY content from NeurIPS paper
# - Abstract text
# - Section content
# - Figures and tables
# - Bibliography entries

# 3. Paste into ICML template structure
# 4. Adjust for page limit (9 → 8 pages)
# 5. Add Broader Impact Statement
```

---

## Verification Checklist

Before submitting:

```
Compilation:
- [ ] Document compiles without errors
- [ ] All citations resolve correctly
- [ ] All references work (\ref, \cite)
- [ ] Page count is correct (references excluded)

Double-Blind Check:
- [ ] Author names removed
- [ ] Acknowledgments removed
- [ ] No self-references that reveal identity
- [ ] GitHub links anonymized

Formatting Check:
- [ ] Correct template used for target venue
- [ ] No modification to .sty files
- [ ] Page limit respected
- [ ] Required sections included
```

---

## Resources

### Official Template Sources

- NeurIPS: https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles
- ICML: https://icml.cc/Conferences/2025/AuthorInstructions
- ICLR: https://iclr.cc/Conferences/2026/AuthorGuide
- ACL: https://github.com/acl-org/acl-style-files
- AAAI: https://aaai.org/authorkit26/
- COLM: https://github.com/COLM-org/Template

### LaTeX Documentation

- Overleaf Learn: https://www.overleaf.com/learn
- LaTeX Wikibook: https://en.wikibooks.org/wiki/LaTeX
- TeX Stack Exchange: https://tex.stackexchange.com

### Tools

- TeX Live: https://tug.org/texlive
- MacTeX: https://www.tug.org/mactex
- Overleaf: https://overleaf.com

---

## See Also

- `latex_templates.md` - Detailed LaTeX template usage guide
- `ml_conferences.md` - Complete conference requirements
- `checklists.md` - Conference paper checklists
