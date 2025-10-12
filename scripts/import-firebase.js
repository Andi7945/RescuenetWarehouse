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
const gcsClient = require('./lib/gcs-client');
const localClient = require('./lib/local-client');
const { initFirebaseReadOnly, getServiceAccountPath } = require('./lib/firebase-init');
const { importAllCollections } = require('./lib/firestore-import');
const { restoreStorageFiles, restoreStorageFilesLocal } = require('./lib/storage-import');
const { displayManifest, confirmImport } = require('./lib/safety-prompts');
const { detectStorageBucket } = require('./lib/storage-bucket-detector');
const manifest = require('./lib/manifest');

/**
 * Main import function
 */
async function importFirebase() {
  // Parse CLI arguments
  program
    .name('import-firebase')
    .description('Import Firestore and Storage data from GCS or local export to Firebase')
    .option('--source <uri>', 'GCS URI of the manifest file (gs://bucket/path/manifest.json)')
    .option('--local-input <path>', 'Local directory containing export data (alternative to --source)')
    .requiredOption('--project <id>', 'Target Firebase project ID')
    .option('--skip-storage', 'Skip importing storage files', false)
    .option('--skip-clear', 'Skip clearing collections before import (may cause conflicts)', false)
    .option('--collections <list>', 'Comma-separated list of collections to import (default: all)')
    .option('--execute', 'Execute the import (without this flag, runs in dry-run mode)', false)
    .option('--yes', 'Skip confirmation prompts (DANGEROUS - use only in automated scripts)', false)
    .parse(process.argv);

  const options = program.opts();

  // Validate that exactly one source is specified
  if (!options.source && !options.localInput) {
    console.error(chalk.red('\n✗ Error: Must specify either --source or --local-input'));
    console.error('\nExamples:');
    console.error(chalk.cyan('  node import-firebase.js --source gs://bucket/exports/manifest.json --project my-project --execute'));
    console.error(chalk.cyan('  node import-firebase.js --local-input ./backups/2025-01-15 --project my-project --execute\n'));
    process.exit(1);
  }

  if (options.source && options.localInput) {
    console.error(chalk.red('\n✗ Error: Cannot use both --source and --local-input'));
    console.error(chalk.red('Choose one import source.\n'));
    process.exit(1);
  }

  // Detect mode
  const isLocalMode = Boolean(options.localInput);

  console.log(chalk.cyan.bold('\n=== Firebase Import Tool ===\n'));

  try {
    // Step 1: Parse/validate source
    let bucketName, manifestPath, basePath, sourceBucket;

    if (isLocalMode) {
      console.log(chalk.white('Step 1: Validating local input path...'));
      const resolvedPath = path.resolve(options.localInput);

      // Check if directory exists
      if (!await localClient.fileExists(resolvedPath)) {
        console.error(chalk.red(`\n✗ Directory not found: ${resolvedPath}`));
        process.exit(1);
      }

      manifestPath = path.join(resolvedPath, 'manifest.json');
      if (!await localClient.fileExists(manifestPath)) {
        console.error(chalk.red(`\n✗ Manifest not found: ${manifestPath}`));
        console.error(chalk.red('Ensure the directory contains a valid export with manifest.json'));
        process.exit(1);
      }

      basePath = resolvedPath;
      console.log(chalk.green(`✓ Validated: ${resolvedPath}`));
    } else {
      console.log(chalk.white('Step 1: Parsing source URI...'));
      const parsed = gcsClient.parseGcsUri(options.source);
      bucketName = parsed.bucketName;
      manifestPath = parsed.path;
      console.log(chalk.green(`✓ Parsed: gs://${bucketName}/${manifestPath}`));

      // Get base path for GCS (directory containing manifest)
      basePath = manifestPath.substring(0, manifestPath.lastIndexOf('/'));
    }

    // Step 2: Connect to GCS (if needed for source or target storage)
    console.log(chalk.white('\nStep 2: Initializing storage SDK...'));
    const serviceAccountPath = getServiceAccountPath(options.project);
    const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });

    if (!isLocalMode) {
      sourceBucket = storage.bucket(bucketName);
      console.log(chalk.green(`✓ Connected to source bucket: ${bucketName}`));
    } else {
      console.log(chalk.green(`✓ Storage SDK initialized (for target storage)`));
    }

    // Step 3: Read manifest
    console.log(chalk.white('\nStep 3: Reading export manifest...'));
    let importManifest;
    if (isLocalMode) {
      importManifest = await localClient.readJSON(manifestPath);
    } else {
      importManifest = await gcsClient.readJSON(sourceBucket, manifestPath);
    }
    console.log(chalk.green(`✓ Manifest loaded`));

    // Step 4: Validate manifest
    console.log(chalk.white('\nStep 4: Validating manifest...'));
    const validation = manifest.validateManifest(importManifest);
    if (!validation.valid) {
      console.error(chalk.red('\n❌ Invalid manifest:'));
      validation.errors.forEach(error => console.error(chalk.red(`  - ${error}`)));
      process.exit(1);
    }
    console.log(chalk.green('✓ Manifest is valid'));

    // Step 5: Display what will be imported
    console.log(chalk.white('\nStep 5: Preview of import operation...'));
    displayManifest(importManifest);

    // Build collection map for easy lookup
    const collectionsMap = {};
    importManifest.collections.forEach(col => {
      collectionsMap[col.name] = col;
    });

    // Filter collections if specified
    const collectionsToImport = options.collections
      ? options.collections.split(',').map(c => c.trim())
      : importManifest.collections.map(c => c.name);

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

    // Step 9: Read collection data
    console.log(chalk.white(`\nStep 8: Loading collection data from ${isLocalMode ? 'local filesystem' : 'GCS'}...`));
    const collectionsData = {};

    for (const collectionName of collectionsToImport) {
      const collectionInfo = collectionsMap[collectionName];
      if (!collectionInfo) {
        console.log(chalk.yellow(`  ⚠️  Collection "${collectionName}" not found in manifest, skipping`));
        continue;
      }

      console.log(chalk.white(`  Loading ${collectionName} from ${collectionInfo.filePath}...`));

      try {
        let collectionData;
        if (isLocalMode) {
          const collectionPath = path.join(basePath, collectionInfo.filePath);
          collectionData = await localClient.readJSON(collectionPath);
        } else {
          const collectionPath = `${basePath}/${collectionInfo.filePath}`;
          collectionData = await gcsClient.readJSON(sourceBucket, collectionPath);
        }

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
    if (!options.skipStorage && importManifest.storage && importManifest.storage.fileCount > 0) {
      console.log(chalk.white('\nStep 10: Importing storage files...'));

      // Initialize target storage bucket with auto-detection
      console.log(chalk.white('Detecting target storage bucket...'));
      const targetBucketName = await detectStorageBucket(options.project, storage);
      const targetStorageBucket = storage.bucket(targetBucketName);
      console.log(chalk.green(`✓ Target storage: ${targetBucketName}`));

      if (isLocalMode) {
        const storageDir = path.join(basePath, 'storage');
        storageResults = await restoreStorageFilesLocal(
          storageDir,
          targetStorageBucket
        );
      } else {
        const storagePrefix = `${basePath}/storage`;
        storageResults = await restoreStorageFiles(
          sourceBucket,
          storagePrefix,
          targetStorageBucket
        );
      }
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
