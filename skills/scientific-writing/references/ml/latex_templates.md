# LaTeX Templates for ML Conferences

## Overview

This document provides comprehensive guidance on using LaTeX templates for ML conference submissions. Proper template usage is critical—formatting errors can lead to desk rejection.

## ⚠️ Golden Rule: Copy Entire Template Directory

**Never copy only `main.tex`**

Templates include multiple files that must be present for compilation:
- `.sty` files - Style definitions
- `.bst` files - Bibliography styles
- Makefiles - Compilation automation
- Example content - Formatting reference

## Workflow 4: Starting a New Paper from Template

### Template Setup Checklist

```
- [ ] Step 1: Copy entire template directory to new project
- [ ] Step 2: Verify template compiles as-is (before any changes)
- [ ] Step 3: Read the template's example content to understand structure
- [ ] Step 4: Replace example content section by section
- [ ] Step 5: Keep template comments/examples as reference until done
- [ ] Step 6: Clean up template artifacts only at the end
```

### Step 1: Copy the Full Template

```bash
# Create your paper directory with the complete template
cp -r templates/neurips2025/ ~/papers/my-new-paper/
cd ~/papers/my-new-paper/

# Verify structure is complete
ls -la

# Should see:
# main.tex
# neurips.sty
# Makefile
# icml.bst
# example_content/
```

### Step 2: Verify Template Compiles First

**Before making ANY changes**, compile the template as-is:

```bash
# Using latexmk (recommended)
latexmk -pdf main.tex

# Or manual compilation
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

**If the unmodified template doesn't compile, fix that first.**

Common issues:
- Missing TeX packages → install via `tlmgr install <package>`
- Wrong TeX distribution → use TeX Live (recommended)
- Missing style files → re-download template

### Step 3: Keep Template Content as Reference

**Don't immediately delete all example content.** Instead:

```latex
% KEEP template examples commented out as you write
% This shows you the expected format

% Template example (keep for reference):
% \begin{figure}[t]
% \centering
% \includegraphics[width=0.8\linewidth]{example-image}
% \caption{Template shows caption style}
% \end{figure}

% Your actual figure:
\begin{figure}[t]
\centering
\includegraphics[width=0.8\linewidth]{your-figure.pdf}
\caption{Your caption following the same style.}
\end{figure}
```

### Step 4: Replace Content Section by Section

**Work through the paper systematically:**

```
Replacement Order:
1. Title and authors (anonymize for submission)
2. Abstract
3. Introduction
4. Methods
5. Experiments
6. Related Work
7. Conclusion
8. References (your .bib file)
9. Appendix
```

**For each section:**
1. Read the template's example content
2. Note any special formatting or macros used
3. Replace with your content following the same patterns
4. Compile frequently to catch errors early

### Step 5: Use Template Macros

Templates often define useful macros. Check the preamble for:

```latex
% Common template macros to use:
\newcommand{\method}{YourMethodName}    % Consistent method naming
\newcommand{\eg}{e.g.,\xspace}          % Proper abbreviations
\newcommand{\ie}{i.e.,\xspace}
\newcommand{\etal}{\textit{et al.}\xspace}
\newcommand{\etc}{etc.\xspace}
```

### Step 6: Clean Up Only at the End

**Only remove template artifacts when paper is nearly complete:**

```latex
% BEFORE SUBMISSION - remove these:
% - Commented-out template examples
% - Unused packages
% - Template's example figures/tables
% - Lorem ipsum or placeholder text

