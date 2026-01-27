# Konwinski Prize 2025 - AI GitHub Issue Resolver Competition

> **Competition URL**: https://www.kaggle.com/competitions/konwinski-prize
>
> **Official Website**: https://kprize.ai
>
> **Category**: Code Agent / AI Software Engineering
>
> **Tags**: `code-agent`, `LLM-agent`, `SWE-bench`, `GitHub-issues`, `automated-programming`

---

## Competition Brief

### Overview
The **Konwinski Prize** is a $1M competition founded by **Andy Konwinski** (co-founder of Databricks) that challenges teams to build an AI system capable of resolving **real GitHub issues**. The competition uses a contamination-free version of the SWE-bench benchmark with GitHub issues collected **after** submissions to prevent data leakage.

### Prize Structure
- **Grand Prize**: $1,000,000 for achieving >90% success rate (unclaimed)
- **Round 1 First Place**: $50,000
- **Total Prize Fund**: $1,225,000+
- **Participation**: 616 teams in Round 1

### Key Challenge
- **Goal**: Build an AI agent that can resolve real GitHub issues
- **Evaluation**: Performed on a **contamination-free test set** collected after submission
- **Success Criterion**: >90% issue resolution rate
- **Timeline**: Round 1 submissions closed July 2025; next round TBD

### Round 1 Results (July 2025)
| Rank | Participant | Score | Achievement |
|------|-------------|-------|-------------|
| 1st | Eduardo Rocha de Andrade | 7.5% (0.058242) | $50,000 prize |
| 2nd | camaro | ~6-7% | Public 2nd Place |
| 3rd | Anonymous | ~5-6% | Bronze Medal |
| 4th | Anonymous | ~5-6% | "Select-Patch-Verify-Test" |
| 5th | Anonymous | ~5% | Regex traceback analysis |
| 6th | quan16369 (Team of 2) | 0.8% | Gold Medal (3 correct, 2 wrong) |

**Key Insight**: The winning score of **7.5%** highlights how extremely difficult real-world GitHub issue resolution is, even for state-of-the-art AI systems.

### Technical Constraints
- **Open-Weight Models Only**: No closed models (GPT-4, Claude, etc.) allowed
- **No External API Calls**: Must run locally
- **Runtime Environment**: Limited computing resources
- **Test Set**: Hidden until evaluation, collected after submission freeze

---

## Top Solutions Analysis

### 1st Place: Eduardo Rocha de Andrade (7.5% success)

**Approach Summary**: Prompt engineering + careful test case generation

**Key Techniques**:
- Meticulous prompt engineering
- Automated test case generation (Fail-to-Pass tests)
- Careful patch validation
- Conservative submission strategy (only high-confidence fixes)

**Why It Won**:
- Quality over quantity: Only submitted fixes with highest confidence
- Proper test validation to ensure patches actually work
- Avoided the heavy penalties for wrong fixes

---

### 4th Place: "Select-Patch-Verify-Test" Pipeline

**Architecture**:
```
Select → Patch → Verify → Test → Choose
```

**Pipeline Steps**:

1. **Select**: Analyze bug reports + code tree to identify relevant files
2. **Patch**: Generate candidate patches using LLM
3. **Verify**: Multi-attempt LLM verification (measure confidence)
4. **Test**: Generate F2P (Fail-to-Pass) tests
   - Tests must fail on original code
   - Tests must pass after patch application
5. **Choose**: Rule-based scoring with strict filtering

**Key Innovation**: The **mandatory testing phase** was crucial for objective validation.

---

### 5th Place: Regex Traceback Analysis

**Key Strategy**:
- Use regex to extract traceback information from error messages
- Focus LLM attention on specific error locations
- More targeted patch generation
- Reduced context window usage

**Effectiveness**: Improved localization of bugs, less hallucination.

---

### 6th Place: Select-Patch-Verify-Choose (quan16369)

**Performance**:
- Private LB: 0.823% (3 correct, 2 wrong, 115 skipped)
- Public LB: -0.0097% (1 correct, 1 wrong, 69 skipped)

