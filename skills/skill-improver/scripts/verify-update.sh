#!/bin/bash
# verify-update.sh - Verify skill integrity after applying updates
# Part of skill-improver

# Usage: ./verify-update.sh <skill-path>
# Example: ./verify-update.sh ~/.claude/skills/git-workflow

set -euo pipefail

# Check if path provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <skill-path>"
    echo "Example: $0 ~/.claude/skills/git-workflow"
    exit 1
fi

SKILL_PATH="$1"
SKILL_NAME=$(basename "$SKILL_PATH")
SKILL_FILE="${SKILL_PATH}/SKILL.md"

# Verification results
PASS=0
FAIL=0
WARN=0

echo "================================"
echo "Skill Update Verification"
echo "================================"
echo "Skill: ${SKILL_NAME}"
echo "Path: ${SKILL_PATH}"
echo ""

# Check 1: SKILL.md exists
echo "Check 1: SKILL.md exists"
if [ -f "$SKILL_FILE" ]; then
    echo "✅ PASS: SKILL.md found"
    ((PASS++))
else
    echo "❌ FAIL: SKILL.md not found"
    ((FAIL++))
    echo ""
    echo "Verification Summary:"
    echo "  Passed: ${PASS}"
    echo "  Failed: ${FAIL}"
    echo "  Warnings: ${WARN}"
    exit 1
fi

echo ""

# Check 2: YAML frontmatter valid
echo "Check 2: YAML frontmatter valid"
if command -v yq &> /dev/null; then
    # Use yq if available for proper YAML validation
    FRONTMAFTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$SKILL_FILE")
    if echo "$FRONTMAFTER" | yq eval '.' > /dev/null 2>&1; then
        echo "✅ PASS: YAML frontmatter is valid"
        ((PASS++))
    else
        echo "❌ FAIL: Invalid YAML frontmatter"
        ((FAIL++))
    fi
else
    # Fallback: basic check for name and description fields
    if grep -q "^name:" "$SKILL_FILE" && grep -q "^description:" "$SKILL_FILE"; then
        echo "✅ PASS: YAML frontmatter has required fields (name, description)"
        ((PASS++))
    else
        echo "❌ FAIL: YAML frontmatter missing required fields"
        ((FAIL++))
    fi
fi

echo ""

# Check 3: Directory structure
echo "Check 3: Directory structure"
DIRS_OK=true

if [ -d "${SKILL_PATH}/references" ]; then
    echo "  ✅ references/ exists"
else
    echo "  ℹ️  references/ not found (optional)"
    ((WARN++))
fi

if [ -d "${SKILL_PATH}/examples" ]; then
    echo "  ✅ examples/ exists"
else
    echo "  ℹ️  examples/ not found (optional)"
    ((WARN++))
fi