% KEEP these:
% - All style files (.sty)
% - Bibliography style (.bst)
% - Required packages from template
% - Any custom macros you're using
```

## Template Pitfalls to Avoid

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Copying only `main.tex` | Missing `.sty`, won't compile | Copy entire directory |
| Modifying `.sty` files | Breaks conference formatting | Never edit style files |
| Adding random packages | Conflicts, breaks template | Only add if necessary |
| Deleting template content too early | Lose formatting reference | Keep as comments until done |
| Not compiling frequently | Errors accumulate | Compile after each section |

## Quick Template Reference

| Conference | Main File | Key Style File | Special Notes |
|------------|-----------|----------------|---------------|
| **NeurIPS 2025** | `main.tex` | `neurips.sty` | Has Makefile, strict 9-page limit |
| **ICML 2026** | `example_paper.tex` | `icml2026.sty` | Includes algorithm packages |
| **ICLR 2026** | `iclr2026_conference.tex` | `iclr2026_conference.sty` | Has math_commands.tex |
| **ACL** | `acl_latex.tex` | `acl.sty` | Strict formatting |
| **AAAI 2026** | `aaai2026-unified-template.tex` | `aaai2026.sty` | Very strict compliance |
| **COLM 2025** | `colm2025_conference.tex` | `colm2025_conference.sty` | Similar to ICLR |

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

**Advantages:**
- Handles BibTeX automatically
- Detects when to recompile
- Cross-reference resolution

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

**Configure:**
```json
{
  "latex-workshop.latex.recipes": [
    {
      "name": "latexmk 🔍",
      "tools": ["latexmk"]
    }
  ]
}
```

**Build:** Save `main.tex` to auto-compile.

### Method 4: Overleaf (Online)

**Steps:**
1. Upload template directory to Overleaf
2. Set compiler to pdfLaTeX
3. Enable auto-compile
4. Edit in browser

**Advantages:**
- No local installation needed
- Collaborative editing
- Cloud backup

## Template-Specific Guidance

### NeurIPS Template

**File structure:**
```
neurips2025/
├── main.tex              # Main document
├── neurips.sty           # Style file
├── Makefile              # Compilation script
└── README.md             # Instructions
```

**Key features:**
- `neurips_2025.sty` defines all formatting
- 9-page limit strictly enforced
- References page doesn't count toward limit

**Common issues:**
- Missing `neurips.sty` → download from official site
- Compilation fails → check TeX Live version

### ICML Template

**File structure:**
```
icml2026/
├── example_paper.tex     # Main document
├── icml2026.sty          # Style file
├── icml.bst              # Bibliography style
└── README.md             # Instructions
```

**Key features:**
- Includes `algorithm` and `algorithmic` packages
- Has `icml.bst` for bibliography formatting
- 8-page limit + 1 page for camera-ready

### ICLR Template

**File structure:**
```
iclr2026/
├── iclr2026_conference.tex    # Main document
├── iclr2026_conference.sty     # Style file
├── math_commands.tex           # Math macros
└── README.md                   # Instructions
```

**Key features:**
- `math_commands.tex` has useful math macros
- 9-page limit + 1 page for camera-ready
- Double-blind format

### ACL Template

**File structure:**
```
acl/
├── acl_latex.tex         # Main document
├── acl.sty               # Style file
├── acl.bst               # Bibliography style
└── README.md             # Instructions
```

**Key features:**
- Very strict formatting (down to millimeters)
- 8-page limit for long papers
- Uses `acl.bst` for bibliography

### AAAI Template

**File structure:**
```
aaai2026/
├── aaai2026-unified-template.tex  # Main document
├── aaai2026.sty                    # Style file
└── README.md                       # Instructions
```

**Key features:**
- **Most strict** template compliance
- Automatic formatting checks during submission
- 7-page limit + 1 page for camera-ready

## Common LaTeX Issues and Solutions

### Issue: Package Conflicts

**Problem:** Multiple packages define same command

```latex
% BAD - conflicts
\usepackage{hyperref}
\usepackage{url}

% GOOD - load in correct order
\usepackage{url}
\usepackage{hyperref}
```

### Issue: Missing Packages

**Problem:** Template uses package not installed

**Solution:** Install via TeX Live
```bash
tlmgr install <package-name>
```

**Common missing packages:**
- `booktabs` - Professional tables
- `algorithm` - Algorithm floats
- `subcaption` - Subfigures
- `cleveref` - Smart references

### Issue: Citation Errors

**Problem:** Citations show as `[?]`

**Solution:** Run BibTeX
```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

### Issue: Figure Placement

**Problem:** Figures not where expected

**Solution:** Use appropriate float specifiers
```latex
\begin{figure}[t]  % Top of page
\begin{figure}[b]  % Bottom of page
\begin{figure}[h]  % Here (if possible)
\begin{figure}[!htb]  % Force location
```

### Issue: Table Formatting

**Problem:** Tables look unprofessional

**Solution:** Use `booktabs`
```latex
\usepackage{booktabs}

\begin{tabular}{lcc}
\toprule
Method & Accuracy ↑ & Latency ↓ \\
\midrule
Baseline & 85.2 & 45ms \\
\textbf{Ours} & \textbf{92.1} & 38ms \\
\bottomrule
\end{tabular}
```

## Bibliography Management

### BibTeX vs BibLaTeX

**BibTeX** (Traditional):
```latex
\bibliographystyle{icml.bst}
\bibliography{references}
```

**BibLaTeX** (Modern):
```latex
\usepackage[style=authoryear]{biblatex}
\addbibresource{references.bib}
\printbibliography
```

### Citation Styles by Conference

| Conference | Style | File |
|------------|-------|------|
| NeurIPS | Numbered | Built-in |
| ICML | Numbered | `icml.bst` |
| ICLR | Numbered | Built-in |
| ACL | Numbered | `acl.bst` |
| AAAI | Numbered | Built-in |

### Creating .bib Files

**From Semantic Scholar:**
1. Search for paper
2. Click "Cite"
3. Select "BibTeX"
4. Copy to your `.bib` file

**From DOI:**
```python
import requests

def doi_to_bibtex(doi):
    response = requests.get(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/x-bibtex"}
    )
    return response.text

bibtex = doi_to_bibtex("10.48550/arXiv.1706.03762")
print(bibtex)
```

