#!/usr/bin/env node

/**
 * Firebase Import CLI Tool
 *
 * Imports Firestore collections and Storage files from GCS export to Firebase project.
 * Requires explicit user confirmation and --execute flag for safety.
 *
 * Usage:
 *   node import-firebase.js --source gs://bucket/path/manifest.json --project rescuenet-testing --execute
 */

const { program } = require('commander');
const chalk = require('chalk');
const { Storage } = require('@google-cloud/storage');
const path = require('path');
const { parseGcsUri, readJSON, getGcsUri } = require('./lib/gcs-client');
const { initFirebaseReadOnly, getServiceAccountPath } = require('./lib/firebase-init');
const { validateManifest, importAllCollections } = require('./lib/firestore-import');
const { restoreStorageFiles } = require('./lib/storage-import');
const { displayManifest, confirmImport } = require('./lib/safety-prompts');
const { detectStorageBucket } = require('./lib/storage-bucket-detector');

/**
 * Main import function
 */
async function importFirebase() {
  // Parse CLI arguments
  program
    .name('import-firebase')
    .description('Import Firestore and Storage data from GCS export to Firebase')
    .requiredOption('--source <uri>', 'GCS URI of the manifest file (gs://bucket/path/manifest.json)')
    .requiredOption('--project <id>', 'Target Firebase project ID')
    .option('--skip-storage', 'Skip importing storage files', false)
    .option('--skip-clear', 'Skip clearing collections before import (may cause conflicts)', false)
    .option('--collections <list>', 'Comma-separated list of collections to import (default: all)')
    .option('--execute', 'Execute the import (without this flag, runs in dry-run mode)', false)
    .option('--yes', 'Skip confirmation prompts (DANGEROUS - use only in automated scripts)', false)
    .parse(process.argv);

  const options = program.opts();

  console.log(chalk.cyan.bold('\n=== Firebase Import Tool ===\n'));

  try {
    // Step 1: Parse source URI
    console.log(chalk.white('Step 1: Parsing source URI...'));
    const { bucketName, path: manifestPath } = parseGcsUri(options.source);
    console.log(chalk.green(`✓ Parsed: gs://${bucketName}/${manifestPath}`));

    // Step 2: Connect to GCS bucket using Storage SDK
    console.log(chalk.white('\nStep 2: Connecting to GCS bucket...'));
    const serviceAccountPath = getServiceAccountPath(options.project);
    const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });
    const sourceBucket = storage.bucket(bucketName);
    console.log(chalk.green(`✓ Connected to bucket: ${bucketName}`));

    // Step 3: Read manifest from GCS
    console.log(chalk.white('\nStep 3: Reading export manifest...'));
    const manifest = await readJSON(sourceBucket, manifestPath);
    console.log(chalk.green(`✓ Manifest loaded`));

    // Step 4: Validate manifest
    console.log(chalk.white('\nStep 4: Validating manifest...'));
    const validation = validateManifest(manifest);
    if (!validation.valid) {
      console.error(chalk.red('\n❌ Invalid manifest:'));
      validation.errors.forEach(error => console.error(chalk.red(`  - ${error}`)));
      process.exit(1);
    }
    console.log(chalk.green('✓ Manifest is valid'));

    // Step 5: Display what will be imported
    console.log(chalk.white('\nStep 5: Preview of import operation...'));
    displayManifest(manifest);

    // Filter collections if specified
    const collectionsToImport = options.collections
      ? options.collections.split(',').map(c => c.trim())
      : Object.keys(manifest.collections || {});

    console.log(chalk.cyan('Target Project:'), chalk.yellow.bold(options.project));
    console.log(chalk.cyan('Collections to import:'), collectionsToImport.join(', '));
    console.log(chalk.cyan('Clear before import:'), options.skipClear ? 'No' : 'Yes');
    console.log(chalk.cyan('Import storage:'), options.skipStorage ? 'No' : 'Yes');

    // Step 6: Check if dry-run mode
    if (!options.execute) {
      console.log(chalk.yellow.bold('\n⚠️  DRY-RUN MODE ⚠️'));
      console.log(chalk.yellow('No changes will be made.'));
      console.log(chalk.yellow('To execute the import, add the --execute flag.'));
      console.log(chalk.white('\nExample:'));
      console.log(chalk.cyan(`  node import-firebase.js --source ${options.source} --project ${options.project} --execute`));
      process.exit(0);
    }

    // Step 7: Get user confirmation (unless --yes flag)
    if (!options.yes) {
      console.log(chalk.white('\nStep 6: Requesting user confirmation...'));
      const confirmed = await confirmImport({ manifest }, options.project);
      if (!confirmed) {
        console.log(chalk.red('\n❌ Import cancelled by user.'));
        process.exit(0);
      }
    } else {
      console.log(chalk.red.bold('\n⚠️  SKIPPING CONFIRMATION (--yes flag) ⚠️'));
      console.log(chalk.red('This is dangerous and should only be used in automated scripts.'));
      console.log(chalk.yellow('Proceeding in 3 seconds...'));
      await new Promise(resolve => setTimeout(resolve, 3000));
    }

    // Step 8: Initialize target Firebase
    console.log(chalk.white('\nStep 7: Initializing target Firebase...'));
    const { db } = await initFirebaseReadOnly(options.project);
    console.log(chalk.green(`✓ Connected to project: ${options.project}`));

    // Initialize target storage bucket with auto-detection
    console.log(chalk.white('Detecting target storage bucket...'));
    const targetBucketName = await detectStorageBucket(options.project, storage);
    const targetStorageBucket = storage.bucket(targetBucketName);
    console.log(chalk.green(`✓ Target storage: ${targetBucketName}\n`));

    // Step 9: Read collection data from GCS
    console.log(chalk.white('\nStep 8: Loading collection data from GCS...'));
    const collectionsData = {};

    // Get the base path (directory containing manifest)
    const basePath = manifestPath.substring(0, manifestPath.lastIndexOf('/'));

    for (const collectionName of collectionsToImport) {
      const collectionInfo = manifest.collections[collectionName];
      if (!collectionInfo) {
        console.log(chalk.yellow(`  ⚠️  Collection "${collectionName}" not found in manifest, skipping`));
        continue;
      }

      const collectionPath = `${basePath}/${collectionInfo.file}`;
      console.log(chalk.white(`  Loading ${collectionName} from ${collectionInfo.file}...`));

      try {
        const collectionData = await readJSON(sourceBucket, collectionPath);
        collectionsData[collectionName] = collectionData;
        console.log(chalk.green(`  ✓ Loaded ${collectionName}: ${collectionData.docs?.length || 0} documents`));
      } catch (error) {
        console.error(chalk.red(`  ❌ Failed to load ${collectionName}: ${error.message}`));
        throw error;
      }
    }

    // Step 10: Import collections
    console.log(chalk.white('\nStep 9: Importing collections to Firestore...'));
    const clearFirst = !options.skipClear;
    const importResults = await importAllCollections(
      db,
      collectionsData,
      clearFirst
    );

    // Step 11: Import storage files (if not skipped)
    let storageResults = null;
    if (!options.skipStorage && manifest.storage && manifest.storage.fileCount > 0) {
      console.log(chalk.white('\nStep 10: Importing storage files...'));
      const storagePrefix = `${basePath}/storage`;
      storageResults = await restoreStorageFiles(
        sourceBucket,
        storagePrefix,
        targetStorageBucket
      );
    } else if (options.skipStorage) {
      console.log(chalk.yellow('\nSkipping storage import (--skip-storage flag)'));
    } else {
      console.log(chalk.white('\nNo storage files to import'));
    }

    // Step 12: Print summary
    console.log(chalk.green.bold('\n=== Import Complete ===\n'));

    console.log(chalk.cyan('Firestore Collections:'));
    let totalImported = 0;
    let totalDeleted = 0;
    let totalErrors = 0;

    for (const [collectionName, result] of Object.entries(importResults)) {
      const status = result.errors.length > 0 ? chalk.yellow('⚠️') : chalk.green('✓');
      console.log(`  ${status} ${collectionName}:`);
      if (result.deleted > 0) {
        console.log(`    Deleted: ${result.deleted} documents`);
      }
      console.log(`    Imported: ${result.imported} documents`);
      if (result.errors.length > 0) {
        console.log(`    Errors: ${result.errors.length}`);
      }

      totalImported += result.imported;
      totalDeleted += result.deleted;
      totalErrors += result.errors.length;
    }

    console.log(chalk.cyan('\nTotals:'));
    console.log(`  Documents deleted: ${totalDeleted}`);
    console.log(`  Documents imported: ${totalImported}`);
    console.log(`  Import errors: ${totalErrors}`);

    if (storageResults) {
      console.log(chalk.cyan('\nStorage Files:'));
      console.log(`  Files copied: ${storageResults.copied}`);
      console.log(`  Files skipped: ${storageResults.skipped}`);
      console.log(`  Copy errors: ${storageResults.errors.length}`);
    }

    if (totalErrors > 0 || (storageResults && storageResults.errors.length > 0)) {
      console.log(chalk.yellow('\n⚠️  Import completed with some errors. Check logs above for details.'));
      process.exit(1);
    } else {
      console.log(chalk.green('\n✓ Import completed successfully!'));
      process.exit(0);
    }

  } catch (error) {
    console.error(chalk.red.bold('\n❌ Import failed:'));
    console.error(chalk.red(error.message));
    if (error.stack) {
      console.error(chalk.gray('\nStack trace:'));
      console.error(chalk.gray(error.stack));
    }
    process.exit(1);
  }
}

// Run the import
importFirebase();
