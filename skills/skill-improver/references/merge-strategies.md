# Merge Strategies for Skill Updates

Detailed strategies for intelligently merging multiple improvements to the same skill files.

## Overview

When applying improvements from an improvement plan, multiple changes may affect the same file or even the same lines. This document defines strategies for detecting conflicts, resolving them, and applying updates in the correct order.

## Priority-Based Merging

### Priority Order

Changes are applied in strict priority order:

1. **High Priority** - Critical issues that must be fixed
2. **Medium Priority** - Important improvements
3. **Low Priority** - Nice-to-have enhancements

### Rationale

- High priority changes often fix fundamental issues
- Applying them first ensures a solid foundation
- Lower priority changes may depend on high priority fixes
- Prevents wasted effort on changes that might be reverted

## Per-File Merge Strategy

### Single File, Multiple Changes

When multiple changes affect the same file:

1. **Group by file**
   ```
   SKILL.md: [
     { line: 10, priority: high, ... },
     { line: 50, priority: high, ... },
     { line: 100, priority: medium, ... },
     { line: 200, priority: low, ... }
   ]
   ```

2. **Sort by line number (descending)**
   - Process from bottom to top
   - Prevents line offset issues
   - Earlier changes don't affect later line numbers

   ```
   SKILL.md: [
     { line: 200, priority: low, ... },      # First
     { line: 100, priority: medium, ... },   # Second
     { line: 50, priority: high, ... },      # Third
     { line: 10, priority: high, ... }       # Fourth
   ]
   ```

3. **Apply within same line range by priority**
   - If multiple changes affect same lines
   - Higher priority wins
   - Document conflict in report

### Algorithm

```python
def merge_per_file(changes):
    """Merge changes for a single file."""

    # Group by line range
    by_range = {}
    for change in changes:
        key = (change['start'], change['end'])
        if key not in by_range:
            by_range[key] = []
        by_range[key].append(change)

    # Resolve conflicts within ranges
    resolved = []
    for range_key, range_changes in by_range.items():
        if len(range_changes) == 1:
            resolved.append(range_changes[0])
        else:
            # Conflict: pick highest priority
            priority_order = {'high': 0, 'medium': 1, 'low': 2}
            sorted_changes = sorted(
                range_changes,
                key=lambda c: priority_order[c['priority']]
            )
            winner = sorted_changes[0]
            winner['conflicts_with'] = sorted_changes[1:]
            resolved.append(winner)

    # Sort by line number descending
    resolved.sort(key=lambda c: c['start'], reverse=True)

    return resolved
```

## Cross-File Merge Strategy

### Multiple Files, Multiple Changes

When changes span multiple files:

1. **Execute all High Priority changes first**
   - Across all files
   - Ensures critical fixes everywhere

2. **Then execute all Medium Priority changes**
   - Build on High Priority foundation

3. **Finally execute all Low Priority changes**
   - Polish and refine

### Execution Order

```
Round 1: High Priority
├── SKILL.md (High changes)
├── references/guide.md (High changes)
└── examples/demo.md (High changes)

Round 2: Medium Priority
├── SKILL.md (Medium changes)
├── references/guide.md (Medium changes)
└── examples/new.md (Medium, new file)

Round 3: Low Priority
└── SKILL.md (Low changes)
```

### Algorithm

```python
def merge_cross_files(all_changes):
    """Merge changes across all files."""

    # Group by priority
    by_priority = {
        'high': [],
        'medium': [],
        'low': []
    }

    for change in all_changes:
        by_priority[change['priority']].append(change)

    # Process each priority level
    execution_order = []
    for priority in ['high', 'medium', 'low']:
        # Group by file within priority
        by_file = {}
        for change in by_priority[priority]:
            file = change['file']
            if file not in by_file:
                by_file[file] = []
            by_file[file].append(change)

        # Merge within each file
        for file, file_changes in by_file.items():
            merged = merge_per_file(file_changes)
            execution_order.extend(merged)

    return execution_order
```

## Conflict Detection

### Types of Conflicts

#### 1. Same Line, Different Content

```
Change A: SKILL.md:10:10
Current: "You should create file"
Suggested: "Create the file"

Change B: SKILL.md:10:10
Current: "You should create file"
Suggested: "Create file now"
```

**Resolution:** Higher priority wins, document conflict

#### 2. Overlapping Line Ranges