## Figures in LaTeX

### Vector Graphics (Preferred)

**Format:** PDF, EPS

**Example:**
```latex
\begin{figure}[t]
\centering
\includegraphics[width=0.8\linewidth]{figure.pdf}
\caption{Your figure caption.}
\label{fig:your-figure}
\end{figure}
```

**When to use:**
- Plots (matplotlib, ggplot2)
- Diagrams (draw.io, Omnigraffle)
- Algorithms (tikz)

### Raster Graphics (Use Sparingly)

**Format:** PNG at 600 DPI minimum

**Example:**
```latex
\begin{figure}[t]
\centering
\includegraphics[width=0.8\linewidth]{photo.png}
\caption{Photograph of experimental setup.}
\end{figure}
```

**When to use:**
- Photographs
- Screenshots
- Natural images

### Subfigures

```latex
\usepackage{subcaption}

\begin{figure}[t]
\centering
\begin{subfigure}{0.48\linewidth}
\centering
\includegraphics[width=\linewidth]{fig1a.pdf}
\caption{Subfigure A}
\end{subfigure}
\hfill
\begin{subfigure}{0.48\linewidth}
\centering
\includegraphics[width=\linewidth]{fig1b.pdf}
\caption{Subfigure B}
\end{subfigure}
\caption{Complete figure caption.}
\end{figure}
```

## Algorithms in LaTeX

### Using algorithm Package

```latex
\usepackage{algorithm}
\usepackage{algorithmic}

\begin{algorithm}[t]
\caption{Your Algorithm}
\label{alg:your-algorithm}
\begin{algorithmic}[1]
\REQUIRE Input $x$
\ENSURE Output $y$
\STATE Initialize parameters
\FOR{$i = 1$ to $n$}
    \STATE Process $x_i$
\ENDFOR
\RETURN $y$
\end{algorithmic}
\end{algorithm}
```

### Using algorithm2e Package

```latex
\usepackage[ruled,vlined]{algorithm2e}

\begin{algorithm}[H]
\SetAlgoLined
\KwIn{Input $x$}
\KwOut{Output $y$}
Initialize parameters\;
\For{$i = 1$ \KwTo $n$}{
    Process $x_i$\;
}
\Return $y$\;
\caption{Your Algorithm}
\end{algorithm}
```

## Math in LaTeX

### Common Commands

```latex
% Inline math
The model achieves $O(n \log n)$ complexity.

% Display math
\begin{equation}
\mathcal{L}(\theta) = \sum_{i=1}^{n} \log p_\theta(x_i)
\end{equation}

% Aligned equations
\begin{align}
f(x) &= x^2 + 2x + 1 \\
     &= (x + 1)^2
\end{align}
```

### ICLR Math Macros

ICLR template provides `math_commands.tex` with useful macros:

```latex
% From ICLR template
\newcommand{\independent}{\perp \!\!\! \perp}
\newcommand{\abs}[1]{\lvert#1\rvert}
\newcommand{\norm}[1]{\lVert#1\rVert}
\newcommand{\E}{\mathbb{E}}
\newcommand{\R}{\mathbb{R}}
```

## Pre-Submission Checklist

### LaTeX Compilation
- [ ] Document compiles without errors
- [ ] All citations resolve correctly
- [ ] All references work (\ref, \cite)
- [ ] Page count is correct (references excluded)
- [ ] Figures are high resolution
- [ ] Tables use `booktabs`

### Double-Blind Check
- [ ] Author names removed
- [ ] Acknowledgments removed
- [ ] No self-references that reveal identity
- [ ] GitHub links anonymized
- [ ] Institution names removed

### Formatting Check
- [ ] Correct template used for target venue
- [ ] No modification to .sty files
- [ ] Page limit respected
- [ ] Required sections included (checklist, impact statement)

### Final Verification
```bash
# Clean build
latexmk -c
latexmk -pdf main.tex

# Verify PDF
pdfinfo main.pdf | grep Pages

# Count pages (excluding references)
# Should match venue requirement
```

## Resources

### Official Template Sources
- NeurIPS: https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles
- ICML: https://icml.cc/Conferences/2025/AuthorInstructions
- ICLR: https://iclr.cc/Conferences/2026/AuthorGuide
- ACL: https://github.com/acl-org/acl-style-files
- AAAI: https://aaai.org/conference/aaai/aaai-26-submit/

### LaTeX Documentation
- Overleaf Learn: https://www.overleaf.com/learn
- LaTeX Wikibook: https://en.wikibooks.org/wiki/LaTeX
- TeX Stack Exchange: https://tex.stackexchange.com

### Tools
- TeX Live: https://tug.org/texlive
- MacTeX: https://www.tug.org/mactex
- Overleaf: https://overleaf.com