**Core Pipeline**:
```python
Select → Patch → Verify (Multi-attempt) → Choose (Logic)
```

**Key Techniques**:

#### 1. Multi-Attempt Verification for Confidence Assessment
```python
# Verify each patch multiple times
VALIDATION_COPY_COUNT = 3  # or more

# Only trust patches with high consensus
judgments_aggregated = [
    [],                      # Candidate 1: No consensus
    [True, True, True],      # Candidate 2: STRONG SIGNAL
    [],                      # Candidate 3: No consensus
    # ... etc
]
```

#### 2. Sophisticated Scoring Function
```python
def calculate_patch_score(patch, judgments):
    # Heavy penalty if invalid or no Yes votes
    if not is_valid(patch) or judgments.count(True) == 0:
        return -LARGE_PENALTY

    # Base score = (Yes votes)² × weight
    score = (judgments.count(True) ** 2) * 5.0

    # EXPONENTIAL size penalty - forces concise solutions
    score -= (np.exp(len(patch) / 10) - 1)

    return score
```

**Scoring Criteria**:
- ✅ Positive score
- ✅ Top percentile (e.g., top 1%)
- ✅ Significantly outperforms second-best
- ✅ Minimum "Yes" vote threshold
- ❌ Otherwise SKIP for safety

#### 3. Size Penalty Strategy
- **Exponential penalty** for patch length
- Forces LLM to find minimal, precise solutions
- Prevents unnecessary changes that cause side effects

**Why Only 6th Place**:
- No **objective testing phase** (unlike top 5)
- Relied only on LLM self-verification (hallucination risk)
- Missed the importance of F2P tests

---

### Common Themes Across Top Solutions

#### What Worked:
1. **Conservative Strategy**: Better to skip than be wrong
   - Wrong fixes: Heavy penalty
   - Skips: Small penalty
   - **Insight**: Quality > Quantity

2. **Multi-Attempt Verification**
   - Don't trust single LLM judgment
   - Aggregate multiple verification attempts
   - Use consensus as confidence metric

3. **Size Penalties**
   - Exponential penalty for large patches
   - Forces minimal, targeted fixes
   - Reduces side effects

4. **Test Case Generation** (Critical for top places)
   - Generate Fail-to-Pass tests
   - Must fail on original code
   - Must pass after patching
   - Objective validation (not subjective LLM judgment)

#### What Didn't Work:
1. **Aggressive Fixing**: Trying to fix everything led to more wrong fixes
2. **Single Verification**: Trusting one LLM judgment caused hallucinations
3. **Large Patches**: More code = more chance of breaking something
4. **No Objective Tests**: Pure LLM verification is unreliable

---

## Code Templates

### Template 1: Select-Patch-Verify-Choose Pipeline

