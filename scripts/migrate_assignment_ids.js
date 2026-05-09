'use strict';

const { Command } = require('commander');
const chalk = require('chalk');
const fs = require('fs');
const path = require('path');
const { initFirebaseReadOnly } = require('./lib/firebase-init');
const { buildMigrationPlan, classifyAssignments } = require('./lib/assignment_analysis');

const MAX_OPS_PER_BATCH = 250;

function formatTimestamp(date) {
  const pad = (n) => String(n).padStart(2, '0');
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
    `_${pad(date.getHours())}-${pad(date.getMinutes())}-${pad(date.getSeconds())}`
  );
}

function countOpsForAction(action) {
  return 1 + action.toDelete.length;
}

async function executePlan(db, plan) {
  let renamed = 0;
  let merged = 0;
  let totalDeleted = 0;

  const batches = [];
  let currentBatch = db.batch();
  let currentOps = 0;
  let currentActions = [];

  for (const action of plan) {
    const opsNeeded = countOpsForAction(action);
    if (currentOps + opsNeeded > MAX_OPS_PER_BATCH && currentOps > 0) {
      batches.push({ batch: currentBatch, actions: currentActions, ops: currentOps });
      currentBatch = db.batch();
      currentOps = 0;
      currentActions = [];
    }
    currentBatch.set(db.collection('assignments').doc(action.newDocId), action.newData);
    for (const docId of action.toDelete) {
      currentBatch.delete(db.collection('assignments').doc(docId));
    }
    currentOps += opsNeeded;
    currentActions.push(action);
  }
  if (currentOps > 0) {
    batches.push({ batch: currentBatch, actions: currentActions, ops: currentOps });
  }

  const total = batches.length;
  for (let i = 0; i < batches.length; i++) {
    const { batch, actions, ops } = batches[i];
    await batch.commit();
    console.log(`Batch ${i + 1}/${total}: committed ${ops} operations`);

    for (const action of actions) {
      if (action.type === 'rename') {
        renamed++;
        totalDeleted += action.toDelete.length;
      } else if (action.type === 'merge') {
        merged++;
        totalDeleted += action.toDelete.length;
        console.log(
          `  Merged ${action.toDelete.length} docs into ${action.newDocId}: [${action.toDelete.join(', ')}]`
        );
      }
    }
  }

  return { renamed, merged, totalDeleted };
}

async function main() {
  const program = new Command();
  program
    .requiredOption('--project <id>', 'Firebase project ID')
    .option('--dry-run', 'Print all planned changes without writing to Firestore')
    .helpOption('--help')
    .parse(process.argv);

  const { project, dryRun } = program.opts();

  const { db } = await initFirebaseReadOnly(project);

  const snap = await db.collection('assignments').get();
  const allDocs = snap.docs.map((d) => ({ docId: d.id, data: d.data() }));

  if (!dryRun) {
    const timestamp = formatTimestamp(new Date());
    const filename = `assignments_backup_${timestamp}_${project}.json`;
    const backupPath = path.join(__dirname, 'backups', filename);
    fs.mkdirSync(path.join(__dirname, 'backups'), { recursive: true });
    fs.writeFileSync(
      backupPath,
      JSON.stringify({ exportedAt: new Date().toISOString(), projectId: project, assignments: allDocs }, null, 2)
    );
    console.log(chalk.green('✓ Backup saved to:'), backupPath);
  }

  const plan = buildMigrationPlan(allDocs);
  const { alreadyMigrated } = classifyAssignments(allDocs);

  const renames = plan.filter((a) => a.type === 'rename').length;
  const merges = plan.filter((a) => a.type === 'merge').length;
  const skipped = alreadyMigrated.length;

  console.log(chalk.bold('\nMIGRATION PLAN'));
  console.log('──────────────');
  console.log('Actions to take:');
  console.log(`  ${renames} renames  (1 UUID doc → deterministic ID)`);
  console.log(`  ${merges} merges   (multiple UUID docs → 1 deterministic ID, pick max count)`);
  console.log(`  ${skipped} skipped  (already migrated)`);

  if (dryRun) {
    console.log('\n' + chalk.yellow('Dry run complete. No changes made.'));
    process.exit(0);
  }

  const { renamed, merged, totalDeleted } = await executePlan(db, plan);

  console.log(chalk.bold('\nMigration complete.'));
  console.log(`  ${renamed} renamed`);
  console.log(`  ${merged} merged`);
  console.log(`  ${skipped} skipped`);
  console.log(`  ${totalDeleted} total documents deleted`);
}

main().catch((err) => {
  console.error(chalk.red('Error:'), err.message);
  process.exit(1);
});
