# Data Import Implementation Plan

**For Claude Code Subagent Implementation**

## Overview

**Import ONLY**: GCS Bucket → Firebase (Firestore + Storage)

**⚠️ CRITICAL SAFETY**: This tool writes to Firebase and requires EXPLICIT user confirmation before any operation.

## Quick Start for Claude Code

Execute these tasks sequentially using subagents or direct implementation:

```
Task 1: Setup dependencies and safety prompts
Task 2: Extend GCS client for reads
Task 3: Implement Firestore import logic
Task 4: Implement Storage import logic
Task 5: Implement Import CLI tool with confirmations
Task 6: Create documentation
Task 7: Manual QA validation
```

**PREREQUISITE**: Export tool must be completed first (see DATA_EXPORT_PLAN.md)

---

## Task 1: Setup Dependencies and Safety Prompts

**Goal**: Add dependencies and create user confirmation utilities

**Actions**:
1. Update `scripts/package.json` to add dependencies:
   ```json
   {
     "dependencies": {
       "firebase-admin": "^12.0.0",
       "commander": "^11.0.0",
       "p-limit": "^4.0.0",
       "cli-progress": "^3.12.0",
       "prompts": "^2.4.2",
       "chalk": "^4.1.2"
     },
     "scripts": {
       "export": "node export-firebase.js",
       "import": "node import-firebase.js"
     }
   }
   ```
2. Run `npm install prompts chalk`
3. Create `scripts/lib/safety-prompts.js` with safety confirmation functions

**File**: `scripts/lib/safety-prompts.js`

**Requirements**:
- Export async function `confirmImport(importDetails, targetProject)` that:
  - Displays red warning about destructive operation
  - Shows manifest preview
  - Prompts user to confirm they understand (yes/no)
  - Prompts user to type EXACT project name
  - For production projects: extra confirmation step
  - Returns true if confirmed, false otherwise
  - Uses `chalk` for colored output
  - Uses `prompts` for interactive prompts
- Export function `displayManifest(manifest)` that:
  - Shows formatted manifest details
  - Displays collection counts
  - Shows storage file counts
  - Warns if export is old (>7 days)
- Export function `isProductionProject(projectId)` that:
  - Returns true if project ID contains 'rescuenet-7733b', '-prod', or 'production'
- Handle Ctrl+C gracefully (exit without stack trace)

**Validation**:
- Module exports all three functions
- Uses chalk for colored output
- Uses prompts for interactive input
- Graceful cancellation works

---

## Task 2: Extend GCS Client for Reads

**Goal**: Add read capabilities to existing GCS client

**File**: `scripts/lib/gcs-client.js` (extend existing)

**Requirements**:
- Add async function `readJSON(bucket, path)` that:
  - Reads JSON file from GCS
  - Returns parsed JavaScript object
  - Throws error if file doesn't exist
  - Throws error if invalid JSON
- Add function `parseGcsUri(uri)` that:
  - Parses gs://bucket/path format
  - Returns `{ bucketName, path }`
  - Throws error if invalid format
- Keep all existing functions (writeJSON, exists, getGcsUri)

**Validation**:
- Module exports 5 functions total
- parseGcsUri correctly parses valid URIs
- parseGcsUri throws error for invalid URIs

---

## Task 3: Implement Firestore Import Logic

**Goal**: Import Firestore collections from plain objects with WRITE operations

**File**: `scripts/lib/firestore-import.js`

**Requirements**:
- Export function `validateManifest(manifest)` that:
  - Checks for required fields (version, timestamp, sourceProject, collections)
  - Returns `{ valid: boolean, errors: Array<string> }`
- Export async function `clearCollection(db, collectionName, batchSize = 500)` that:
  - DELETES all documents from collection in batches
  - Returns number of deleted documents
  - Logs progress to console
- Export async function `importCollection(db, collectionName, docs, batchSize = 500)` that:
  - Imports documents using batched writes
  - Preserves document IDs
  - Returns `{ imported: number, errors: Array }`
  - Logs progress to console