```python
import numpy as np
from typing import List, Tuple

class KonwinskiPrizeAgent:
    def __init__(self, llm_client):
        self.llm = llm_client
        self.VALIDATION_COPY_COUNT = 3
        self.SIZE_PENALTY_WEIGHT = 0.1

    def select_relevant_code(self, issue: str, code_tree: dict) -> List[str]:
        """Select relevant files using LLM analysis"""
        prompt = f"""
        Analyze this GitHub issue and identify relevant files:

        Issue: {issue}

        Code Tree:
        {self._format_code_tree(code_tree)}

        Return a list of relevant files with brief explanations.
        """
        # Multiple selection attempts for diversity
        selections = []
        for _ in range(3):
            selection = self.llm.generate(prompt)
            selections.append(selection)
        return selections

    def generate_patches(self, issue: str, selected_code: str) -> List[str]:
        """Generate multiple candidate patches"""
        prompt = f"""
        GitHub Issue: {issue}

        Relevant Code:
        {selected_code}

        Generate 5 different git diff patches to fix this issue.
        Each patch should be minimal and targeted.
        """
        patches = self.llm.generate(prompt)
        return self._parse_patches(patches)

    def verify_patch(self, issue: str, patch: str) -> List[bool]:
        """Multi-attempt verification for confidence assessment"""
        judgments = []

        for _ in range(self.VALIDATION_COPY_COUNT):
            prompt = f"""
            Issue: {issue}

            Proposed Patch:
            {patch}

            Does this patch correctly fix the issue? Answer Yes or No.
            """
            response = self.llm.generate(prompt)
            is_yes = "yes" in response.lower()
            judgments.append(is_yes)

        return judgments

    def calculate_patch_score(self, patch: str, judgments: List[bool]) -> float:
        """Calculate score with exponential size penalty"""
        # Heavy penalty if invalid or no Yes votes
        if judgments.count(True) == 0:
            return -1000.0

        # Base score = (Yes votes)² × weight
        score = (judgments.count(True) ** 2) * 5.0

        # Exponential size penalty
        score -= (np.exp(len(patch) / 10) - 1)

        return score

    def choose_best_patch(self, patches: List[str], all_judgments: List[List[bool]]) -> str:
        """Choose best patch using scoring function"""
        scored_patches = []

        for patch, judgments in zip(patches, all_judgments):
            score = self.calculate_patch_score(patch, judgments)
            scored_patches.append((patch, score, judgments))

        # Sort by score
        scored_patches.sort(key=lambda x: x[1], reverse=True)

        # Apply strict criteria
        if not scored_patches:
            return None

        best_patch, best_score, best_judgments = scored_patches[0]

        # Must meet all criteria
        if best_score <= 0:
            return None

        if len(scored_patches) > 1:
            second_score = scored_patches[1][1]
            if best_score - second_score < 10:  # Must be significantly better
                return None

        return best_patch

    def solve_issue(self, issue: str, code_tree: dict) -> str:
        """Main pipeline: Select → Patch → Verify → Choose"""
        # Step 1: Select relevant code
        selections = self.select_relevant_code(issue, code_tree)
        selected_code = selections[0]  # Use best selection

        # Step 2: Generate patches
        patches = self.generate_patches(issue, selected_code)

        # Step 3: Verify patches
        all_judgments = []
        for patch in patches:
            judgments = self.verify_patch(issue, patch)
            all_judgments.append(judgments)

        # Step 4: Choose best patch
        best_patch = self.choose_best_patch(patches, all_judgments)

        return best_patch  # Returns None if no patch is good enough
```

### Template 2: With Test Case Generation (Top 5 Approach)

```python
class TestValidatedAgent(KonwinskiPrizeAgent):
    """Enhanced agent with Fail-to-Pass test generation"""

    def generate_f2p_test(self, issue: str, code: str) -> str:
        """Generate a test that fails on original code"""
        prompt = f"""
        GitHub Issue: {issue}

        Original Code:
        {code}

        Generate a unit test that:
        1. FAILS on the current (buggy) code
        2. PASSES when the bug is fixed

        The test should be minimal and focused on the specific bug.
        """
        test_code = self.llm.generate(prompt)
        return test_code

    def validate_patch_with_test(self, patch: str, test_code: str, original_code: str) -> bool:
        """Objective validation: test must fail on original, pass on patched"""
        # Apply patch to get patched code
        patched_code = self._apply_patch(original_code, patch)

        # Run test on original code (should FAIL)
        original_result = self._run_test(test_code, original_code)
        if original_result != "FAIL":
            return False  # Test doesn't fail on buggy code!

        # Run test on patched code (should PASS)
        patched_result = self._run_test(test_code, patched_code)
        if patched_result != "PASS":
            return False  # Test doesn't pass on fixed code!

        return True

    def solve_issue_with_tests(self, issue: str, code_tree: dict) -> str:
        """Pipeline with test validation"""
        # Select + Patch as before
        selections = self.select_relevant_code(issue, code_tree)
        patches = self.generate_patches(issue, selections[0])

        # Generate test
        test_code = self.generate_f2p_test(issue, selections[0])

        # Validate each patch with test
        valid_patches = []
        for patch in patches:
            if self.validate_patch_with_test(patch, test_code, selections[0]):
                valid_patches.append(patch)

        # Use verification to choose among valid patches
        if not valid_patches:
            return None

        # Apply verification logic only to valid patches
        all_judgments = []
        for patch in valid_patches:
            judgments = self.verify_patch(issue, patch)
            all_judgments.append(judgments)

        return self.choose_best_patch(valid_patches, all_judgments)
```

