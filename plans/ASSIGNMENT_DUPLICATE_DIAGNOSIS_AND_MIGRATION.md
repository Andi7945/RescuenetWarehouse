# Assignment Duplicate Diagnosis & ID Migration: Implementation Plan

## Context

Assignment documents in Firestore currently use random UUID doc IDs. The business constraint is one assignment per `(itemId, containerId)` pair, but there is no structural enforcement of this at the data level. Duplicate documents can exist (same `itemId` + `containerId`, different doc IDs), causing the item page and container overview to show different counts for the same item.

Phase 1 (code change) is already deployed: new assignments now get deterministic IDs `"${itemId}__${containerId}"`. Existing UUID-based documents are unaffected and remain fully reachable because all read/update/delete operations query by field values, not by doc ID.

This plan covers the two scripts needed next:

1. **Diagnostic script** — read-only, prints all duplicate pairs and their current state
2. **Migration script** — converts all UUID-based docs to deterministic IDs, resolves duplicates, creates a backup with restore instructions

## What to Build

```
scripts/
  lib/
    assignment_analysis.js       # Pure functions shared by both scripts
  diagnose_assignment_duplicates.js
  migrate_assignment_ids.js
  ASSIGNMENT_ID_MIGRATION.md     # Backup format + step-by-step restore guide
```

No new `npm` dependencies. All required packages (`firebase-admin`, `commander`, `chalk`) are already in `scripts/package.json`.

## Reuse Existing Infrastructure

- **Firebase init**: `scripts/lib/firebase-init.js` → `initFirebaseReadOnly(projectId)` returns `{ db, projectId }`
- **Backups directory**: `scripts/backups/` already exists — write backup files here
- **Service accounts**: `scripts/secrets/rescuenet-production.json` and `rescuenet-testing.json` — see `scripts/SERVICE_ACCOUNTS.md`
- **Style reference**: follow `scripts/export-firebase.js` for CLI structure and chalk usage pattern

## Data Shapes

```js
// Firestore assignment document shape (as returned by .data())
{
  id: string,          // doc ID field (also stored inside the document)
  itemId: string,
  containerId: string,
  count: number,
}

// A doc as returned from Firestore snapshot (with both ref and data)
{
  docId: string,       // snapshot.id (the actual Firestore doc ID)
  data: AssignmentData // snapshot.data()
}
```

Note: the `id` field inside the document may differ from `docId` for UUID-era documents. Deterministic documents will have `docId === data.id === "${itemId}__${containerId}"`.

## Interfaces (defined upfront so Phase 2 tasks can run in parallel)

### `scripts/lib/assignment_analysis.js` — exported pure functions

```js
deterministicId(itemId, containerId)
// Returns: string — e.g. "abc123__def456"

isUuidId(id)
// Returns: boolean — true if id matches UUID v4 regex

groupByPair(docs)
// docs: Array<{ docId, data }>
// Returns: Map<string, Array<{ docId, data }>>
// Key is deterministicId(data.itemId, data.containerId)

classifyAssignments(docs)
// Returns: {
//   alreadyMigrated: Array<{ docId, data }>,   // docId matches deterministicId
//   clean:           Array<{ docId, data }>,   // single UUID doc per pair, no duplicate
//   duplicates:      Array<Array<{ docId, data }>> // groups with 2+ docs per pair
// }

resolveWinner(group)
// group: Array<{ docId, data }> — all docs for one pair (must be 2+)
// Returns: { winner: { docId, data }, discarded: Array<{ docId, data }> }
// Strategy: pick the doc with the highest count; on tie, pick first

buildMigrationPlan(docs)
// Returns: Array<MigrationAction>
// MigrationAction: {
//   type: 'rename' | 'merge',  // rename = 1 UUID doc, merge = 2+ UUID docs
//   newDocId: string,          // deterministic ID
//   newData: AssignmentData,   // data to write
//   toDelete: Array<string>,   // docIds to delete
//   duplicateCount: number,    // 1 for rename, 2+ for merge
// }
// Skips docs that are already migrated (docId already matches deterministic pattern)
```

### `scripts/diagnose_assignment_duplicates.js` — CLI

```
Usage:
  node diagnose_assignment_duplicates.js --project <id>

Options:
  --project <id>   Firebase project ID (required)
  --help
```

Stdout output format (chalk-colored):

```
Assignment Duplicate Diagnosis
Project: rescuenet-7733b
────────────────────────────────────────
Fetching assignments...
Total documents: 142

✓ Already migrated (deterministic ID): 12
✓ Clean (single UUID doc, no duplicate): 118
⚠ Duplicates found: 3 pairs (7 documents)

DUPLICATES DETAIL
─────────────────
Pair: abc123__def456  (itemId: abc123, containerId: def456)
  Doc 1: f3a1b2c4-... count: 1  ← winner (highest count)
  Doc 2: 9e8d7c6b-... count: 1

Pair: ...
...

MIGRATION PREVIEW
─────────────────
Actions to take:
  118 renames  (1 UUID doc → deterministic ID)
  3 merges     (multiple UUID docs → 1 deterministic ID, pick max count)
  12 skipped   (already migrated)

Run migrate_assignment_ids.js to apply these changes.
```

Exit code: always 0 (read-only, informational).

### `scripts/migrate_assignment_ids.js` — CLI

```
Usage:
  node migrate_assignment_ids.js --project <id> [--dry-run]

Options:
  --project <id>   Firebase project ID (required)
  --dry-run        Print all planned changes without writing to Firestore
  --help
```

