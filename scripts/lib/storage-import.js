/**
 * Storage Import Utilities
 *
 * Imports storage files from GCS export to Firebase Storage.
 * Used by the Firebase data import tool.
 */

const pLimit = require('p-limit');
const path = require('path');
const { getAllFilesRecursive } = require('./local-client');

/**
 * Strips export prefix from storage path
 *
 * Pure function that removes the export timestamp prefix from a storage path.
 * Example: 'exports/2025-10-10/storage/items/123/image.jpg' → 'items/123/image.jpg'
 *
 * @param {string} exportPath - Full path in export bucket including prefix
 * @param {string} exportPrefix - Export prefix to strip (e.g., 'exports/2025-10-10/storage/')
 * @returns {string} Clean storage path without export prefix
 */
function stripExportPrefix(exportPath, exportPrefix) {
  if (!exportPath.startsWith(exportPrefix)) {
    // If path doesn't have expected prefix, return as-is
    return exportPath;
  }
  return exportPath.substring(exportPrefix.length);
}

/**
 * Restores storage files from GCS export to Firebase Storage
 *
 * Copies all files from a GCS export to a target Firebase Storage bucket,
 * preserving original paths by stripping the export prefix.
 *
 * @param {object} sourceBucket - GCS Bucket object containing the export
 * @param {string} sourcePrefix - Export prefix (e.g., 'exports/2025-10-10/storage/')
 * @param {object} targetBucket - Firebase Storage Bucket object to restore files to
 * @param {number} concurrency - Number of concurrent copy operations (default: 5)
 * @returns {Promise<object>} Stats object { copied: number, skipped: number, errors: Array }
 */
async function restoreStorageFiles(sourceBucket, sourcePrefix, targetBucket, concurrency = 5) {
  console.log(`\nRestoring storage files from ${sourcePrefix}...`);
  console.log(`Concurrency: ${concurrency}`);

  // Ensure sourcePrefix ends with '/' for proper prefix matching
  const normalizedPrefix = sourcePrefix.endsWith('/') ? sourcePrefix : `${sourcePrefix}/`;

  // List all files with the export prefix
  const [files] = await sourceBucket.getFiles({ prefix: normalizedPrefix });

  if (files.length === 0) {
    console.log('No storage files found to restore');
    return { copied: 0, skipped: 0, errors: [] };
  }

  console.log(`Found ${files.length} files to restore`);

  // Initialize stats
  const stats = {
    copied: 0,
    skipped: 0,
    errors: []
  };

  // Create concurrency limiter
  const limit = pLimit(concurrency);

  // Create copy tasks for each file
  const copyTasks = files.map((file, index) => {
    return limit(async () => {
      try {
        const sourcePath = file.name;

        // Strip export prefix to get original storage path
        const targetPath = stripExportPrefix(sourcePath, normalizedPrefix);

        // Skip if path is same as source (shouldn't happen, but safeguard)
        if (targetPath === sourcePath) {
          console.warn(`Skipping file with unexpected path: ${sourcePath}`);
          stats.skipped++;
          return;
        }

        // Copy file to target bucket with original path
        await file.copy(targetBucket.file(targetPath));
        stats.copied++;

        // Log progress every 10 files
        if ((index + 1) % 10 === 0 || index + 1 === files.length) {
          console.log(`Progress: ${stats.copied} copied, ${stats.skipped} skipped, ${stats.errors.length} errors (${index + 1}/${files.length} processed)`);
        }
      } catch (error) {
        console.error(`Error copying file ${file.name}:`, error.message);
        stats.errors.push({
          file: file.name,
          error: error.message
        });

        // Log progress on errors too
        if ((index + 1) % 10 === 0 || index + 1 === files.length) {
          console.log(`Progress: ${stats.copied} copied, ${stats.skipped} skipped, ${stats.errors.length} errors (${index + 1}/${files.length} processed)`);
        }
      }
    });
  });

  // Execute all copy tasks
  await Promise.all(copyTasks);

  // Log final summary
  console.log(`\n✓ Storage restore complete:`);
  console.log(`  Copied: ${stats.copied}`);
  console.log(`  Skipped: ${stats.skipped}`);
  console.log(`  Errors: ${stats.errors.length}`);

  if (stats.errors.length > 0) {
    console.log('\nFiles with errors:');
    stats.errors.forEach(({ file, error }) => {
      console.log(`  - ${file}: ${error}`);
    });
  }

  return stats;
}

