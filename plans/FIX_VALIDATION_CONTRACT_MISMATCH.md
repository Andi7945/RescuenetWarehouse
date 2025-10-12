# Fix Validation Contract Mismatch in Import Script

**Date:** 2025-10-12
**Status:** Ready for implementation
**Priority:** High (blocks import functionality)

## Problem Statement

The `import-firebase.js` script fails with `TypeError: Cannot read properties of undefined (reading 'forEach')` during manifest validation. This is caused by a contract mismatch between the validator implementation and its caller:

- **Implementation** (`lib/manifest.js:validateManifest()`): Throw-based validator that throws errors on failure, returns `true` on success
- **Consumer** (`import-firebase.js`): Expects return-based validator that returns `{ valid: boolean, errors: string[] }`

When validation succeeds, the function returns `true`, but the caller checks `!validation.valid` (which is `!undefined` = `true`), incorrectly entering the error path and attempting `validation.errors.forEach()` on `undefined`.

## Root Cause

Historical refactoring artifact. Line 20 in `import-firebase.js` shows an unused import `validateManifestOld` from `./lib/firestore-import` which likely had the return-based contract. The new `manifest.validateManifest()` was implemented with throw-based contract but the error handling code was never updated.

## Solution Approach

**Option chosen:** Convert `validateManifest()` to return-based validation (option 2)

**Rationale:**
- Caller code already expects this contract
- Better separation of concerns (validation logic vs error handling)
- More functional/pure - returns data instead of side effects
- Easier to test
- Allows collecting multiple errors instead of failing fast
- No changes needed in `import-firebase.js` (already correct)

## Implementation Plan

### Phase 1: Update Validation Function (Pure Function Refactor)

**File:** `scripts/lib/manifest.js`

**Changes to `validateManifest()` function:**

1. **Initialize error collector**
   - Add `const errors = []` at function start
   - Change all `throw new Error(...)` to `errors.push(...)`

2. **Handle early exit for null manifest**
   - Keep early return for null/undefined manifest
   - Return `{ valid: false, errors: ['Invalid manifest: manifest is null or undefined'] }`

3. **Convert all validation checks to non-throwing**
   - Change from: `if (!field) throw new Error(...)`
   - Change to: `if (!field) errors.push(...)`
   - Add defensive checks: `if (field && typeof field !== 'type')` to avoid accessing undefined properties

4. **Update collections validation**
   - Wrap `manifest.collections.forEach()` in `if (Array.isArray(manifest.collections))`
   - Only validate collection entries if collections is an array
   - Use `else` block pattern to prevent validation when array check fails

5. **Update storage validation**
   - Keep null/undefined check: `if (manifest.storage !== null && manifest.storage !== undefined)`
   - Wrap nested validations in type check: `if (typeof manifest.storage === 'object')`
   - Add conditional checks for nested properties

6. **Return validation result object**
   - Replace `return true` with: `return { valid: errors.length === 0, errors }`

**Function signature remains unchanged:**
```javascript
/**
 * @param {Object} manifest - Manifest object to validate
 * @returns {{valid: boolean, errors: string[]}} Validation result with errors array
 */
function validateManifest(manifest)
```

**Update JSDoc comments:**
- Remove `@throws {Error}` documentation
- Update `@returns` to document `{valid: boolean, errors: string[]}`
- Update example in JSDoc to show new usage pattern

### Phase 2: Verify Caller Contract Match

**File:** `scripts/import-firebase.js`

**Verification only (no changes needed):**

1. **Check lines 124-129** - Already correct implementation:
   ```javascript
   const validation = manifest.validateManifest(importManifest);
   if (!validation.valid) {
     console.error(chalk.red('\n❌ Invalid manifest:'));
     validation.errors.forEach(error => console.error(chalk.red(`  - ${error}`)));
     process.exit(1);
   }
   ```

2. **Confirm success path** at line 130 works correctly (no changes needed)

### Phase 3: Check for Other Usages

**Search for all usages of `validateManifest`:**

