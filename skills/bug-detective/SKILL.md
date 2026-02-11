---
name: bug-detective
description: This skill should be used when the user asks to "debug this", "fix this error", "investigate this bug", "troubleshoot this issue", "find the problem", "something is broken", "this isn't working", "why is this failing", or reports errors/exceptions/bugs. Provides systematic debugging workflow and common error patterns.
version: 0.1.0
---

# Bug Detective

A systematic debugging workflow for investigating and resolving code errors, exceptions, and failures. Provides structured debugging methods and common error pattern recognition.

## Core Philosophy

Debugging is a scientific problem-solving process that requires:
1. **Understand the problem** - Clearly define symptoms and expected behavior
2. **Gather evidence** - Collect error messages, logs, stack traces
3. **Form hypotheses** - Infer possible causes based on evidence
4. **Verify hypotheses** - Confirm or eliminate causes through experiments
5. **Resolve the issue** - Apply fixes and verify

## Debugging Workflow

### Step 1: Understand the Problem

Before starting to debug, clarify the following information:

**Required information to collect:**
- Complete error message content
- Exact location of the error (filename and line number)
- Reproduction steps (how to trigger the error)
- Expected behavior vs actual behavior
- Environment info (OS, versions, dependencies)

**Question template:**
```
1. What is the exact error message?
2. Which file and line does the error occur at?
3. How can this issue be reproduced? Provide detailed steps.
4. What was the expected result? What actually happened?
5. What recent changes might have introduced this issue?
```

### Step 2: Analyze Error Type

Choose a debugging strategy based on error type:

| Error Type | Characteristics | Debugging Method |
|-----------|----------------|-----------------|
| **Syntax Error** | Code cannot be parsed | Check syntax, bracket matching, quotes |
| **Import Error** | ModuleNotFoundError | Check module installation, path config |
| **Type Error** | TypeError | Check data types, type conversions |
| **Attribute Error** | AttributeError | Check if object attribute exists |
| **Key Error** | KeyError | Check if dictionary key exists |
| **Index Error** | IndexError | Check list/array index range |
| **Null Reference** | NoneType/NullPointerException | Check if variable is None |
| **Network Error** | ConnectionError/Timeout | Check network connection, URL, timeout settings |
| **Permission Error** | PermissionError | Check file permissions, user permissions |
| **Resource Error** | FileNotFoundError | Check if file path exists |

### Step 3: Locate the Problem Source

Use the following methods to locate the issue:

**1. Binary Search Method**
- Comment out half the code, check if the problem persists
- Progressively narrow the scope until the problematic code is found

**2. Log Tracing**
- Add print/logging statements at key locations
- Track variable value changes
- Confirm code execution path

**3. Breakpoint Debugging**
- Use debugger breakpoint functionality
- Step through code execution
- Inspect variable state

**4. Stack Trace Analysis**
- Find the call chain from the stack trace in the error message
- Determine the direct cause of the error
- Trace back to the root cause

### Step 4: Form and Verify Hypotheses

**Hypothesis framework:**
```
Hypothesis: [problem description] causes [error phenomenon]

Verification steps:
1. [verification method 1]
2. [verification method 2]

Expected results:
- If hypothesis is correct: [expected phenomenon]
- If hypothesis is wrong: [expected phenomenon]
```

### Step 5: Apply Fix

After fixing, verify:
1. The original error is resolved
2. No new errors have been introduced
3. Related functionality still works correctly
4. Tests added to prevent regression

## Python Common Error Patterns

### 1. Indentation Errors
### 2. Mutable Default Arguments
### 3. Closure Issues in Loops
### 4. Modifying a List While Iterating
### 5. Using `is` for String Comparison
### 6. Forgetting to Call `super().__init__()`

## JavaScript/TypeScript Common Error Patterns

### 1. `this` Binding Issues
### 2. Async Error Handling
### 3. Object Reference Comparison

## Bash/Zsh Common Error Patterns

### 1. Spacing Issues

```bash
# ❌ No spaces allowed in assignment
name = "John"  # Error: tries to run 'name' command

# ✅ Correct assignment
name="John"

# ❌ Missing spaces in conditional test
if[$name -eq 1]; then  # Error

# ✅ Correct
if [ $name -eq 1 ]; then
```