- Export async function `importAllCollections(db, collectionsData, clearFirst = true)` that:
  - Imports all collections
  - Optionally clears before import
  - Returns results object keyed by collection name
  - Continues on errors (doesn't stop entire operation)
- Export function `restoreTimestamps(value)` that:
  - Recursively converts ISO date strings back to Firestore Timestamps
  - Handles arrays and nested objects
  - Returns converted value

**Validation**:
- Module exports all five functions
- validateManifest correctly identifies invalid manifests
- Batch size is respected (500 max operations per batch)
- Error handling is graceful

---

## Task 4: Implement Storage Import Logic

**Goal**: Import storage files from GCS export to Firebase Storage

**File**: `scripts/lib/storage-import.js`

**Requirements**:
- Export async function `restoreStorageFiles(sourceBucket, sourcePrefix, targetBucket, concurrency = 5)` that:
  - Lists all files in source export with prefix
  - Copies files to target bucket preserving original paths
  - Strips export prefix from paths (e.g., 'exports/2025-10-10/storage/items/123/image.jpg' → 'items/123/image.jpg')
  - Uses p-limit for concurrency control
  - Returns `{ copied: number, skipped: number, errors: Array }`
  - Logs progress every 10 files
  - Handles errors gracefully (continues on failure)

**Dependencies**: Requires `p-limit` package (already installed)

**Validation**:
- Module exports restoreStorageFiles function
- Uses p-limit for concurrency
- Path stripping works correctly
- Error handling doesn't stop entire operation

---

## Task 5: Implement Import CLI Tool with Confirmations

**Goal**: Create command-line interface with MANDATORY safety confirmations

**File**: `scripts/import-firebase.js`

**Requirements**:
- Use `commander` for CLI argument parsing
- Required options: `--source <uri>` (GCS path), `--project <id>` (target project)
- Optional options: `--skip-storage`, `--skip-clear`, `--collections <list>`, `--execute`, `--yes`
- **CRITICAL**: Default to dry-run mode (no writes without `--execute` flag)
- **CRITICAL**: Require user confirmation unless `--yes` flag (show warnings about `--yes`)
- Main async function `importFirebase()` that:
  1. Parses source URI
  2. Reads manifest from GCS
  3. Validates manifest
  4. Displays what will be imported
  5. STOPS if not `--execute` (dry-run mode)
  6. Gets user confirmation (unless `--yes`)
  7. Initializes target Firebase
  8. Reads collection data from GCS
  9. Imports collections (with optional clear)
  10. Imports storage files (if not skipped)
  11. Prints summary with totals
- Use `chalk` for colored output (red for warnings, yellow for cautions, green for success)
- Error handling: catch and log errors, exit with code 1
- Add shebang: `#!/usr/bin/env node`

**Confirmation Flow**:
```
⚠️  DESTRUCTIVE OPERATION ⚠️
Target: rescuenet-testing
[Display manifest]
? Confirm destructive operation? (y/N)
Type EXACT project name: rescuenet-testing
? Project name: _
[If production: Extra confirmation]
✓ Confirmed. Proceeding...
```

**Validation**:
- Script is executable
- Shows help with `--help` flag
- Dry-run mode works (no --execute)
- Confirmation prompts appear (no --yes)
- `--yes` flag skips prompts with warning
- (Full test requires Firebase credentials and export)

---

## Task 6: Create Documentation

**Goal**: Document usage, safety, and workflows

**File**: `scripts/README-import.md`

**Requirements**:
- ⚠️ Safety Features section at top (mandatory confirmation, dry-run default, production protection)
- Prerequisites (completed export, service account, explicit user decision)
- Setup instructions (already done if export tool completed)
- Usage examples:
  - Dry run (safe, no changes)
  - Full import with confirmation
  - Import specific collections
  - Skip storage files
  - Skip confirmation (automated scripts only - warn about dangers)
- What Gets Replaced section (explain destructive nature)
- Confirmation flow example
- Common workflows (refresh staging from production, restore from backup)
- Safety checklist (what to verify before production import)
- Troubleshooting
- Production import policy (requirements before importing to prod)
- Next steps after import (verification steps)

**Also update**: Root `README.md` to mention import tool (or keep separate for safety)

**Validation**:
- README-import.md exists with all sections
- Safety warnings are prominent
- Examples are copy-pasteable
- Production warnings are clear

---

## Task 7: Manual QA Validation

**Goal**: Test the import tool end-to-end with all safety features

**Prerequisites**:
- Completed export tool (Task 1-8 of DATA_EXPORT_PLAN.md)
- At least one successful export in GCS
- Service account keys for target project
- **CRITICAL**: Test ONLY on staging/test environments initially

**Test Scenarios**:

**Phase 1: Dry Run Testing**
1. **Valid export dry run**: `npm run import -- --source=gs://rescuenet-migrations/exports/... --project=rescuenet-testing`
   - Should show manifest without writing
2. **Invalid source URI**: Test with bad URI
   - Should show clear error
3. **Missing manifest**: Test with non-existent export
   - Should show clear error

**Phase 2: Confirmation Flow Testing**
1. **User cancels at first prompt**: Test confirmation flow
   - Should cancel gracefully
2. **User types wrong project name**: Test project name verification
   - Should cancel with error
3. **Ctrl+C cancellation**: Test graceful exit
   - Should exit without stack trace
4. **Production project warnings**: Dry run with production-like project ID
   - Should show extra warnings

**Phase 3: Actual Import (Staging Only)**
1. **Backup staging first**: Export current staging data
   - Keep as rollback option
2. **Full import to staging**: `npm run import -- --source=gs://... --project=rescuenet-testing --execute`
   - Should import successfully
3. **Verify in Firebase Console**:
   - Document counts match manifest
   - Sample documents have correct data
   - Timestamps are valid
   - Storage files accessible
4. **Test Flutter app**: Ensure app works with imported data

**Phase 4: Edge Cases**
1. **Selective collection import**: `--collections=items`
2. **Skip storage**: `--skip-storage`
3. **Skip clear**: `--skip-clear` (may cause conflicts)
4. **Re-running import**: Import twice to same target

**Phase 5: Error Handling**
1. **Invalid manifest structure**: Test with corrupted manifest
2. **Missing collection file**: Test with incomplete export
3. **Network interruption**: (optional) Test resilience

**Deliverable**: QA checklist with results (pass/fail/not tested)

**⚠️ DO NOT test on production** unless explicitly approved and backed up

---

## File Structure Reference

```
scripts/
├── lib/
│   ├── firebase-init.js         # From export tool
│   ├── gcs-client.js            # Extended in Task 2
│   ├── firestore-export.js      # From export tool
│   ├── storage-export.js        # From export tool
│   ├── safety-prompts.js        # Task 1 (NEW)
│   ├── firestore-import.js      # Task 3 (NEW)
│   └── storage-import.js        # Task 4 (NEW)
├── export-firebase.js           # From export tool
├── import-firebase.js           # Task 5 (NEW)
├── package.json                 # Updated in Task 1
├── README-export.md             # From export tool
└── README-import.md             # Task 6 (NEW)
```

---

## Implementation Notes for Subagents

**Task Dependencies**:
- Task 1 is prerequisite for all others
- Task 2 extends existing file (independent)
- Task 3 is independent
- Task 4 is independent
- Task 5 depends on Tasks 1-4
- Task 6 is independent (documentation)
- Task 7 depends on all previous tasks

**Recommended Order**:
1. Task 1 (setup safety)
2. Tasks 2, 3, 4 in parallel
3. Task 5 (CLI with confirmations)
4. Task 6 (documentation)
5. Task 7 (manual QA)

**Total Estimated Time**: ~11 hours

---

## Safety Guarantees

✅ **Dry-run default**: No writes without `--execute` flag
✅ **Triple confirmation**: Understand → Type project name → Production extra
✅ **Production protection**: Extra warnings and confirmation step
✅ **Graceful cancellation**: Ctrl+C any time
✅ **Manifest preview**: See exactly what will be imported
✅ **Clear warnings**: Red text for destructive operations
✅ **No --yes by default**: Automated mode must be explicitly enabled
✅ **Validation**: Check manifest structure before import
✅ **Logging**: All operations logged to console

---

## Critical Warnings

⚠️ **NEVER run import without explicit user decision**
⚠️ **ALWAYS dry-run first**
⚠️ **ALWAYS backup before import to production**
⚠️ **NEVER use --yes without understanding implications**
⚠️ **ALWAYS verify manifest before confirming**
⚠️ **TEST on staging first, then production with approval**

---

## Dependencies on Export Tool

This import tool requires:
- ✅ Export tool completed and tested (DATA_EXPORT_PLAN.md)
- ✅ At least one successful export in GCS
- ✅ Same GCS client utilities (`lib/gcs-client.js`)
- ✅ Same Firebase init utilities (`lib/firebase-init.js`)

**Recommendation**: Complete export tool first, create test exports, THEN implement import tool.
