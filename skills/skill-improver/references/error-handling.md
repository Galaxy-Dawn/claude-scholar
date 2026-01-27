# Error Handling

## Parse Errors

**Symptom:** Cannot read improvement plan

**Solutions:**
- Verify file exists and is readable
- Check file follows expected format
- Ensure proper markdown structure

## Conflict Errors

**Symptom:** Multiple changes to same content

**Solutions:**
- Apply highest priority change
- Flag conflict for manual review
- Document decision in report

## Edit Failures

**Symptom:** Cannot find current content to replace

**Solutions:**
- Verify current content matches exactly
- Check line numbers are correct
- File may have been modified externally
- Skip change and document in report

## Verification Failures

**Symptom:** Update broke skill structure

**Solutions:**
- Restore from backup
- Review conflicting changes
- Apply changes individually
- Skip problematic changes