1. **Search codebase**
   - Use grep to find all calls to `validateManifest` in `scripts/` directory
   - Check if any other files use this function

2. **Update any other callers** (if found)
   - Verify they handle the new return contract
   - Update any try-catch blocks to use return value checks instead

**Expected findings:** Only `import-firebase.js` should be using this function based on module structure.

### Phase 4: Manual Testing

**Test with existing backup:**

1. **Run import script in dry-run mode:**
   ```bash
   node scripts/import-firebase.js \
     --local-input ./scripts/backups/2025-10-12 \
     --project rescuenet-testing
   ```

2. **Expected outcome:**
   - Step 4 validation should succeed
   - Should print "✓ Manifest is valid"
   - Should proceed to Step 5 (preview)
   - Should stop at dry-run message (no --execute flag)

3. **Test with invalid manifest:**
   - Create temporary backup dir with broken manifest
   - Test missing fields: remove `version`, `projectId`, `exportedAt`
   - Test wrong types: set `version: 123` instead of string
   - Test invalid collections: remove `name` or `filePath` from collection entry
   - Verify multiple errors are collected and displayed

4. **Test with null manifest:**
   - Temporarily modify code to pass `null` to validator
   - Verify early exit with appropriate error message

**Success criteria:**
- Valid manifest passes validation
- Invalid manifests show all collected errors (not just first one)
- Error messages are descriptive and actionable
- Import script proceeds normally with valid manifests

## Files to Modify

```
scripts/
├── lib/
│   └── manifest.js          # UPDATE: validateManifest() function
└── import-firebase.js       # VERIFY ONLY: caller already correct
```

## Implementation Notes

### Design Principles Applied

1. **Single Responsibility Principle (SRP)**
   - `validateManifest()` only validates, doesn't handle errors or exit process
   - Caller decides what to do with validation results

2. **Keep It Simple (KISS)**
   - No complex error handling framework
   - Simple array of error strings
   - Straightforward boolean + errors return object

3. **Modularity**
   - Pure function: same input = same output
   - No side effects (no throwing, no logging, no process.exit)
   - Easy to test in isolation
   - Reusable in different contexts (CLI, API, tests)

4. **Functional Programming**
   - Validation function is pure
   - Returns data describing validation state
   - Allows caller to collect/aggregate/log errors as needed

### Testing Strategy

**Manual testing only** - No automated tests required

**Rationale:**
- Function has clear, testable contract
- Error paths are straightforward
- Real-world usage in import script provides integration test
- Small, pure function with obvious behavior
- Adding tests would be over-engineering for this fix

### Migration Safety

**Zero breaking changes for current usage:**
- `import-firebase.js` already expects the new contract
- No other known consumers (verify in Phase 3)
- Backwards incompatible with throw-based callers, but none exist

**Rollback plan:**
- Git commit after Phase 1 completion
- If issues found, revert single commit
- Original throw-based version in git history

## Acceptance Criteria

- [ ] `validateManifest()` returns `{ valid: boolean, errors: string[] }`
- [ ] All validation errors are collected (not just first failure)
- [ ] Valid manifest returns `{ valid: true, errors: [] }`
- [ ] Invalid manifest returns `{ valid: false, errors: [...] }`
- [ ] JSDoc updated to reflect new return type
- [ ] Import script successfully validates existing backup
- [ ] Import script proceeds to dry-run completion with valid manifest
- [ ] Import script shows all errors for invalid manifest
- [ ] No other files broken by the change

## Future Improvements (Out of Scope)

- Add TypeScript for compile-time contract enforcement
- Create shared validation utility library for all scripts
- Add structured error objects with field paths (e.g., `{ field: 'collections[0].name', error: '...' }`)
- Add warning-level validations (non-blocking issues)

## References

- Error occurs at: `scripts/import-firebase.js:127`
- Validator function: `scripts/lib/manifest.js:62-131`
- Related unused import: `scripts/import-firebase.js:20` (`validateManifestOld`)