### Template 3: Traceback Analysis (5th Place Approach)

```python
import re

class TracebackAwareAgent(KonwinskiPrizeAgent):
    """Agent that uses regex to extract traceback info"""

    def extract_traceback(self, issue: str) -> dict:
        """Extract traceback information using regex"""
        traceback_patterns = [
            r'File "([^"]+)", line (\d+), in (\w+)',
            r'(\w+Error): (.+)',
            r'Traceback \(most recent call last\):',
        ]

        traceback_info = {
            'files': [],
            'lines': [],
            'functions': [],
            'error_types': [],
            'error_messages': [],
        }

        for pattern in traceback_patterns:
            matches = re.findall(pattern, issue)
            # Parse matches into traceback_info

        return traceback_info

    def select_with_traceback(self, issue: str, code_tree: dict) -> List[str]:
        """Use traceback to prioritize files"""
        traceback_info = self.extract_traceback(issue)

        # Prioritize files mentioned in traceback
        prioritized_files = []
        for file_path in traceback_info['files']:
            if file_path in code_tree:
                prioritized_files.append(file_path)

        # Add context from nearby files
        for file_path in prioritized_files:
            # Add sibling files, parent directories, etc.

        return prioritized_files

    def generate_targeted_patch(self, issue: str, traceback_info: dict, code: str) -> str:
        """Generate patch focused on traceback location"""
        prompt = f"""
        Issue: {issue}

        Error Location:
        - File: {traceback_info['files']}
        - Line: {traceback_info['lines']}
        - Function: {traceback_info['functions']}

        Error Type: {traceback_info['error_types'][0]}
        Error Message: {traceback_info['error_messages'][0]}

        Code:
        {code}

        Generate a minimal git diff patch to fix this specific error.
        Focus on the exact location mentioned in the traceback.
        """
        patch = self.llm.generate(prompt)
        return patch
```

---

## Best Practices

### 1. Conservative Strategy > Aggressive Fixing

**Key Insight**: The evaluation heavily penalizes wrong fixes more than skips.

```python
# Bad: Try to fix everything
if patch_score > 0:
    submit(patch)  # Might submit low-quality patches

# Good: Only submit when very confident
if (patch_score > 0 and
    patch_score > second_best_score * 2 and  # Significantly better
    min_yes_votes >= 3):  # Strong consensus
    submit(patch)
else:
    skip()  # Better safe than sorry
```

### 2. Multi-Attempt Verification is Essential

**Key Insight**: Single LLM judgments are unreliable due to hallucination.

```python
# Bad: Trust single verification
if verify(patch) == "Yes":
    trust(patch)

# Good: Aggregate multiple verifications
verifications = [verify(patch) for _ in range(5)]
yes_count = sum(1 for v in verifications if v == "Yes")
if yes_count >= 4:  # Strong consensus
    trust(patch)
```

### 3. Exponential Size Penalties Work

**Key Insight**: Larger patches have exponentially higher risk of side effects.

```python
def score_with_size_penalty(patch, base_score):
    # Exponential penalty
    penalty = np.exp(len(patch) / 10) - 1
    return base_score - penalty

# This forces the LLM to find minimal solutions
# rather than rewriting entire files
```

### 4. Objective Testing > Subjective Verification

**Key Insight**: LLM self-verification is subjective; tests are objective.

```python
# Less reliable: Pure LLM verification
if llm_says_patch_is_good(patch):
    submit(patch)

# More reliable: Objective test validation
if test_fails_on_original(code) and test_passes_on_patched(code, patch):
    submit(patch)
```

### 5. Traceback Analysis Improves Localization

**Key Insight**: Error tracebacks tell you exactly where to look.

