# Data Export Implementation Plan

**For Claude Code Subagent Implementation**

## Overview

**Export ONLY**: Firebase (Firestore + Storage) → GCS Bucket

This tool is read-only and cannot modify any Firebase data. It creates timestamped backups in GCS.

## Quick Start for Claude Code

Execute these tasks sequentially using subagents or direct implementation:

```
Task 1: Setup project structure
Task 2: Implement Firebase initialization
Task 3: Implement GCS client utilities
Task 4: Implement Firestore export logic
Task 5: Implement Storage export logic
Task 6: Implement Export CLI tool
Task 7: Create documentation
Task 8: Manual QA validation
```

---

## Task 1: Setup Project Structure

**Goal**: Initialize Node.js project with dependencies

**Actions**:
1. Create `scripts` directory if it doesn't exist
2. Initialize `scripts/package.json`:
   ```json
   {
     "name": "rescuenet-firebase-export",
     "version": "1.0.0",
     "scripts": {
       "export": "node export-firebase.js"
     },
     "dependencies": {
       "firebase-admin": "^12.0.0",
       "commander": "^11.0.0",
       "p-limit": "^4.0.0",
       "cli-progress": "^3.12.0"
     }
   }
   ```
3. Run `npm install` in scripts directory
4. Create `scripts/lib/` directory for modules
5. Create `scripts/secrets/` directory for service account keys
6. Update `.gitignore` to add:
   ```
   scripts/secrets/
   scripts/*.log
   scripts/node_modules/
   ```

**Validation**:
- `scripts/package.json` exists with correct dependencies
- `.gitignore` includes secrets directory
- `npm install` completes successfully

---

## Task 2: Implement Firebase Initialization

**Goal**: Create read-only Firebase Admin SDK initialization helper

**File**: `scripts/lib/firebase-init.js`

**Requirements**:
- Export function `initFirebaseReadOnly(projectId)` that returns `{ db, storageBucket, projectId }`
- Export function `getServiceAccountPath(projectId)` that maps project IDs to key files
- Use service account keys from `scripts/secrets/`
- Map `rescuenet-7733b` → `rescuenet-production.json`
- Map `rescuenet-testing` → `rescuenet-testing.json`
- Throw error if service account not found
- Initialize Firebase Admin with named app to allow multiple connections

**Reference Implementation** (in plan above, Step 2)

**Validation**:
- Can require the module without errors
- Function throws error for missing service account
- Function initializes Firebase app correctly (test manually if keys available)

---

## Task 3: Implement GCS Client Utilities

**Goal**: Create utilities for writing data to Google Cloud Storage

**File**: `scripts/lib/gcs-client.js`

