# Service Account Setup - Add Retry Logic for IAM Propagation

**For Claude Code Subagent Implementation**

---

## Problem Statement

The service account setup script fails when granting IAM permissions immediately after creating a service account due to Google Cloud's eventual consistency model. Service accounts take 2-7+ minutes to propagate through GCP's distributed infrastructure before they can be referenced in IAM policy operations.

**Error:**
```
ERROR: (gcloud.projects.add-iam-policy-binding) INVALID_ARGUMENT:
Service account firebase-export-tool@rescuenet-testing.iam.gserviceaccount.com does not exist.
```

**Root Cause:** IAM eventual consistency - the service account exists but hasn't propagated to all GCP systems yet.

---

## Solution Overview

Implement retry logic with exponential backoff in the `grant_permissions()` function. This is a battle-tested pattern for handling eventual consistency in distributed systems.

**Key Principles:**
- **KISS**: Simple retry wrapper around existing command
- **SRP**: Extract retry logic into reusable function
- **Modularity**: Works with any gcloud command, not just IAM
- **No over-testing**: This is infrastructure automation, manual testing is sufficient

---

## Implementation Plan

Execute this single task using a subagent:

### Task: Add Retry Logic to Service Account Setup Script

**Goal:** Make the script resilient to IAM propagation delays

**File to Edit:** `scripts/setup-service-accounts.sh`

**Changes Required:**

#### 1. Create Reusable Retry Function (After line 49, before `check_prerequisites`)

Add a generic retry function that can wrap any command:

```bash
# Retry a command with exponential backoff
# Usage: retry_with_backoff <max_attempts> <initial_wait_seconds> <command...>
# Returns: 0 on success, 1 on failure after all attempts
retry_with_backoff() {
  local max_attempts=$1
  local wait_time=$2
  shift 2
  local command=("$@")
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    # Execute command and capture exit code
    if "${command[@]}" 2>/dev/null; then
      return 0  # Success
    fi

    # Check if this was the last attempt
    if [ $attempt -eq $max_attempts ]; then
      return 1  # Failed after all attempts
    fi

    # Log retry and wait
    print_warning "Attempt ${attempt}/${max_attempts} failed, retrying in ${wait_time}s..."
    sleep $wait_time

    # Exponential backoff: double the wait time
    wait_time=$((wait_time * 2))
    attempt=$((attempt + 1))
  done

  return 1
}
```

**Function Design:**
- **Pure logic**: Takes parameters, returns exit code
- **Reusable**: Works with any command, not just gcloud
- **Generic**: Could be extracted to a shared bash library later
- **Simple**: 20 lines, easy to understand and maintain

#### 2. Update `grant_permissions()` Function (Starts around line 152)

Replace the existing `grant_permissions()` function with retry-enabled version:

```bash
grant_permissions() {
  local project_id=$1
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"

  print_header "Granting Permissions"

  # Wait a few seconds before first attempt (helps with propagation)
  print_info "Waiting for service account to propagate..."
  sleep 5

  for role in "${ROLES[@]}"; do
    print_info "Granting ${role}..."

    # Try with retry logic: max 10 attempts, start with 5s wait
    if retry_with_backoff 10 5 \
      gcloud projects add-iam-policy-binding "${project_id}" \
        --member="serviceAccount:${service_account_email}" \
        --role="${role}" \
        --condition=None \
        --quiet; then
      print_success "${role}"
    else
      print_error "Failed to grant ${role} after multiple attempts"
      print_error "The service account may not have propagated yet. Wait a few minutes and try:"
      print_error "  gcloud projects add-iam-policy-binding ${project_id} \\"
      print_error "    --member='serviceAccount:${service_account_email}' \\"
      print_error "    --role='${role}'"
      exit 1
    fi
  done

  echo ""
}
```

**Changes Made:**
1. Added initial 5-second wait (catches fast propagation cases)
2. Wrapped `gcloud projects add-iam-policy-binding` with `retry_with_backoff`
3. Set max attempts to 10, initial wait to 5 seconds
4. Exponential backoff: 5s, 10s, 20s, 40s, 80s... (max ~10 minutes total)
5. Better error message with manual recovery command if all retries fail

