---
name: latex-conference-template-organizer
description: Organize messy conference LaTeX template .zip files into clean Overleaf-ready structure. Use when the user asks to "organize LaTeX template", "clean up .zip template", or "prepare Overleaf submission template".
version: 0.1.0
---

# LaTeX Conference Template Organizer

## Overview

Transform messy conference LaTeX template .zip files into clean, Overleaf-ready submission templates. Official conference templates often contain excessive example content, instructional comments, and disorganized file structures. This skill converts them into templates ready for writing.

## Working Mode

**Analyze-then-confirm mode**: First analyze issues and present them to the user, then execute cleanup after confirmation.

## Complete Workflow

```
Receive .zip file
    ↓
1. Extract and analyze file structure
    ↓
2. Identify main file and dependencies
    ↓
3. Diagnose issues (present to user)
    ↓
4. Ask for conference info (link/name)
    ↓
5. Wait for user confirmation of cleanup plan
    ↓
6. Execute cleanup, create output directory
    ↓
7. Generate README (with official website info)
    ↓
8. Output complete
```

## Step 1: Extract and Analyze

### Extract Files

Extract .zip to a temporary directory:

```bash
unzip -q template.zip -d /tmp/latex-template-temp
cd /tmp/latex-template-temp
find . -type f -name "*.tex" -o -name "*.sty" -o -name "*.cls" -o -name "*.bib"
```

### Identify File Types

| File Type | Purpose |
|-----------|---------|
| `.tex` | LaTeX source files |
| `.sty` / `.cls` | Style files |
| `.bib` | Bibliography database |
| `.pdf` / `.png` / `.jpg` | Image files |

### Identify Main File

**Common main file names:**
- `main.tex`
- `paper.tex`
- `document.tex`
- `sample-sigconf.tex`
- `template.tex`

**Identification methods:**
1. Check if filename matches common patterns
2. Search for files containing `\documentclass`
3. If multiple candidates exist, ask user to confirm

```bash
# Find files containing \documentclass
grep -l "\\documentclass" *.tex
```

## Step 2: Diagnose Issues

Present discovered issues to the user:

### Disorganized File Structure

- Multi-level directory nesting
- .tex files scattered across directories
- Unclear which file is the main file

### Redundant Content

Detect the following patterns and flag for cleanup:
- Filenames containing: `sample`, `example`, `demo`, `test`
- Comments containing: `sample`, `example`, `template`, `delete this`

### Dependency Issues

- Referenced `.sty`/`.cls` files missing
- Image/table reference paths incorrect

## Step 3: Ask for Conference Information

Ask the user for the following information:

```markdown
Please provide the following information (optional):

1. **Conference submission link** (recommended): Used to extract official submission requirements
2. **Conference name**: If no link available
3. **Other special requirements**: Such as page limits, anonymity requirements, etc.
```

## Step 4: Present Cleanup Plan

Present the cleanup plan to the user and wait for confirmation:

```markdown
## Cleanup Plan

### Issues Found
- [List diagnosed issues]

### Cleanup Approach
1. Main file: main.tex (clean example content)
2. Section separation: text/ directory
3. Resource directories: figures/, tables/, styles/

### Output Structure
[Show output directory structure]

Confirm execution? [Y/n]
```

## Step 5: Execute Cleanup

### Create Output Directory Structure

```bash
mkdir -p output/{text,figures,tables,styles}
```

### Clean Up Main File (main.tex)

**Keep:**
- `\documentclass` declaration
- Required package imports
- Core configuration (e.g., anonymous mode)

**Remove:**
- Example section content
- Verbose instructional comments
- Example author/title information

**Add:**
- Import sections with `\input{text/XX-section}`

**Example main.tex structure** (ACM template standard format):
```latex
\documentclass[...]{...}  % Keep original template document class

% Required packages (keep original template package declarations)

%% ============================================================================
%% Preamble: Before \begin{document}
%% ============================================================================

%% Title and author information
\title{Your Paper Title}
\author{Author Name}
\affiliation{...}

%% Abstract (in preamble, before \maketitle)
\begin{abstract}
% TODO: Write abstract content
\end{abstract}

%% CCS Concepts and Keywords (in preamble)
\begin{CCSXML}
<ccs2012>
   <concept>
       <concept_id>10010405.10010444.10010447</concept_id>
       <concept_desc>Applied computing~...</concept_desc>
       <concept_significance>500</concept_significance>
   </concept>
</ccs2012>
\end{CCSXML}

\ccsdesc[500]{Applied computing~...}
\keywords{keyword1, keyword2, keyword3}

%% ============================================================================
%% Document Body
%% ============================================================================
\begin{document}

\maketitle

%% Section content (imported from text/)
\input{text/01-introduction}
\input{text/02-related-work}
\input{text/03-method}
\input{text/04-experiments}
\input{text/05-conclusion}

\bibliographystyle{...}
\bibliography{references}

\end{document}
```