/**
 * Restores storage files from local filesystem to Firebase Storage
 *
 * Uploads all files from a local directory to Firebase Storage,
 * preserving the relative path structure.
 *
 * @param {string} localStorageDir - Local directory containing storage files
 * @param {object} targetBucket - Firebase Storage Bucket object to restore files to
 * @param {number} concurrency - Number of concurrent upload operations (default: 5)
 * @returns {Promise<object>} Stats object { copied: number, skipped: number, errors: Array }
 */
async function restoreStorageFilesLocal(localStorageDir, targetBucket, concurrency = 5) {
  console.log(`\nRestoring storage files from local filesystem: ${localStorageDir}...`);
  console.log(`Concurrency: ${concurrency}`);

  // Check if directory exists
  const fs = require('fs').promises;
  try {
    await fs.access(localStorageDir);
  } catch (error) {
    console.warn(`Storage directory not found: ${localStorageDir}, skipping...`);
    return { copied: 0, skipped: 0, errors: [] };
  }

  // Get all files recursively
  let files;
  try {
    files = await getAllFilesRecursive(localStorageDir);
  } catch (error) {
    console.error(`Failed to read storage directory: ${error.message}`);
    return { copied: 0, skipped: 0, errors: [{ file: localStorageDir, error: error.message }] };
  }

  if (files.length === 0) {
    console.log('No storage files found to restore');
    return { copied: 0, skipped: 0, errors: [] };
  }

  console.log(`Found ${files.length} files to restore`);

  // Initialize stats
  const stats = {
    copied: 0,
    skipped: 0,
    errors: []
  };

  // Create concurrency limiter
  const limit = pLimit(concurrency);

  // Create upload tasks for each file
  const uploadTasks = files.map((localFilePath, index) => {
    return limit(async () => {
      try {
        // Get relative path from storage directory (this becomes the Firebase Storage path)
        const relativePath = path.relative(localStorageDir, localFilePath);

        // Upload to Firebase Storage
        await targetBucket.upload(localFilePath, {
          destination: relativePath,
        });

        stats.copied++;

        // Log progress every 10 files
        if ((index + 1) % 10 === 0 || index + 1 === files.length) {
          console.log(`Progress: ${stats.copied} uploaded, ${stats.skipped} skipped, ${stats.errors.length} errors (${index + 1}/${files.length} processed)`);
        }
      } catch (error) {
        console.error(`Error uploading file ${localFilePath}:`, error.message);
        stats.errors.push({
          file: localFilePath,
          error: error.message
        });

        // Log progress on errors too
        if ((index + 1) % 10 === 0 || index + 1 === files.length) {
          console.log(`Progress: ${stats.copied} uploaded, ${stats.skipped} skipped, ${stats.errors.length} errors (${index + 1}/${files.length} processed)`);
        }
      }
    });
  });

  // Execute all upload tasks
  await Promise.all(uploadTasks);

  // Log final summary
  console.log(`\n✓ Storage restore complete:`);
  console.log(`  Uploaded: ${stats.copied}`);
  console.log(`  Skipped: ${stats.skipped}`);
  console.log(`  Errors: ${stats.errors.length}`);

  if (stats.errors.length > 0) {
    console.log('\nFiles with errors:');
    stats.errors.forEach(({ file, error }) => {
      console.log(`  - ${file}: ${error}`);
    });
  }

  return stats;
}

module.exports = { restoreStorageFiles, restoreStorageFilesLocal, stripExportPrefix };