Execution steps:
1. Fetch all assignment docs
2. Save backup to `scripts/backups/assignments_backup_<YYYY-MM-DD_HH-mm-ss>_<projectId>.json`
3. Print backup path
4. Build migration plan via `buildMigrationPlan`
5. Print plan summary (same format as diagnostic MIGRATION PREVIEW section)
6. If `--dry-run`: stop here, print "Dry run complete. No changes made."
7. Execute plan in Firestore batches of ≤250 operations (each batch: write new doc + delete old doc(s))
8. Print progress per batch
9. Print final summary: N renamed, N merged, N skipped, N total docs deleted

Backup file format: see `ASSIGNMENT_ID_MIGRATION.md`.

## Implementation Tasks

### Phase 1 — Shared Library (do first, others depend on it)

**Task 1: Create `scripts/lib/assignment_analysis.js`**

Implement all six pure functions listed in the Interfaces section above. Each function must be independently testable and have a single responsibility.

Implementation notes:
- UUID v4 regex: `/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i`
- `groupByPair` groups by `deterministicId(data.itemId, data.containerId)`
- `classifyAssignments` calls `groupByPair`, then for each group:
  - if `docId === deterministicId(...)` → `alreadyMigrated`
  - else if group size === 1 → `clean`
  - else → `duplicates` (push the whole group array)
- `buildMigrationPlan` skips `alreadyMigrated`, maps `clean` → `rename`, maps `duplicates` → `merge`
- Use `module.exports` (CommonJS)

---

### Phase 2 — Scripts and Docs (run in parallel after Phase 1)

**Task 2: Create `scripts/diagnose_assignment_duplicates.js`**

- Use `commander` for CLI args (match style of `export-firebase.js`)
- Use `initFirebaseReadOnly(projectId)` from `scripts/lib/firebase-init.js`
- Fetch all docs from the `assignments` collection: `db.collection('assignments').get()`
- Map snapshot docs to `{ docId: doc.id, data: doc.data() }`
- Call `classifyAssignments` and `buildMigrationPlan` from `assignment_analysis.js`
- Print colored report using `chalk` (chalk v4, CJS import: `const chalk = require('chalk')`)
- Top-level `async` main function, wrapped in `.catch(err => { console.error(err); process.exit(1); })`

**Task 3: Create `scripts/migrate_assignment_ids.js`**

- Same CLI/init pattern as Task 2
- Backup: write `JSON.stringify({ exportedAt, projectId, assignments: allDocs }, null, 2)` to `scripts/backups/assignments_backup_<timestamp>_<projectId>.json` where `allDocs` is `Array<{ docId, data }>`
- Use `buildMigrationPlan` from `assignment_analysis.js`
- Execute batches using `db.batch()`:
  - For each action: `batch.set(db.collection('assignments').doc(action.newDocId), action.newData)`
  - For each docId in `action.toDelete`: `batch.delete(db.collection('assignments').doc(docId))`
  - Commit every 250 operations (count set + delete ops separately, stay under 500 total per batch)
- If `--dry-run`, skip backup creation and batch execution
- Print progress with chalk

**Task 4: Create `scripts/ASSIGNMENT_ID_MIGRATION.md`**

This is the operational guide for the migration. Write it as documentation for a developer running the migration on production data. Include:

1. **Overview** — what the migration does and why (one paragraph)
2. **Prerequisites** — Node.js, service account access, running `npm install` in `scripts/`
3. **Step 1: Diagnose** — how to run the diagnostic script and what to look for
4. **Step 2: Dry run** — always run migrate with `--dry-run` first and verify the output
5. **Step 3: Migrate** — how to run the migration script for real
6. **Step 4: Verify** — after migration, re-run the diagnostic script; expected output is "0 duplicates, 0 UUID docs"
7. **Backup file format** — document the JSON structure:
   ```json
   {
     "exportedAt": "ISO timestamp",
     "projectId": "rescuenet-7733b",
     "assignments": [
       { "docId": "original-firestore-doc-id", "data": { "id": "...", "itemId": "...", "containerId": "...", "count": 1 } }
     ]
   }
   ```
8. **Restore procedure** — step-by-step instructions:
   - Step R1: Locate the backup file in `scripts/backups/`
   - Step R2: Run a restore script (inline Node.js snippet — one-liner or short script) that:
     - Reads the backup JSON
     - Deletes all current assignment docs (batched)
     - Writes back every `{ docId, data }` from the backup using `doc(docId).set(data)`
   - Step R3: Re-run the diagnostic script to confirm state matches pre-migration
9. **Duplicate resolution strategy** — document that winner = max count, tie = first found, and that all merges are logged to stdout during migration

---

## Execution Order for Subagents

```
[Subagent A]  Task 1 (assignment_analysis.js)
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
[Sub B] Task 2   [Sub C] Task 3  [Sub D] Task 4
(diagnose)       (migrate)       (docs)
```

Subagents B and C require Task 1 to be complete first (they import `assignment_analysis.js`).
Subagent D (docs) can run in parallel with Tasks 1–3 since interfaces are fully specified above.

## Acceptance Criteria

- [ ] `node diagnose_assignment_duplicates.js --project rescuenet-7733b` runs without error and prints a structured report
- [ ] `node migrate_assignment_ids.js --project rescuenet-7733b --dry-run` prints planned changes without modifying Firestore
- [ ] Backup file is valid JSON matching the documented schema
- [ ] `ASSIGNMENT_ID_MIGRATION.md` contains complete restore instructions with a working code snippet
- [ ] All functions in `assignment_analysis.js` are pure (no side effects, no I/O)
- [ ] No new npm dependencies introduced

## Out of Scope

- Running the migration itself (that is a manual step, after reviewing diagnostic output)
- Phase 3 cleanup (simplifying `getAssignmentByIds` to direct doc lookup, removing dead duplicate checks in notifiers)