```python
# Use regex to extract:
# - File paths
# - Line numbers
# - Function names
# - Error types

# Focus LLM attention on these specific locations
# rather than analyzing entire codebase
```

### 6. Context Window Management

**Key Insight**: Limited context means you must prioritize information.

```python
# Bad: Send entire codebase
context = entire_repository  # Too large!

# Good: Send only relevant files
context = select_top_k_files(issue, code_tree, k=10)

# Better: Send only relevant functions
context = select_top_k_functions(issue, code_tree, k=5)
```

### 7. Model Selection

**Open-Weight Models** (allowed in competition):
- **Qwen2.5-Coder-32B-Instruct**: Good balance of capability and size
- **DeepSeek-Coder-V2**: Strong coding performance (may be too large)
- **CodeLlama-34B**: Reliable but older

**Strategies**:
- Use smaller models for selection/verification
- Use larger models for patch generation
- Ensemble multiple models if compute allows

---

## Lessons Learned

### What Round 1 Revealed

1. **Real-World Code is Much Harder Than Benchmarks**
   - SWE-bench Verified: ~75% top score
   - Konwinski Prize: 7.5% top score
   - **Gap**: Contamination-free, recent issues are significantly harder

2. **Objective Testing is Non-Negotiable**
   - All top 5 solutions used test generation
   - 6th place (no tests) dropped to 0.8%
   - LLM verification alone is insufficient

3. **Quality > Quantity**
   - Best strategy: Fix few issues correctly
   - Worst strategy: Fix many issues incorrectly
   - **Insight**: Skip when uncertain

4. **Current AI Limitations**
   - Even best open models struggle with real issues
   - 90% target remains far off
   - Significant room for improvement

### Future Directions

1. **Better Test Generation**
   - Automatic test case synthesis
   - Edge case coverage
   - Regression prevention

2. **Improved Retrieval**
   - Better code search
   - Semantic similarity matching
   - Issue-to-code mapping

3. **Multi-Agent Systems**
   - Specialized agents for different tasks
   - Agent communication and consensus
   - Hierarchical decision making

4. **Better Models**
   - Larger context windows
   - Improved code understanding
   - Better reasoning capabilities

---

## Resources

### Official Resources
- **Competition Page**: https://www.kaggle.com/competitions/konwinski-prize
- **Official Website**: https://kprize.ai
- **Strategy Guide**: https://github.com/raymyers/konwinski-prize-strategy-guide

### Solution Writeups
- **1st Place**: Eduardo Rocha de Andrade (July 2025)
- **2nd Place**: camaro (Public 2nd Place)
- **3rd Place**: Anonymous
- **4th Place**: "Select-Patch-Verify-Test"
- **5th Place**: Regex traceback analysis
- **6th Place**: https://github.com/quan16369/Kaggle-Konwinski-Prize-6th-Place-Solution-

### Related Benchmarks
- **SWE-bench**: https://www.swebench.com/
- **SWE-bench Verified**: https://www.swebench.com/verified
- **SWE-agent**: https://github.com/princeton-nlp/SWE-agent

### Technical Papers
- SWE-bench Technical Report
- "Dissecting the SWE-Bench Leaderboards" (2025)
- "SWE-RM: Execution-free reward model for SWE agents"
- "DeepSWE: Reinforcement learning for code agents"

---

## Summary

The **Konwinski Prize** is a groundbreaking competition that revealed the **significant gap** between AI performance on contaminated benchmarks and real-world GitHub issue resolution. With a winning score of only **7.5%**, the competition demonstrated that:

1. **Current AI is far from 90% automated software engineering**
2. **Objective testing is essential** for reliable code generation
3. **Conservative strategies beat aggressive approaches**
4. **Real-world coding remains an enormous challenge** for AI systems

The competition's focus on **open-weight models**, **contamination-free evaluation**, and **real GitHub issues** makes it a valuable benchmark for the field of AI software engineering.

---

**Last Updated**: January 2026
**Sources**: Kaggle competition page, solution writeups, GitHub repositories, and news articles