```
Change A: SKILL.md:10:15
Current: lines 10-15 content
Suggested: new content for 10-15

Change B: SKILL.md:12:20
Current: lines 12-20 content
Suggested: new content for 12-20
```

**Resolution:** Higher priority wins, lower priority is skipped

#### 3. Same Priority Conflicts

```
Change A: SKILL.md:10:10 (High)
Suggested: "Option A"

Change B: SKILL.md:10:10 (High)
Suggested: "Option B"
```

**Resolution:** First in list wins, flag for manual review

### Conflict Detection Algorithm

```python
def detect_conflicts(changes):
    """Detect conflicting changes."""

    conflicts = []

    # Sort by line range
    sorted_changes = sorted(changes, key=lambda c: (c['start'], c['end']))

    for i in range(len(sorted_changes)):
        for j in range(i + 1, len(sorted_changes)):
            a = sorted_changes[i]
            b = sorted_changes[j]

            # Check for overlap
            if ranges_overlap(a, b):
                # Check if suggestions differ
                if a['suggested'] != b['suggested']:
                    conflicts.append({
                        'changes': [a, b],
                        'type': 'overlap',
                        'resolution': 'priority'
                    })

    return conflicts

def ranges_overlap(a, b):
    """Check if two line ranges overlap."""

    a_start, a_end = a['start'], a['end']
    b_start, b_end = b['start'], b['end']

    return not (a_end < b_start or b_end < a_start)
```

## Conflict Resolution

### Resolution Strategies

#### 1. Priority-Based Resolution

**Apply highest priority change:**
```
Conflicting changes:
- High: Fix description
- Low: Clarify text

Resolution: Apply High, skip Low
```

#### 2. First-Win Resolution

**For same priority conflicts:**
```
Conflicting changes (both High):
- #1: Fix description option A
- #2: Fix description option B

Resolution: Apply #1, skip #2, flag for review
```

#### 3. Manual Review Flag

**Document conflicts requiring human review:**
```markdown
## Conflicts Requiring Manual Review

### SKILL.md:10:10
**Applied:** High Priority - Fix description (Option A)
**Skipped:** High Priority - Alternative fix (Option B)
**Reason:** Same priority, first change applied

Review suggested alternative and manually apply if preferred.
```

### Resolution Algorithm

```python
def resolve_conflicts(changes):
    """Resolve conflicts using priority-based strategy."""

    priority_value = {'high': 3, 'medium': 2, 'low': 1}

    # Track applied line ranges
    applied_ranges = []

    # Filter changes
    resolved = []
    skipped = []

    for change in sorted(changes, key=lambda c: (
        -priority_value[c['priority']],  # Higher priority first
        c['start']
    )):
        # Check if range already applied
        conflict = False
        for applied in applied_ranges:
            if ranges_overlap(change, applied):
                conflict = True
                skipped.append({
                    'change': change,
                    'reason': 'overlap_with_higher_priority',
                    'conflicts_with': applied
                })
                break

        if not conflict:
            resolved.append(change)
            applied_ranges.append({
                'start': change['start'],
                'end': change['end']
            })

    return resolved, skipped
```

## Special Cases

### New File Creation

When creating new files (no line numbers):

1. **Check if file already exists**
2. **If exists:** Verify content matches or skip
3. **If not exists:** Create with suggested content

```python
def handle_new_file(change, skill_path):
    """Handle new file creation."""

    file_path = os.path.join(skill_path, change['file'])

    if os.path.exists(file_path):
        # File exists, verify content
        existing = read_file(file_path)
        if existing.strip() == change['suggested'].strip():
            return {'status': 'already_exists', 'action': 'skip'}
        else:
            return {
                'status': 'conflict',
                'action': 'skip',
                'reason': 'File exists with different content'
            }
    else:
        # Create new file
        write_file(file_path, change['suggested'])
        return {'status': 'created', 'action': 'created'}
```

### Append Operations

When no line numbers and file exists:

```python
def handle_append(change, skill_path):
    """Handle append to existing file."""

    file_path = os.path.join(skill_path, change['file'])

    if os.path.exists(file_path):
        # Append to end
        existing = read_file(file_path)
        updated = existing + '\n\n' + change['suggested']
        write_file(file_path, updated)
        return {'status': 'appended', 'action': 'appended'}
    else:
        # Treat as new file
        write_file(file_path, change['suggested'])
        return {'status': 'created', 'action': 'created'}
```