**Why These Numbers:**
- **10 attempts**: Covers the 7+ minute max propagation time
- **5 second initial wait**: Fast enough for quick propagation, not annoying for users
- **Exponential backoff**: Efficient - tries quickly at first, then backs off

#### 3. Update Success Message in `print_summary()` (Around line 187)

Update the summary to mention the retry logic:

Find this section:
```bash
print_success "Service account is ready to use!"
```

Replace with:
```bash
print_success "Service account is ready to use!"
print_info "Note: IAM permissions may take up to 2 minutes to fully propagate"
```

This sets proper expectations for users.

---

## Implementation Guidelines

**For the Subagent:**

1. **Read the existing script** first to understand structure and line numbers
2. **Locate the three sections** to modify:
   - After line 49: Add `retry_with_backoff` function
   - Around line 152: Replace `grant_permissions` function
   - Around line 187: Update success message
3. **Use the Edit tool** for each change (three separate edits)
4. **Test the changes** by running the script:
   ```bash
   cd scripts
   ./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
   ```
5. **Verify behavior**:
   - Script should succeed (may take 1-2 minutes for permission granting)
   - Should see retry messages if propagation is slow
   - Should see success message at the end

**Important:**
- Keep existing error handling and logging patterns
- Don't change color codes, print functions, or other logic
- Preserve the script's style and conventions
- The retry function should be generic (not hardcoded to IAM)

---

## Expected Behavior After Fix

### Scenario 1: Fast Propagation (Best Case)
```
========================================
Granting Permissions
========================================
→ Waiting for service account to propagate...
→ Granting roles/datastore.user...
✓ roles/datastore.user
→ Granting roles/storage.objectViewer...
✓ roles/storage.objectViewer
→ Granting roles/storage.objectCreator...
✓ roles/storage.objectCreator
```
**Time:** ~10 seconds (5s wait + 3 role grants)

### Scenario 2: Slow Propagation (Typical)
```
========================================
Granting Permissions
========================================
→ Waiting for service account to propagate...
→ Granting roles/datastore.user...
⚠ Attempt 1/10 failed, retrying in 5s...
⚠ Attempt 2/10 failed, retrying in 10s...
✓ roles/datastore.user
→ Granting roles/storage.objectViewer...
✓ roles/storage.objectViewer
→ Granting roles/storage.objectCreator...
✓ roles/storage.objectCreator
```
**Time:** ~30 seconds (first role takes 20s to propagate, rest succeed immediately)

### Scenario 3: Very Slow Propagation (Edge Case)
```
========================================
Granting Permissions
========================================
→ Waiting for service account to propagate...
→ Granting roles/datastore.user...
⚠ Attempt 1/10 failed, retrying in 5s...
⚠ Attempt 2/10 failed, retrying in 10s...
⚠ Attempt 3/10 failed, retrying in 20s...
⚠ Attempt 4/10 failed, retrying in 40s...
✓ roles/datastore.user
→ Granting roles/storage.objectViewer...
✓ roles/storage.objectViewer
→ Granting roles/storage.objectCreator...
✓ roles/storage.objectCreator
```
**Time:** ~2-3 minutes

### Scenario 4: Failure After All Retries (Rare)
```
========================================
Granting Permissions
========================================
→ Waiting for service account to propagate...
→ Granting roles/datastore.user...
⚠ Attempt 1/10 failed, retrying in 5s...
⚠ Attempt 2/10 failed, retrying in 10s...
[... more retries ...]
⚠ Attempt 10/10 failed, retrying in 1280s...
✗ Failed to grant roles/datastore.user after multiple attempts
✗ The service account may not have propagated yet. Wait a few minutes and try:
✗   gcloud projects add-iam-policy-binding rescuenet-testing \
✗     --member='serviceAccount:firebase-export-tool@rescuenet-testing.iam.gserviceaccount.com' \
✗     --role='roles/datastore.user'
```
**Action:** User waits and runs the manual command, or re-runs the entire script

---

## Testing Plan