### KDD 2026 Anonymous Submission Special Configuration

For KDD 2026 (using ACM acmart template), add the `nonacm` option to the document class to remove footnotes:

```latex
%% ============================================================================
%% Document Class - KDD 2026 Anonymous Submission Configuration
%% Submission version: \documentclass[sigconf,anonymous,review,nonacm]{acmart}
%% Camera-ready: \documentclass[sigconf]{acmart}
%% ============================================================================
\documentclass[sigconf,anonymous,review,nonacm]{acmart}

%% ============================================================================
%% Disable ACM metadata (submission version only)
%% ============================================================================
\settopmatter{printacmref=false}  % Disable ACM Reference Format
\setcopyright{none}               % Disable copyright notice
\acmConference[]{}{}{}            % Clear conference info (removes footnote)
\acmYear{}                        % Clear year
\acmISBN{}                        % Clear ISBN
\acmDOI{}                         % Clear DOI

%% Content to restore for camera-ready version:
%% \acmConference[KDD '26]{Proceedings of the 30th ACM SIGKDD Conference on Knowledge Discovery and Data Mining}{August 09--13, 2026}{Jeju, Korea}
%% \acmISBN{978-1-4503-XXXX-X/26/08}
%% \acmDOI{10.1145/nnnnnnn.nnnnnnn}
```

### Create Section Files (text/)

Create independent .tex files for each section, **containing only section content** without `\begin{document}` etc.:

**text/01-introduction.tex**:
```latex
\section{Introduction}
% TODO: Write introduction content
```

**text/02-related-work.tex**:
```latex
\section{Related Work}
% TODO: Write related work content
```

**text/03-method.tex**:
```latex
\section{Method}
% TODO: Write method content
```

**text/04-experiments.tex**:
```latex
\section{Experiments}
% TODO: Write experiments content
```

**text/05-conclusion.tex**:
```latex
\section{Conclusion}
% TODO: Write conclusion content
```

**Important notes:**
- **Abstract** should be placed in main.tex preamble (before `\begin{document}`), after `\maketitle`
- **Files in text/ contain only sections**, starting with `\section{...}`
- Do not include `\begin{document}` or other wrappers in text/ files

### Copy Style Files (styles/)

Copy all `.sty` and `.cls` files from the original template to `styles/`:

```bash
find /tmp/latex-template-temp -type f \( -name "*.sty" -o -name "*.cls" \) -exec cp {} output/styles/ \;
```

**Note:** Maintain the original template's directory structure (e.g., `acmart/`), only move to `styles/`.

### Handle Images and Tables

```bash
# Copy image files
find /tmp/latex-template-temp -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" \) -exec cp {} output/figures/ \;

# Copy table files (if any)
find /tmp/latex-template-temp -type f -name "*.tex" | grep -i table | while read f; do cp "$f" output/tables/; done
```

### Create Example Table File

**Important:** Overleaf automatically deletes empty directories. To prevent the `tables/` directory from being deleted, create an example table file:

```bash
# Create example table file
cat > output/tables/example-table.tex << 'EOF'
% Example table file
% Can be deleted or replaced with your own tables

\begin{table}[h]
    \centering
    \caption{Example Table}
    \label{tab:example}
    \begin{tabular}{lccc}
        \toprule
        Method & Metric 1 & Metric 2 & Metric 3 \\
        \midrule
        Baseline & 85.3 & 12.4 & 0.92 \\
        Method A & 87.1 & 11.8 & 0.95 \\
        \textbf{Ours} & \textbf{89.4} & \textbf{10.2} & \textbf{0.97} \\
        \bottomrule
    \end{tabular}
\end{table}
EOF
```

**Notes:**
- If the original template already has table files, this step can be skipped
- The example table is only to prevent directory deletion; it can be deleted or replaced
- Reference tables in the paper using `\input{tables/example-table.tex}` or copy table content directly into section files

### Copy Bibliography

```bash
# Copy .bib files
find /tmp/latex-template-temp -type f -name "*.bib" -exec cp {} output/ \;
```

## Step 6: Generate README

### Information Source Priority

1. **Conference link provided by user** → Extract using WebFetch
2. **Template file comments** → Extract from .tex files
3. **Default inference** → Infer from `\documentclass`

### README Template