**Requirements**:
- Export async function `writeJSON(bucket, path, data)` that:
  - Writes JSON data to GCS
  - Returns GCS URI (gs://bucket/path format)
  - Pretty-prints JSON with 2-space indent
  - Sets contentType to 'application/json'
- Export async function `exists(bucket, path)` that checks if file exists
- Export function `getGcsUri(bucket, path)` that formats gs:// URI
- No delete operations

**Reference Implementation** (in plan above, Step 3)

**Validation**:
- Module exports all three functions
- Functions have correct signatures
- (Manual test if GCS access available)

---

## Task 4: Implement Firestore Export Logic

**Goal**: Export Firestore collections to plain JavaScript objects

**File**: `scripts/lib/firestore-export.js`

**Requirements**:
- Define constant `COLLECTIONS` array with: containers, items, work_log, current_locations, module_destinations, container_types, assignments
- Export async function `exportCollection(db, collectionName)` that:
  - Fetches all documents from collection
  - Converts to plain objects with IDs
  - Returns `{ docs: [...], count: number }`
  - Logs progress to console
- Export async function `exportAllCollections(db, collectionNames = COLLECTIONS)` that:
  - Exports all specified collections
  - Returns object keyed by collection name
  - Handles errors per collection (continues on failure)
- Export function `createManifest(exportData, sourceProject)` that:
  - Creates metadata object with version, timestamp, counts
  - Returns manifest object
- Export function `convertTimestamps(value)` that recursively converts Firestore Timestamps to ISO strings
- Export function `docToPlainObject(doc)` that converts DocumentSnapshot to plain object

**Reference Implementation** (in plan above, Step 4)

**Validation**:
- Module exports all required functions and COLLECTIONS constant
- COLLECTIONS array has 7 collection names
- Functions handle errors gracefully

---

## Task 5: Implement Storage Export Logic

**Goal**: Export Firebase Storage files to GCS

**File**: `scripts/lib/storage-export.js`

**Requirements**:
- Export async function `listStorageFiles(sourceBucket, prefix = '')` that:
  - Lists all files in bucket with optional prefix
  - Returns array of file metadata objects
  - Logs progress to console
- Export async function `copyStorageFiles(sourceBucket, targetBucket, targetPrefix, concurrency = 5)` that:
  - Copies all files from source to target with new prefix
  - Uses p-limit for concurrency control
  - Returns `{ files, totalBytes, copied, errors }`
  - Logs progress every 10 files
  - Handles errors gracefully (continues on failure)

**Dependencies**: Requires `p-limit` package

**Reference Implementation** (in plan above, Step 5)

**Validation**:
- Module exports both functions
- Uses p-limit for concurrency
- Error handling doesn't stop entire operation

---

## Task 6: Implement Export CLI Tool

**Goal**: Create command-line interface for export operations

**File**: `scripts/export-firebase.js`

**Requirements**:
- Use `commander` for CLI argument parsing
- Required options: `--project <id>`, `--bucket <name>`
- Optional options: `--output <path>`, `--skip-storage`, `--collections <list>`, `--dry-run`
- Default output path: `exports/{YYYY-MM-DD}-{projectId}`
- Main async function `exportFirebase()` that:
  1. Initializes Firebase (read-only)
  2. Exports collections using `exportAllCollections`
  3. Optionally exports storage using `copyStorageFiles`
  4. Creates manifest using `createManifest`
  5. Writes all data to GCS using `writeJSON`
  6. Prints summary
- Dry-run mode: show plan but don't write
- Error handling: catch and log errors, exit with code 1
- Console output: clear progress indicators and status messages
- Add shebang: `#!/usr/bin/env node`

**Reference Implementation** (in plan above, Step 6)

**Validation**:
- Script is executable (`chmod +x export-firebase.js`)
- Shows help with `--help` flag
- Dry-run mode works
- (Full test requires Firebase credentials)

---

## Task 7: Create Documentation

**Goal**: Document usage and workflows

**File**: `scripts/README-export.md`

**Requirements**:
- Overview section explaining what tool does
- Setup instructions (dependencies, service accounts, GCS bucket)
- Usage examples (basic export, production export, dry run, specific collections, skip storage)
- Output structure diagram
- Manifest format example
- Common workflows (weekly backup, pre-release snapshot)
- Troubleshooting section
- Safety notes
- Link to import tool plan

**Also update**: Root `README.md` to add Data Export section with link to `scripts/README-export.md`

**Reference Content** (in plan above, Step 7)

**Validation**:
- README-export.md exists with all sections
- Root README.md has Data Export section
- Examples are copy-pasteable

---

## Task 8: Manual QA Validation

**Goal**: Test the export tool end-to-end

**Prerequisites**:
- Service account keys for rescuenet-testing in `scripts/secrets/rescuenet-testing.json`
- GCS bucket `rescuenet-migrations` exists
- Permissions configured

**Test Scenarios**:
1. **Dry run**: `npm run export -- --project=rescuenet-testing --bucket=rescuenet-migrations --dry-run`
   - Should show plan without writing
2. **Full export**: `npm run export -- --project=rescuenet-testing --bucket=rescuenet-migrations`
   - Should create export in GCS
3. **Verify GCS output**:
   - Check manifest exists: `gsutil cat gs://rescuenet-migrations/exports/.../manifest.json`
   - Check collections exist: `gsutil ls gs://rescuenet-migrations/exports/.../firestore/`
4. **Edge cases**:
   - `--skip-storage` flag
   - `--collections=items` flag
   - Re-running same export

**Deliverable**: QA checklist with results (pass/fail/not tested)

---

## File Structure Reference

```
scripts/
├── lib/
│   ├── firebase-init.js         # Task 2
│   ├── gcs-client.js            # Task 3
│   ├── firestore-export.js      # Task 4
│   └── storage-export.js        # Task 5
├── export-firebase.js           # Task 6
├── package.json                 # Task 1
└── README-export.md             # Task 7
```

---

## Implementation Notes for Subagents

**Task Dependencies**:
- Tasks 1-3 can run in parallel after Task 1
- Task 4 depends on Task 2 (uses firebase-init)
- Task 5 is independent
- Task 6 depends on Tasks 2-5
- Task 7 is independent (can run anytime)
- Task 8 depends on all previous tasks

**Recommended Order**:
1. Task 1 (setup)
2. Tasks 2, 3, 5 in parallel
3. Task 4 (depends on 2)
4. Task 6 (depends on 2-5)
5. Task 7 (documentation)
6. Task 8 (manual QA)

**Total Estimated Time**: ~8.5 hours

---

## Safety Guarantees

✅ **Read-Only**: Tool cannot modify or delete Firebase data
✅ **No Import**: This tool ONLY exports (import is separate)
✅ **Idempotent**: Safe to re-run multiple times
✅ **Dry Run**: Preview before executing
✅ **Logging**: All operations logged to console
✅ **Error Handling**: Continues on individual failures

---

## Next Phase

After export tool is complete and tested, see `DATA_IMPORT_PLAN.md` for the import implementation.

**IMPORTANT**: Import tool will be completely separate and require explicit user confirmation before any writes.