**Manual Testing Only** (No automated tests needed for this bash script)

### Test 1: Fresh Service Account Creation
```bash
cd scripts
./setup-service-accounts.sh rescuenet-testing test-account.json
```
**Expected:** Script succeeds with retry messages visible

### Test 2: Existing Service Account (Re-run)
```bash
./setup-service-accounts.sh rescuenet-testing test-account.json
```
**Expected:** Script detects existing account, updates permissions successfully

### Test 3: Both Projects
```bash
./setup-all-service-accounts.sh
```
**Expected:** Both projects set up successfully with retry logic working

### Cleanup After Testing
```bash
# Delete test service account if created
gcloud iam service-accounts delete test-account@rescuenet-testing.iam.gserviceaccount.com --quiet

# Or keep it if it's the actual service account you need
```

---

## Rollback Plan

If the changes cause issues:

1. **Git Reset** (if committed):
   ```bash
   git checkout scripts/setup-service-accounts.sh
   ```

2. **Manual Rollback**:
   - Remove the `retry_with_backoff` function
   - Revert `grant_permissions` to direct `gcloud` calls without retry
   - Remove the propagation note from success message

3. **Fallback Workaround**:
   - Create service account
   - Wait 2-3 minutes manually
   - Grant permissions using gcloud commands directly

---

## Success Criteria

✅ Script succeeds when service account propagation is slow
✅ Retry messages are clear and informative
✅ Exponential backoff prevents API hammering
✅ Script completes in under 3 minutes for typical cases
✅ Error messages provide manual recovery commands
✅ Both individual and batch scripts work correctly

---

## Future Improvements (Out of Scope)

These are **not** part of this task, but could be considered later:

- Extract `retry_with_backoff` to a shared bash library (`scripts/lib/retry.sh`)
- Add `--no-retry` flag for debugging
- Add `--max-wait` parameter to control total retry time
- Parallel permission granting (grant all 3 roles concurrently)
- Health check after permission granting (verify roles are actually applied)

---

## File Summary

**Files Modified:** 1
- `scripts/setup-service-accounts.sh` (3 sections updated)

**Files Created:** 0

**Total Changes:**
- ~30 lines added (retry function)
- ~20 lines modified (grant_permissions)
- ~2 lines added (success message)

**Complexity:** Low
**Risk:** Low (retry logic is additive, doesn't change happy path)
**Testing Effort:** 15 minutes manual testing

---

## Commands for Subagent

The subagent should execute these steps:

1. Read the current script:
   ```
   Read scripts/setup-service-accounts.sh
   ```

2. Make three edits:
   - Add `retry_with_backoff` function after line 49
   - Replace `grant_permissions` function around line 152
   - Update success message around line 187

3. Test the changes:
   ```
   cd scripts
   ./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
   ```

4. Report back:
   - Did the script succeed?
   - Were retry messages displayed?
   - How long did it take?
   - Any errors encountered?

---

## Notes for Implementation

**Bash Best Practices Used:**
- `local` variables for function scope
- `"${array[@]}"` for proper array expansion
- `2>/dev/null` for clean retry logic (suppress error output during retries)
- Exit codes for success/failure (0/1)
- Exponential backoff with `$((wait_time * 2))`

**Why This Approach:**
- **Simple**: Minimal code changes, easy to understand
- **Robust**: Handles 99.9% of propagation delay cases
- **User-friendly**: Clear feedback during retries
- **Maintainable**: Generic retry function can be reused elsewhere
- **Non-breaking**: Doesn't change behavior for successful first attempts

**Why Not Other Approaches:**
- ❌ **Fixed sleep**: Not robust (might be too short or unnecessarily long)
- ❌ **Polling service account status**: More complex, no clear "ready" state
- ❌ **Using numeric IDs**: Doesn't eliminate propagation delay
- ❌ **Parallel retries**: Over-complicates the logic for minimal gain

---

## Estimated Effort

**Implementation:** 10 minutes
**Testing:** 15 minutes
**Total:** 25 minutes

This is a straightforward change following well-established patterns for handling eventual consistency in distributed systems.