### 2. Quoting Issues

```bash
# ❌ Variables not expanded inside single quotes
echo 'The value is $var'  # Output: The value is $var

# ✅ Use double quotes
echo "The value is $var"  # Output: The value is actual_value

# ❌ Using backticks for command substitution (confusing)
result=`command`

# ✅ Use $()
result=$(command)
```

### 3. Unquoted Variables

```bash
# ❌ Unquoted variable, empty value causes errors
rm -rf $dir/*  # If dir is empty, deletes all files in current directory

# ✅ Always quote variables
[ -n "$dir" ] && rm -rf "$dir"/*

# Or use set -u to prevent undefined variables
set -u  # or set -o nounset
```

### 4. Variable Scope in Loops

```bash
# ❌ Pipe creates subshell, outer variable unchanged
cat file.txt | while read line; do
    count=$((count + 1))  # Outer count won't change
done
echo "Total: $count"  # Outputs 0

# ✅ Use process substitution or redirection
while read line; do
    count=$((count + 1))
done < file.txt
echo "Total: $count"  # Correct output
```

### 5. Array Operations

```bash
# ❌ Incorrect array access
arr=(1 2 3)
echo $arr[1]  # Outputs 1[1]

# ✅ Correct array access
echo ${arr[1]}  # Outputs 2
echo ${arr[@]}  # Outputs all elements
echo ${#arr[@]} # Outputs array length
```

### 6. String Comparison

```bash
# ❌ Using = for string comparison
if [ $name = "John" ]; then  # Not standard in some shells

# ✅ Use = or ==
if [ "$name" = "John" ]; then
if [[ "$name" == "John" ]]; then

# ❌ Using -eq for numeric comparison instead of =
if [ $age = 18 ]; then  # Wrong

# ✅ Use arithmetic operators for numeric comparison
if [ $age -eq 18 ]; then
if (( age == 18 )); then
```

### 7. Command Failure Continues Execution

```bash
# ❌ Execution continues after command failure
cd /nonexistent
rm file.txt  # Deletes file.txt in current directory

# ✅ Use set -e to exit on error
set -e  # or set -o errexit
cd /nonexistent  # Script exits here
rm file.txt

# Or check if command succeeded
cd /nonexistent || exit 1
```

## Common Debugging Commands

### Python pdb Debugger
### Node.js Inspector
### Git Bisect

### Bash Debugging

```bash
# Run script in debug mode
bash -x script.sh  # Print each command
bash -v script.sh  # Print command source
bash -n script.sh  # Syntax check, no execution

# Enable debugging within a script
set -x  # Enable command tracing
set -v  # Enable verbose mode
set -e  # Exit on error
set -u  # Error on undefined variables
set -o pipefail  # Fail if any command in pipe fails
```

## Preventive Debugging

### 1. Use Type Checking
### 2. Input Validation
### 3. Defensive Programming
### 4. Logging

## Debugging Checklist

### Before Starting
- [ ] Obtain the complete error message
- [ ] Record the stack trace of the error
- [ ] Confirm reproduction steps
- [ ] Understand expected behavior

### During Debugging
- [ ] Check recent code changes
- [ ] Use binary search to locate the issue
- [ ] Add logs to trace variables
- [ ] Verify hypotheses

### After Resolution
- [ ] Confirm the original error is fixed
- [ ] Test related functionality
- [ ] Add tests to prevent regression
- [ ] Document the problem and solution

## Additional Resources

### Reference Files

For detailed debugging techniques and patterns:
- **`references/python-errors.md`** - Python error details
- **`references/javascript-errors.md`** - JavaScript/TypeScript error details
- **`references/shell-errors.md`** - Bash/Zsh script error details
- **`references/debugging-tools.md`** - Debugging tools usage guide
- **`references/common-patterns.md`** - Common error patterns

### Example Files

Working debugging examples:
- **`examples/debugging-workflow.py`** - Complete debugging workflow example
- **`examples/error-handling-patterns.py`** - Error handling patterns
- **`examples/debugging-workflow.sh`** - Shell script debugging example
