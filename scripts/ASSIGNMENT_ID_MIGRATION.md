# Assignment ID Migration Runbook

## Overview

This migration converts Firestore assignment documents from random UUID-based document IDs to deterministic IDs of the form `"${itemId}__${containerId}"`. Where multiple documents exist for the same item/container pair (duplicates), they are resolved by keeping the document with the highest `count` value; in the event of a tie, the first document found is kept. The purpose is to enforce the one-assignment-per-pair business rule at the data level, making duplicate creation structurally impossible going forward.

---

## Prerequisites

- **Node.js 18+** must be installed and available on your `PATH`.
- Service account JSON files must be present at:
  - `scripts/secrets/rescuenet-production.json`
  - `scripts/secrets/rescuenet-testing.json`
- Dependencies must be installed. Run the following from inside the `scripts/` directory:

```bash
npm install
```

---

## Step 1: Diagnose

Run the diagnostic script to inspect the current state of the `assignments` collection:

```bash
node diagnose_assignment_duplicates.js --project rescuenet-7733b
```

**What to look for in the output:**

- **Duplicate count** — the number of item/container pairs that have more than one assignment document.
- **Migration preview** — a list of all documents, showing which would be kept and which would be deleted during migration.

Record the total document count and duplicate count before proceeding. You will verify these numbers again after migration.

---

## Step 2: Dry Run

Always perform a dry run before executing the real migration:

```bash
node migrate_assignment_ids.js --project rescuenet-7733b --dry-run
```

In dry-run mode the script simulates all changes without writing anything to Firestore. Verify that:

- The number of documents to be created matches the unique pair count from Step 1.
- The number of duplicates to be removed matches the duplicate count from Step 1.

Do not proceed to Step 3 until the dry-run counts are consistent with the diagnosis output.

---

## Step 3: Migrate

Run the migration for real:

```bash
node migrate_assignment_ids.js --project rescuenet-7733b
```

The script will:

1. Write a full backup of the current `assignments` collection before making any changes (see [Backup file format](#backup-file-format) below).
2. Create new documents using deterministic IDs.
3. Delete the old UUID-based documents and any resolved duplicates.
4. Print all merge decisions to stdout.

Wait for the `Migration complete` message before closing the terminal or taking any further action.

---

## Step 4: Verify

Re-run the diagnostic script:

```bash
node diagnose_assignment_duplicates.js --project rescuenet-7733b
```

**Expected output after a successful migration:**

- **0 duplicates**
- **0 UUID docs** — every document should be reported as "Already migrated"

If any duplicates or UUID-based documents remain, do not use the application until they are resolved.

---

## Backup File Format

Before any writes are performed, the migration script saves a complete snapshot of the `assignments` collection. The backup is a JSON file with the following structure:

```json
{
  "exportedAt": "2026-05-09T12:00:00.000Z",
  "projectId": "rescuenet-7733b",
  "assignments": [
    {
      "docId": "original-firestore-doc-id",
      "data": {
        "id": "...",
        "itemId": "...",
        "containerId": "...",
        "count": 1
      }
    }
  ]
}
```

Backup files are written to:

```
scripts/backups/assignments_backup_<YYYY-MM-DD_HH-mm-ss>_<projectId>.json
```

---

## Restore Procedure

If you need to roll back the migration, follow these steps.

### Step R1: Locate the backup file

Find the backup created immediately before your migration run:

```
scripts/backups/
```

Select the file whose timestamp matches your migration run (e.g., `assignments_backup_2026-05-09_12-00-00_rescuenet-7733b.json`).

### Step R2: Run the restore script

Copy the script below into a file named `restore.js` inside the `scripts/` directory, then run it:

```js
// restore.js — run: node restore.js <backup-file> <project-id>
const admin = require('firebase-admin');
const fs = require('fs');
const { initFirebaseReadOnly } = require('./lib/firebase-init');

async function restore() {
  const [,, backupFile, projectId] = process.argv;
  if (!backupFile || !projectId) { console.error('Usage: node restore.js <backup-file> <project-id>'); process.exit(1); }
  const backup = JSON.parse(fs.readFileSync(backupFile, 'utf8'));
  const { db } = await initFirebaseReadOnly(projectId);
  // Delete all current assignments
  const snap = await db.collection('assignments').get();
  let batch = db.batch(); let ops = 0;
  for (const doc of snap.docs) {
    batch.delete(doc.ref); ops++;
    if (ops === 499) { await batch.commit(); batch = db.batch(); ops = 0; }
  }
  if (ops > 0) await batch.commit();
  // Restore from backup
  batch = db.batch(); ops = 0;
  for (const { docId, data } of backup.assignments) {
    batch.set(db.collection('assignments').doc(docId), data); ops++;
    if (ops === 499) { await batch.commit(); batch = db.batch(); ops = 0; }
  }
  if (ops > 0) await batch.commit();
  console.log(`Restored ${backup.assignments.length} documents from ${backupFile}`);
}
restore().catch(e => { console.error(e); process.exit(1); });
```

Run it from inside `scripts/`:

```bash
node restore.js backups/assignments_backup_<YYYY-MM-DD_HH-mm-ss>_rescuenet-7733b.json rescuenet-7733b
```

### Step R3: Verify the restored state

Re-run the diagnostic script to confirm the collection matches the pre-migration state:

```bash
node diagnose_assignment_duplicates.js --project rescuenet-7733b
```

The output should reflect the original duplicate and document counts that were recorded in Step 1.

---

## Duplicate Resolution Strategy

When multiple documents share the same `itemId`/`containerId` pair, the migration applies the following rules in order:

1. **Max count wins** — the document with the highest `count` value is kept as the canonical record.
2. **Tie-breaking** — if two or more documents have equal `count` values, the first document encountered in the collection scan is kept.
3. **Transparency** — every merge decision is printed to stdout during migration, including the document IDs involved and the chosen `count` value. Review this output to audit which data was retained and which was discarded.
