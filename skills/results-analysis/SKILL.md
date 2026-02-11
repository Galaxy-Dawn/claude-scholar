---
name: results-analysis
description: This skill should be used when the user asks to "analyze experimental results", "generate results section", "statistical analysis of experiments", "compare model performance", "create results visualization", or mentions connecting experimental data to paper writing. Provides comprehensive guidance for analyzing ML/AI experimental results and generating paper-ready content.
tags: [Research, Analysis, Statistics, Visualization, Paper Writing]
version: 0.1.0
---

# Results Analysis for ML/AI Research

A systematic experimental results analysis workflow connecting experimental data to paper writing.

## Core Features

This skill provides three core capabilities:

1. **Experimental Data Analysis** - Read and analyze experimental data in various formats
2. **Statistical Validation** - Perform statistical significance tests and performance comparisons
3. **Paper Content Generation** - Generate text and visualizations for the Results section

## When to Use

Use this skill when you need to:
- Analyze experimental results (CSV, JSON, TensorBoard logs)
- Generate the Results section of a paper
- Compare performance across multiple models
- Perform statistical significance tests
- Create publication-quality visualizations
- Validate the reliability of experimental results

## Workflow

### Standard Analysis Pipeline

```
Data Loading → Data Validation → Statistical Analysis → Visualization → Writing → Quality Check
```

### Step 1: Data Loading and Validation

**Supported Data Formats:**
- CSV files - Tabular data
- JSON files - Structured results
- TensorBoard logs - Training curves
- Python pickle - Complex objects

**Data Validation Checks:**
- Completeness check - Missing values, outliers
- Consistency check - Data format, units
- Reproducibility check - Random seeds, version info

Select appropriate tools for data loading and preliminary validation based on data format.

### Step 2: Statistical Analysis

**Basic Statistics:**
- Mean
- Standard Deviation
- Standard Error
- Confidence Interval

**Significance Tests:**
- t-test - Two-group comparison
- ANOVA - Multi-group comparison
- Wilcoxon test - Non-parametric test
- Bonferroni correction - Multiple comparison correction

Select appropriate statistical tests based on data characteristics.

**Key Principles:**
- Report complete statistical information (mean ± std/SE)
- Specify the test method and significance level used
- Report p-values and effect sizes
- Consider multiple comparison issues

See `references/statistical-methods.md` for the complete statistical methods guide.

### Step 3: Model Performance Comparison

**Comparison Dimensions:**
- Accuracy/Performance metrics
- Training time/Inference speed
- Model complexity/Parameter count
- Robustness/Generalization ability

**Comparison Methods:**
- Baseline comparison - Compare with existing methods
- Ablation study - Validate component contributions
- Cross-dataset validation - Test generalization

Systematically compare performance across different methods, ensuring fair comparison.

### Step 4: Visualization

**Publication-Quality Visualization Requirements:**
- Vector format (PDF/EPS)
- Colorblind-friendly palette
- Clear labels and legends
- Appropriate error bars
- Readable in black-and-white print

**Common Chart Types:**
- Line chart - Training curves, trend analysis
- Bar chart - Performance comparison
- Box plot - Distribution display
- Heatmap - Correlation analysis
- Scatter plot - Relationship display

Use appropriate visualization tools to generate publication-quality figures.

See `references/visualization-best-practices.md` for the visualization guide.

### Step 5: Writing the Results Section

**Results Section Structure:**

```markdown
## Results

### Overview of Main Findings
[1-2 paragraphs summarizing core results]

### Experimental Setup
[Brief description of experimental configuration; details in appendix]

### Performance Comparison
[Comparison with baseline methods, including tables and figures]

### Ablation Study
[Validate contributions of each component]

### Statistical Significance
[Report statistical test results]

### Qualitative Analysis
[Case studies, visualization examples]
```

**Writing Principles:**
- Clearly state the hypothesis each experiment validates
- Guide readers to observe key phenomena: "Figure X shows..."
- Report complete statistical information
- Honestly report limitations

See `references/results-writing-guide.md` for the complete writing guide.

### Step 6: Quality Check

**Checklist:**
- [ ] All values include error bars/confidence intervals
- [ ] Statistical test methods are specified
- [ ] Figures are clear and readable (including black-and-white print)
- [ ] Hyperparameter search ranges are reported
- [ ] Computational resources are specified (GPU type, time)
- [ ] Random seed settings are specified
- [ ] Results are reproducible (code/data available)

## Common Mistakes and Pitfalls

### Statistical Errors