### YAML Frontmatter Updates

Special handling for YAML frontmatter:

1. **Parse existing frontmatter**
2. **Update specific fields**
3. **Preserve other fields**
4. **Validate YAML syntax**

```python
def update_frontmatter(file_path, updates):
    """Update YAML frontmatter fields."""

    # Read file
    content = read_file(file_path)

    # Extract frontmatter
    frontmatter, body = extract_frontmatter(content)

    # Parse YAML
    import yaml
    data = yaml.safe_load(frontmatter)

    # Apply updates
    for key, value in updates.items():
        data[key] = value

    # Serialize back
    new_frontmatter = yaml.dump(data, default_flow_style=False)

    # Reconstruct file
    updated = f"---\n{new_frontmatter}---\n{body}"

    write_file(file_path, updated)
```

## Verification After Merge

### Post-Merge Checks

After applying all changes:

1. **Verify file existence**
   ```python
   for change in applied_changes:
       file_path = os.path.join(skill_path, change['file'])
       assert os.path.exists(file_path), f"File not found: {file_path}"
   ```

2. **Verify YAML syntax**
   ```bash
   ~/.claude/skills/skill-quality-reviewer/scripts/extract-yaml.sh <skill-path>
   ```

3. **Verify content was applied**
   ```python
   for change in applied_changes:
       content = read_file(change['file'])
       assert change['suggested'] in content, "Change not found in file"
   ```

4. **Verify no unintended changes**
   ```python
   # Compare backup with current
   # Only expected changes should be present
   ```

## Complete Merge Workflow

```python
def execute_merge(improvement_plan, skill_path):
    """Complete merge workflow."""

    # 1. Parse improvement plan
    changes = parse_improvement_plan(improvement_plan)

    # 2. Detect conflicts
    conflicts = detect_conflicts(changes)

    # 3. Resolve conflicts
    resolved, skipped = resolve_conflicts(changes)

    # 4. Sort by execution order
    execution_order = merge_cross_files(resolved)

    # 5. Backup original files
    backup_skill(skill_path)

    # 6. Execute changes
    applied = []
    failed = []

    for change in execution_order:
        try:
            if change['start'] is None:
                # New file or append
                result = handle_new_file(change, skill_path)
            else:
                # Edit existing content
                result = edit_file(
                    change['file'],
                    change['start'],
                    change['end'],
                    change['current'],
                    change['suggested']
                )

            applied.append({
                'change': change,
                'result': result
            })

        except Exception as e:
            failed.append({
                'change': change,
                'error': str(e)
            })

    # 7. Verify results
    verification = verify_merge(skill_path, applied)

    # 8. Generate report
    report = generate_merge_report(
        applied=applied,
        failed=failed,
        skipped=skipped,
        conflicts=conflicts,
        verification=verification
    )

    return report
```

## Best Practices

### When Merging

1. **Always backup first** - Restore if things go wrong
2. **Apply high priority first** - Critical fixes first
3. **Process bottom to top** - Avoid line offset issues
4. **Verify after each file** - Catch errors early
5. **Document all decisions** - Clear update report

### When Conflicts Occur

1. **Prioritize by importance** - Critical over nice-to-have
2. **Flag for review** - Let user decide when unsure
3. **Don't silently skip** - Document everything
4. **Preserve originals** - Backup enables recovery

### After Merging

1. **Run verification** - Ensure skill still works
2. **Review report** - Confirm changes match intent
3. **Test the skill** - Verify functionality
4. **Keep backup** - Until confident in changes

## Error Recovery

### If Merge Fails

1. **Stop immediately** - Don't continue with errors
2. **Identify failure point** - Which change caused issue
3. **Restore from backup** - Return to original state
4. **Analyze failure** - Understand why it failed
5. **Retry selectively** - Skip problematic changes

### Partial Recovery

If some changes applied before failure:

```python
def partial_recovery(applied, backup_path):
    """Restore only failed changes."""

    # Get list of applied files
    applied_files = set(c['file'] for c in applied)

    # Restore only files that failed
    for file_path in failed_files:
        restore_from_backup(file_path, backup_path)

    return {
        'restored': failed_files,
        'preserved': applied_files
    }
```

This ensures successful changes are preserved while failed ones are reverted.
