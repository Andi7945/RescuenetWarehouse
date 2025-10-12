#!/usr/bin/env node

const { Command } = require('commander');
const path = require('path');
const { Storage } = require('@google-cloud/storage');
const { initFirebaseReadOnly, getServiceAccountPath } = require('./lib/firebase-init');
const gcsClient = require('./lib/gcs-client');
const localClient = require('./lib/local-client');
const { exportAllCollections, createManifest: createOldManifest } = require('./lib/firestore-export');
const { copyStorageFiles, copyStorageFilesLocal } = require('./lib/storage-export');
const { detectStorageBucket } = require('./lib/storage-bucket-detector');
const manifest = require('./lib/manifest');

async function exportFirebase() {
  const program = new Command();

  program
    .name('export-firebase')
    .description('Export Firebase Firestore and Storage data to GCS or local filesystem')
    .requiredOption('--project <id>', 'Firebase project ID')
    .option('--bucket <name>', 'GCS bucket name for export')
    .option('--local-output <path>', 'Local directory for export (alternative to --bucket)')
    .option('--output <path>', 'Output path in bucket (default: exports/{YYYY-MM-DD}-{projectId})')
    .option('--skip-storage', 'Skip storage file export')
    .option('--collections <list>', 'Comma-separated collection names (default: all collections)')
    .option('--dry-run', 'Show plan without writing')
    .parse();

  const options = program.opts();

  // Validate that exactly one destination is specified
  if (!options.bucket && !options.localOutput) {
    console.error('\n✗ Error: Must specify either --bucket or --local-output');
    console.error('\nExamples:');
    console.error('  node export-firebase.js --project my-project --bucket my-backup-bucket');
    console.error('  node export-firebase.js --project my-project --local-output ./backups/2025-01-15\n');
    process.exit(1);
  }

  if (options.bucket && options.localOutput) {
    console.error('\n✗ Error: Cannot use both --bucket and --local-output');
    console.error('Choose one export destination.\n');
    process.exit(1);
  }

  // Detect mode
  const isLocalMode = Boolean(options.localOutput);

  // Generate default output path if not provided (for GCS only)
  const defaultPath = `exports/${new Date().toISOString().split('T')[0]}-${options.project}`;
  const outputPath = isLocalMode ? options.localOutput : (options.output || defaultPath);

  // Handle dry-run mode
  if (options.dryRun) {
    console.log('\n=== DRY RUN MODE ===');
    console.log('Export Plan:');
    console.log(`  Project: ${options.project}`);
    console.log(`  Mode: ${isLocalMode ? 'Local Filesystem' : 'Google Cloud Storage'}`);
    console.log(`  Target: ${isLocalMode ? outputPath : `gs://${options.bucket}/${outputPath}`}`);
    console.log(`  Collections: ${options.collections || 'all'}`);
    console.log(`  Skip Storage: ${options.skipStorage ? 'yes' : 'no'}`);
    console.log('\nNo data will be exported in dry-run mode.');
    console.log('Remove --dry-run flag to perform actual export.\n');
    return;
  }

  const startTime = Date.now();

  console.log('\n=== Firebase Export Tool ===');
  console.log(`Project: ${options.project}`);
  console.log(`Mode: ${isLocalMode ? 'Local Filesystem' : 'Google Cloud Storage'}`);
  console.log(`Target: ${isLocalMode ? path.resolve(outputPath) : `gs://${options.bucket}/${outputPath}`}\n`);

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

    console.log(`✓ GCS Storage SDK initialized (source: ${sourceBucketName})\n`);

    // Initialize target bucket (only for GCS mode)
    let targetBucket = null;
    if (!isLocalMode) {
      targetBucket = storage.bucket(options.bucket);
    }

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
      if (isLocalMode) {
        storageResult = await copyStorageFilesLocal(sourceBucket, path.resolve(outputPath), 5);
        console.log(`✓ Downloaded ${storageResult.downloaded} files (${storageResult.totalBytes} bytes)\n`);
      } else {
        storageResult = await copyStorageFiles(sourceBucket, targetBucket, `${outputPath}/storage`, 5);
        console.log(`✓ Copied ${storageResult.copied} files (${storageResult.totalBytes} bytes)\n`);
      }
    } else {
      console.log('⊘ Skipping Storage export\n');
    }

    // Create manifest (using new manifest module format)
    console.log('Creating manifest...');

    // Convert collections data to array format for new manifest
    const collectionsArray = Object.entries(collectionsData).map(([name, data]) => ({
      name,
      count: data.count
    }));

    // Build storage files info if storage was exported
    const storageFilesInfo = storageResult ? {
      files: isLocalMode ? storageResult.downloaded : storageResult.copied,
      totalBytes: storageResult.totalBytes,
    } : null;

    // Create manifest using new format
    const exportManifest = manifest.createManifest({
      projectId: options.project,
      timestamp: new Date().toISOString(),
      collections: collectionsData,
      storageFiles: storageFilesInfo,
    });

    console.log('✓ Manifest created\n');

    // Write all data
    console.log(`Writing data to ${isLocalMode ? 'local filesystem' : 'GCS'}...`);

    // Write manifest
    if (isLocalMode) {
      const manifestPath = path.join(path.resolve(outputPath), 'manifest.json');
      await localClient.writeJSON(manifestPath, exportManifest);
    } else {
      await gcsClient.writeJSON(targetBucket, `${outputPath}/manifest.json`, exportManifest);
    }
    console.log(`  ✓ manifest.json`);

    // Write each collection
    for (const [collectionName, collectionData] of Object.entries(collectionsData)) {
      if (isLocalMode) {
        const collectionPath = path.join(path.resolve(outputPath), 'firestore', `${collectionName}.json`);
        await localClient.writeJSON(collectionPath, collectionData.docs);
      } else {
        await gcsClient.writeJSON(targetBucket, `${outputPath}/firestore/${collectionName}.json`, collectionData.docs);
      }
      console.log(`  ✓ firestore/${collectionName}.json (${collectionData.count} documents)`);
    }

    // Write storage summary (if storage was exported)
    if (storageResult) {
      if (isLocalMode) {
        const summaryPath = path.join(path.resolve(outputPath), 'storage', 'summary.json');
        await localClient.writeJSON(summaryPath, storageResult);
      } else {
        await gcsClient.writeJSON(targetBucket, `${outputPath}/storage/summary.json`, storageResult);
      }
      console.log(`  ✓ storage/summary.json`);
    }

    // Calculate elapsed time
    const elapsedSeconds = ((Date.now() - startTime) / 1000).toFixed(2);

    // Print summary
    console.log('\n=== Export Complete ===');
    console.log(`Location: ${isLocalMode ? path.resolve(outputPath) : `gs://${options.bucket}/${outputPath}`}`);
    console.log('\nCollections exported:');
    for (const [collectionName, collectionData] of Object.entries(collectionsData)) {
      console.log(`  - ${collectionName}: ${collectionData.count} documents`);
    }
    if (storageResult) {
      const fileCount = isLocalMode ? storageResult.downloaded : storageResult.copied;
      console.log(`\nStorage files: ${fileCount} files (${storageResult.totalBytes} bytes)`);
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
