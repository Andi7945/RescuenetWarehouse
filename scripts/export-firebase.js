#!/usr/bin/env node

const { Command } = require('commander');
const path = require('path');
const { Storage } = require('@google-cloud/storage');
const { initFirebaseReadOnly, getServiceAccountPath } = require('./lib/firebase-init');
const { writeJSON } = require('./lib/gcs-client');
const { exportAllCollections, createManifest } = require('./lib/firestore-export');
const { copyStorageFiles } = require('./lib/storage-export');
const { detectStorageBucket } = require('./lib/storage-bucket-detector');

async function exportFirebase() {
  const program = new Command();

  program
    .name('export-firebase')
    .description('Export Firebase Firestore and Storage data to Google Cloud Storage')
    .requiredOption('--project <id>', 'Firebase project ID')
    .requiredOption('--bucket <name>', 'GCS bucket name for export')
    .option('--output <path>', 'Output path in bucket (default: exports/{YYYY-MM-DD}-{projectId})')
    .option('--skip-storage', 'Skip storage file export')
    .option('--collections <list>', 'Comma-separated collection names (default: all collections)')
    .option('--dry-run', 'Show plan without writing')
    .parse();

  const options = program.opts();

  // Generate default output path if not provided
  const defaultPath = `exports/${new Date().toISOString().split('T')[0]}-${options.project}`;
  const outputPath = options.output || defaultPath;

  // Handle dry-run mode
  if (options.dryRun) {
    console.log('\n=== DRY RUN MODE ===');
    console.log('Export Plan:');
    console.log(`  Project: ${options.project}`);
    console.log(`  Target Bucket: ${options.bucket}`);
    console.log(`  Output Path: ${outputPath}`);
    console.log(`  Collections: ${options.collections || 'all'}`);
    console.log(`  Skip Storage: ${options.skipStorage ? 'yes' : 'no'}`);
    console.log('\nNo data will be exported in dry-run mode.');
    console.log('Remove --dry-run flag to perform actual export.\n');
    return;
  }

  const startTime = Date.now();

  console.log('\n=== Firebase Export Tool ===');
  console.log(`Project: ${options.project}`);
  console.log(`Target: gs://${options.bucket}/${outputPath}\n`);

  try {
    // Initialize Firebase (for Firestore only)
    console.log('Initializing Firebase...');
    const { db } = await initFirebaseReadOnly(options.project);
    console.log('✓ Firebase initialized\n');

    // Initialize GCS Storage SDK (used for BOTH source and target buckets)
    // This ensures bucket references are compatible for cross-bucket copying
    console.log('Initializing GCS Storage SDK...');
    const serviceAccountPath = getServiceAccountPath(options.project);
    const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });

    // Auto-detect which storage bucket domain exists (.appspot.com or .firebasestorage.app)
    // This handles both legacy and modern Firebase projects
    const sourceBucketName = await detectStorageBucket(options.project, storage);
    const sourceBucket = storage.bucket(sourceBucketName);
    const targetBucket = storage.bucket(options.bucket);

    console.log(`✓ GCS Storage SDK initialized (source: ${sourceBucketName})\n`);

    // Export Firestore collections
    console.log('Exporting Firestore collections...');
    const collectionsToExport = options.collections
      ? options.collections.split(',').map(s => s.trim())
      : undefined;

    const collectionsData = await exportAllCollections(db, collectionsToExport);
    console.log(`✓ Exported ${Object.keys(collectionsData).length} collections\n`);

    // Export Storage files (if not skipped)
    let storageResult = null;
    if (!options.skipStorage) {
      console.log('Exporting Storage files...');
      storageResult = await copyStorageFiles(sourceBucket, targetBucket, `${outputPath}/storage`, 5);
      console.log(`✓ Copied ${storageResult.copied} files (${storageResult.totalBytes} bytes)\n`);
    } else {
      console.log('⊘ Skipping Storage export\n');
    }

    // Create manifest
    console.log('Creating manifest...');
    const manifest = createManifest(collectionsData, options.project);
    if (storageResult) {
      manifest.storage = {
        filesCopied: storageResult.copied,
        bytesTransferred: storageResult.totalBytes,
        errors: storageResult.errors.length
      };
    }
    console.log('✓ Manifest created\n');

    // Write all data to GCS
    console.log('Writing data to GCS...');

    // Write manifest
    await writeJSON(targetBucket, `${outputPath}/manifest.json`, manifest);
    console.log(`  ✓ manifest.json`);

    // Write each collection
    for (const [collectionName, collectionData] of Object.entries(collectionsData)) {
      await writeJSON(targetBucket, `${outputPath}/firestore/${collectionName}.json`, collectionData.docs);
      console.log(`  ✓ firestore/${collectionName}.json (${collectionData.count} documents)`);
    }

    // Write storage summary (if storage was exported)
    if (storageResult) {
      await writeJSON(targetBucket, `${outputPath}/storage/summary.json`, storageResult);
      console.log(`  ✓ storage/summary.json`);
    }

    // Calculate elapsed time
    const elapsedSeconds = ((Date.now() - startTime) / 1000).toFixed(2);

    // Print summary
    console.log('\n=== Export Complete ===');
    console.log(`Location: gs://${options.bucket}/${outputPath}`);
    console.log('\nCollections exported:');
    for (const [collectionName, collectionData] of Object.entries(collectionsData)) {
      console.log(`  - ${collectionName}: ${collectionData.count} documents`);
    }
    if (storageResult) {
      console.log(`\nStorage files: ${storageResult.copied} files (${storageResult.totalBytes} bytes)`);
    }
    console.log(`\nTotal time: ${elapsedSeconds}s\n`);

  } catch (error) {
    console.error('\n✗ Export failed:', error.message);
    if (error.stack) {
      console.error('\nStack trace:');
      console.error(error.stack);
    }
    process.exit(1);
  }
}

exportFirebase().catch(error => {
  console.error('Export failed:', error.message);
  process.exit(1);
});