```markdown
# [Conference Name] Submission Template

## Template Information
- **Conference**: [Conference name]
- **Website**: [Conference link]
- **Template version**: [From template or website]
- **Document class**: [Extracted documentclass]

## Submission Requirements

### Page and Format
- **Page limit**: [From website or template]
- **Two-column/Single-column**: [Detect layout]
- **Font size**: [10pt/11pt etc.]

### Anonymity Requirements
- **Blind review required**: [Detect template mode]
- **Author information handling**: [Instructions]

### Compilation Requirements
- **Recommended compiler**: [XeLaTeX/pdfLaTeX/LuaLaTeX]
- **Special package requirements**: [If any]

## Overleaf Usage

### Upload Steps
1. Create a new project on Overleaf
2. Upload the entire `output/` directory
3. Set compiler to [specified compiler]
4. Click Recompile to test

### File Description
- `main.tex` - Main file, start here
- `text/` - Section content, edit as needed
- `figures/` - Place images here
- `tables/` - Place tables here
- `styles/` - Style files, no modification needed
- `references.bib` - Bibliography database

## Common Operations

### Adding Images
```latex
\begin{figure}[h]
    \centering
    \includegraphics[width=0.8\linewidth]{figures/your-image.pdf}
    \caption{Image caption}
    \label{fig:your-label}
\end{figure}
```

### Adding Tables
```latex
\begin{table}[h]
    \centering
    \begin{tabular}{|c|c|}
        \hline
        Column 1 & Column 2 \\
        \hline
        Content 1 & Content 2 \\
        \hline
    \end{tabular}
    \caption{Table caption}
    \label{tab:your-label}
\end{table}
```

### Adding References
Add entries to `references.bib` and cite in text using `\cite{key}`.

## Notes
- [Warnings extracted from template comments]
- [Important notes extracted from website]
```

### Extract Information from Website (if user provided a link)

Use WebFetch to get conference submission page content and extract:
- Page limits
- Anonymity requirements
- Format requirements
- Submission deadlines

## Step 7: Cleanup and Output

```bash
# Clean up temporary files
rm -rf /tmp/latex-template-temp

# Output completion message
echo "Template cleanup complete! Output directory: output/"
echo "Please upload the output/ directory to Overleaf to test compilation."
```

## Error Handling

| Error Scenario | Handling Approach |
|----------------|-------------------|
| Main file not found | List all .tex files, let user choose |
| Dependency file missing | Warn user, attempt to locate from template directory |
| Cannot extract conference info | Use default info from template, mark as [To be confirmed] |
| Website inaccessible | Fall back to template comments, prompt user to fill in manually |
| Extraction failed | Prompt user to check .zip file integrity |

## Common Conference Template Types

| Conference | Document Class | Notes |
|------------|---------------|-------|
| **KDD (ACM SIGKDD)** | `acmart` | **Anonymous submission requires `nonacm` option to remove footnotes** |
| ACM Conferences | `acmart` | Requires anonymous mode `\acmReview{anonymous}` |
| CVPR/ICCV | `cvpr` | Two-column, strict page limits |
| NeurIPS | `neurips_2025` | Anonymous review, no page limit |
| ICLR | `iclr2025_conference` | Two-column, requires session info |
| AAAI | `aaai25` | Two-column, 8 pages + references |

### KDD Anonymous Submission Configuration Notes

KDD 2026 uses the ACM acmart template and requires special configuration for anonymous submission:

**Submission version** (remove all ACM metadata footnotes):
```latex
\documentclass[sigconf,anonymous,review,nonacm]{acmart}
\settopmatter{printacmref=false}
\setcopyright{none}
\acmConference[]{}{}{}
\acmYear{}
\acmISBN{}
\acmDOI{}
```

**Camera-ready version** (restore ACM metadata):
```latex
\documentclass[sigconf]{acmart}
\settopmatter{printacmref=true}
\setcopyright{acmcopyright}
\acmConference[KDD '26]{...}{...}{...}
\acmYear{2026}
\acmISBN{978-1-4503-XXXX-X/26/08}
\acmDOI{10.1145/nnnnnnn.nnnnnnn}
```

## Quick Reference

### Detect Document Type
```bash
# Detect document class
grep "\\documentclass" main.tex

# Detect anonymous mode
grep -i "anonymous\|review\|blind" main.tex

# Detect page settings
grep "pagelimit\|pageLimit\|page_limit" main.tex
```

### Common Cleanup Patterns
```bash
# Remove example files
rm -f sample-* example-* demo-* test-*

# Remove temporary files
rm -f *.aux *.log *.out *.bbl *.blg
```
