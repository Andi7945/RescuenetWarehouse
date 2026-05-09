'use strict';

const { Command } = require('commander');
const chalk = require('chalk');
const { initFirebaseReadOnly } = require('./lib/firebase-init');
const { classifyAssignments, buildMigrationPlan, resolveWinner } = require('./lib/assignment_analysis');

const SEPARATOR = chalk.gray('─'.repeat(40));
const SECTION_SEP = chalk.gray('─'.repeat(17));

async function main() {
  const program = new Command();
  program
    .requiredOption('--project <id>', 'Firebase project ID')
    .helpOption('--help')
    .parse(process.argv);

  const { project } = program.opts();

  console.log(chalk.bold('Assignment Duplicate Diagnosis'));
  console.log(`Project: ${project}`);
  console.log(SEPARATOR);

  console.log('Fetching assignments...');
  const { db } = await initFirebaseReadOnly(project);
  const snap = await db.collection('assignments').get();
  const docs = snap.docs.map((d) => ({ docId: d.id, data: d.data() }));

  console.log(`Total documents: ${docs.length}`);
  console.log();

  const { alreadyMigrated, clean, duplicates } = classifyAssignments(docs);
  const duplicateDocCount = duplicates.reduce((sum, g) => sum + g.length, 0);

  console.log(chalk.green(`✓ Already migrated (deterministic ID): ${alreadyMigrated.length}`));
  console.log(chalk.green(`✓ Clean (single UUID doc, no duplicate): ${clean.length}`));

  if (duplicates.length === 0) {
    console.log(chalk.green('✓ No duplicates found'));
  } else {
    console.log(
      chalk.yellow(`⚠ Duplicates found: ${duplicates.length} pairs (${duplicateDocCount} documents)`)
    );
  }

  if (duplicates.length > 0) {
    console.log();
    console.log(chalk.bold('DUPLICATES DETAIL'));
    console.log(SECTION_SEP);

    for (const group of duplicates) {
      const { winner } = resolveWinner(group);
      const pairKey = `${group[0].data.itemId}__${group[0].data.containerId}`;
      console.log(
        `Pair: ${pairKey}  (itemId: ${group[0].data.itemId}, containerId: ${group[0].data.containerId})`
      );

      const sorted = [...group].sort((a, b) => (b.data.count ?? 0) - (a.data.count ?? 0));
      sorted.forEach((doc, idx) => {
        const isWinner = doc.docId === winner.docId;
        const winnerMarker = isWinner ? `  ${chalk.cyan('← winner (highest count)')}` : '';
        console.log(`  Doc ${idx + 1}: ${doc.docId}  itemId: ${doc.data.itemId}  containerId: ${doc.data.containerId}  count: ${doc.data.count ?? 0}${winnerMarker}`);
      });

      console.log();
    }
  }

  const plan = buildMigrationPlan(docs);
  const renames = plan.filter((a) => a.type === 'rename').length;
  const merges = plan.filter((a) => a.type === 'merge').length;
  const skipped = alreadyMigrated.length;

  console.log(chalk.bold('MIGRATION PREVIEW'));
  console.log(SECTION_SEP);
  console.log('Actions to take:');
  console.log(`  ${renames} renames  (1 UUID doc → deterministic ID)`);
  console.log(`  ${merges} merges     (multiple UUID docs → 1 deterministic ID, pick max count)`);
  console.log(`  ${skipped} skipped   (already migrated)`);
  console.log();
  console.log('Run migrate_assignment_ids.js to apply these changes.');
}

main().catch((err) => {
  console.error(chalk.red('Error:'), err.message);
  process.exit(1);
});