if [ -d "${SKILL_PATH}/scripts" ]; then
    echo "  ✅ scripts/ exists"
    # Check if scripts are executable (macOS compatible)
    SCRIPT_COUNT=$(find "${SKILL_PATH}/scripts" -type f | wc -l | tr -d ' ')
    EXEC_COUNT=0
    for script in "${SKILL_PATH}/scripts"/*; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            ((EXEC_COUNT++))
        fi
    done
    if [ "$SCRIPT_COUNT" -gt 0 ] && [ "$EXEC_COUNT" -eq "$SCRIPT_COUNT" ]; then
        echo "  ✅ All scripts are executable"
    elif [ "$SCRIPT_COUNT" -gt 0 ]; then
        echo "  ⚠️  Some scripts are not executable (${EXEC_COUNT}/${SCRIPT_COUNT} executable)"
        ((WARN++))
    fi
else
    echo "  ℹ️  scripts/ not found (optional)"
fi

if [ "$DIRS_OK" = true ] || [ ! -d "${SKILL_PATH}/references" ] && [ ! -d "${SKILL_PATH}/examples" ]; then
    echo "✅ PASS: Directory structure is valid"
    ((PASS++))
else
    echo "⚠️  WARN: Optional directories missing"
fi

echo ""

# Check 4: SKILL.md size (progressive disclosure check)
echo "Check 4: SKILL.md size (progressive disclosure)"
WORD_COUNT=$(wc -w < "$SKILL_FILE" | tr -d ' ')

if [ "$WORD_COUNT" -lt 3000 ]; then
    echo "✅ PASS: SKILL.md is ${WORD_COUNT} words (good progressive disclosure)"
    ((PASS++))
elif [ "$WORD_COUNT" -lt 5000 ]; then
    echo "⚠️  WARN: SKILL.md is ${WORD_COUNT} words (could be more concise)"
    ((WARN++))
else
    echo "❌ FAIL: SKILL.md is ${WORD_COUNT} words (too long, should use references/)"
    ((FAIL++))
fi

echo ""

# Check 5: No broken references (basic check)
echo "Check 5: Referenced files exist"
BROKEN_REFS=0

# Extract references from SKILL.md
# Look for patterns like "See `references/file.md`" or "**`references/pattern.md`**"
REF_FILES=$(grep -oE 'references/[-_a-zA-Z0-9\.]+' "$SKILL_FILE" | sort -u || true)

if [ -n "$REF_FILES" ]; then
    for ref in $REF_FILES; do
        REF_PATH="${SKILL_PATH}/${ref}"
        if [ -f "$REF_PATH" ]; then
            echo "  ✅ ${ref} exists"
        else
            echo "  ❌ ${ref} referenced but not found"
            ((BROKEN_REFS++))
        fi
    done

    if [ "$BROKEN_REFS" -eq 0 ]; then
        echo "✅ PASS: All referenced files exist"
        ((PASS++))
    else
        echo "❌ FAIL: ${BROKEN_REFS} referenced file(s) not found"
        ((FAIL++))
    fi
else
    echo "ℹ️  No references found in SKILL.md"
    echo "✅ PASS: No broken references"
    ((PASS++))
fi

echo ""

# Check 6: Writing style (imperative form check)
echo "Check 6: Writing style (imperative form check)"
SECOND_PERSON=$(grep -iE "you should|you need|you can|you must|you'll|your" "$SKILL_FILE" | wc -l | tr -d ' ')

if [ "$SECOND_PERSON" -eq 0 ]; then
    echo "✅ PASS: No second-person language found"
    ((PASS++))
elif [ "$SECOND_PERSON" -lt 5 ]; then
    echo "⚠️  WARN: ${SECOND_PERSON} instance(s) of second-person language"
    ((WARN++))
    # Still count as pass for now
    ((PASS++))
else
    echo "❌ FAIL: ${SECOND_PERSON} instances of second-person language"
    echo "   (should use imperative form)"
    ((FAIL++))
fi

echo ""

# Check 7: Description quality (basic check)
echo "Check 7: Description quality"
DESCRIPTION=$(grep "^description:" "$SKILL_FILE" | head -1)

if [ -n "$DESCRIPTION" ]; then
    # Check for third person
    if echo "$DESCRIPTION" | grep -qi "this skill should be used when"; then
        echo "  ✅ Uses third-person format"
        DESC_OK=true
    else
        echo "  ❌ Does not use third-person format"
        DESC_OK=false
    fi

    # Check length (100-300 characters ideal)
    DESC_LEN=$(echo "$DESCRIPTION" | cut -d: -f2- | wc -c | tr -d ' ')
    if [ "$DESC_LEN" -ge 100 ] && [ "$DESC_LEN" -le 300 ]; then
        echo "  ✅ Description length is ${DESC_LEN} characters (good)"
    elif [ "$DESC_LEN" -lt 100 ]; then
        echo "  ⚠️  Description is ${DESC_LEN} characters (too short)"
        DESC_OK=false
    else
        echo "  ⚠️  Description is ${DESC_LEN} characters (too long)"
        DESC_OK=false
    fi

    if [ "$DESC_OK" = true ]; then
        echo "✅ PASS: Description quality is good"
        ((PASS++))
    else
        echo "⚠️  WARN: Description could be improved"
        ((WARN++))
        # Still count as pass for basic check
        ((PASS++))
    fi
else
    echo "❌ FAIL: No description found in frontmatter"
    ((FAIL++))
fi

echo ""
echo "================================"
echo "Verification Summary"
echo "================================"
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo "  Warnings: ${WARN}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo "✅ Verification PASSED"
    echo "   Skill structure is valid."
    exit 0
else
    echo "❌ Verification FAILED"
    echo "   Please review and fix the failed checks."
    exit 1
fi