❌ **Wrong approach:**
- Reporting only the best results (cherry-picking)
- Confusing standard deviation and standard error
- Not reporting statistical significance
- Not correcting for multiple comparisons

✅ **Correct approach:**
- Report all experimental results
- Clearly specify whether standard deviation or standard error is used
- Perform appropriate statistical tests
- Use Bonferroni or similar correction methods

### Visualization Errors

❌ **Wrong approach:**
- Using non-colorblind-friendly palettes
- Y-axis not starting from 0 (exaggerating differences)
- Missing error bars
- Overly complex figures

✅ **Correct approach:**
- Use Okabe-Ito or Paul Tol palettes
- Set reasonable axis ranges
- Include error bars and confidence intervals
- Keep figures clean and clear

### Writing Errors

❌ **Wrong approach:**
- Over-interpreting results
- Not describing experimental setup
- Hiding negative results
- Missing statistical information

✅ **Correct approach:**
- Objectively describe observed phenomena
- Provide sufficient experimental details
- Honestly report all results
- Report complete statistical information

See `references/common-pitfalls.md` for the complete error patterns and fixes.

## Integration with Paper Writing

### Collaboration with ml-paper-writing Skill

This skill focuses on experimental results analysis and works in tandem with the `ml-paper-writing` skill:

**results-analysis handles:**
- Data analysis and statistical tests
- Visualization generation
- Results interpretation

**ml-paper-writing handles:**
- Complete paper structure
- Citation management
- Conference format requirements

**Workflow Integration:**
```
Experiments complete → results-analysis analyzes
    ↓
Generate analysis report and visualizations
    ↓
ml-paper-writing integrates into paper
    ↓
Complete Results section
```

### Output Format

After analysis, the following are generated:

1. **Analysis Report** (`analysis-report.md`)
   - Statistical summary
   - Key findings
   - Suggested figures

2. **Visualization Files** (`figures/`)
   - PDF format figures
   - Standalone figure captions

3. **Results Draft** (`results-draft.md`)
   - Text ready for direct use in the paper
   - Includes figure references

## Examples and Templates

### Example Files

Refer to the `examples/` directory for complete examples:

- **`example-analysis-report.md`** - Complete analysis report example
- **`example-results-section.md`** - Paper Results section example

### Workflow Overview

The complete analysis pipeline includes:

1. **Data Loading** - Read results from experiment output files
2. **Statistical Analysis** - Compute basic statistics and perform significance tests
3. **Visualization** - Create publication-quality figures
4. **Report Generation** - Integrate analysis results and visualizations

See the guides in the `references/` directory for detailed methods and best practices.

## Reference Resources

### Detailed Guides

- **`references/statistical-methods.md`** - Complete statistical methods guide
- **`references/results-writing-guide.md`** - Results section writing standards
- **`references/visualization-best-practices.md`** - Visualization best practices
- **`references/common-pitfalls.md`** - Common errors and fixes

### External Resources

- [Nature Statistics Checklist](https://www.nature.com/documents/nr-reporting-summary-flat.pdf)
- [Science Reproducibility Guidelines](https://www.science.org/content/page/science-journals-editorial-policies)
- [NeurIPS Paper Checklist](https://neurips.cc/Conferences/2025/PaperInformation/PaperChecklist)

## Best Practices Summary

### Data Analysis

✅ **Recommended:**
- Run experiments multiple times (at least 3-5 runs)
- Report complete statistical information
- Use appropriate statistical tests
- Check data completeness

❌ **Prohibited:**
- Cherry-picking best results
- Ignoring statistical significance
- Hiding negative results
- Not reporting experimental setup

### Visualization

✅ **Recommended:**
- Use vector format
- Colorblind-friendly palettes
- Include error bars
- Clear labels

❌ **Prohibited:**
- Raster formats (PNG/JPG)
- Misleading axis scales
- Overly complex figures
- Missing legends

### Writing

✅ **Recommended:**
- Objectively describe results
- Provide sufficient detail
- Honestly report limitations
- Guide reader attention

❌ **Prohibited:**
- Over-interpretation
- Hiding details
- Exaggerating effects
- Vague descriptions

## Summary

This skill provides a systematic experimental results analysis workflow:

1. **Data Loading and Validation** - Ensure data quality
2. **Statistical Analysis** - Perform appropriate statistical tests
3. **Model Comparison** - Systematic performance comparison
4. **Visualization** - Publication-quality figures
5. **Writing** - Results section content
6. **Quality Check** - Ensure reproducibility

Following these principles produces high-quality, reproducible experimental results analysis that meets top conference standards.
