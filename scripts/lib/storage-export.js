const pLimit = require('p-limit');
const fs = require('fs').promises;
const path = require('path');

/**
 * Lists all files in a storage bucket with optional prefix filter
 * @param {object} sourceBucket - GCS bucket instance (@google-cloud/storage)
 * @param {string} prefix - Optional prefix to filter files
 * @returns {Promise<Array>} Array of file metadata objects
 */
async function listStorageFiles(sourceBucket, prefix = '') {
  console.log(`Listing files in storage bucket${prefix ? ` with prefix: ${prefix}` : ''}...`);

  const options = {};
  if (prefix) {
    options.prefix = prefix;
  }

  const [files] = await sourceBucket.getFiles(options);

  console.log(`Found ${files.length} files in storage`);

  return files;
}

/**
 * Copies files from source bucket to target bucket with concurrency control
 * @param {object} sourceBucket - Source GCS bucket (@google-cloud/storage)
 * @param {object} targetBucket - Target GCS bucket (@google-cloud/storage)
 * @param {string} targetPrefix - Prefix to prepend to file paths in target bucket
 * @param {number} concurrency - Number of concurrent copy operations (default: 5)
 * @returns {Promise<object>} Stats object with files, totalBytes, copied, and errors
 */
async function copyStorageFiles(sourceBucket, targetBucket, targetPrefix, concurrency = 5) {
  console.log(`Starting storage copy with concurrency: ${concurrency}`);

  // List all files in source bucket
  const files = await listStorageFiles(sourceBucket);

  if (files.length === 0) {
    console.log('No files to copy');
    return { files: 0, totalBytes: 0, copied: 0, errors: [] };
  }

  // Initialize stats
  const stats = {
    files: files.length,
    totalBytes: 0,
    copied: 0,
    errors: []
  };

  // Create concurrency limiter
  const limit = pLimit(concurrency);

  // Create copy tasks for each file
  const copyTasks = files.map((file, index) => {
    return limit(async () => {
      try {
        const sourcePath = file.name;
        const targetPath = targetPrefix ? `${targetPrefix}/${sourcePath}` : sourcePath;

        // Get file metadata for size
        const [metadata] = await file.getMetadata();
        const fileSize = parseInt(metadata.size || 0);

        // Copy file using GCS copy (source and destination can be in different buckets)
        const destinationFile = targetBucket.file(targetPath);
        await file.copy(destinationFile);

        stats.totalBytes += fileSize;
        stats.copied++;

        // Log progress every 10 files
        if ((index + 1) % 10 === 0 || index + 1 === files.length) {
          console.log(`Copied ${stats.copied}/${files.length} files...`);
        }
      } catch (error) {
        console.error(`Error copying file ${file.name}:`, error.message);
        stats.errors.push({
          file: file.name,
          error: error.message
        });
      }
    });
  });

  // Execute all copy tasks
  await Promise.all(copyTasks);

  // Log summary
  console.log(`\nCopy complete: Copied ${stats.copied}/${stats.files} files, ${stats.errors.length} errors`);
  if (stats.errors.length > 0) {
    console.log('Files with errors:');
    stats.errors.forEach(({ file, error }) => {
      console.log(`  - ${file}: ${error}`);
    });
  }

  return stats;
}

/**
 * Downloads files from Firebase Storage to local filesystem
 * @param {object} sourceBucket - Source GCS bucket (@google-cloud/storage)
 * @param {string} localOutputDir - Local directory path to download files to
 * @param {number} concurrency - Number of concurrent download operations (default: 5)
 * @returns {Promise<object>} Stats object with files, totalBytes, downloaded, skipped, and errors
 */
async function copyStorageFilesLocal(sourceBucket, localOutputDir, concurrency = 5) {
  console.log(`Starting storage download to local filesystem with concurrency: ${concurrency}`);

  // List all files in source bucket
  const files = await listStorageFiles(sourceBucket);

  if (files.length === 0) {
    console.log('No files to download');
    return { files: 0, totalBytes: 0, downloaded: 0, skipped: 0, errors: [] };
  }

  // Create storage subdirectory
  const storageDir = path.join(localOutputDir, 'storage');
  await fs.mkdir(storageDir, { recursive: true });

  // Initialize stats
  const stats = {
    files: files.length,
    totalBytes: 0,
    downloaded: 0,
    skipped: 0,
    errors: []
  };

  // Create concurrency limiter
  const limit = pLimit(concurrency);

  // Create download tasks for each file
  const downloadTasks = files.map((file, index) => {
    return limit(async () => {
      try {
        const sourcePath = file.name;

        // Skip directory marker files (zero-byte files ending with '/')
        if (sourcePath.endsWith('/')) {
          console.log(`Skipping directory marker: ${sourcePath}`);
          stats.skipped++;
          return;
        }

        const destPath = path.join(storageDir, sourcePath);

        // Get file metadata for size
        const [metadata] = await file.getMetadata();
        const fileSize = parseInt(metadata.size || 0);

        // Create parent directory if needed (preserve structure)
        await fs.mkdir(path.dirname(destPath), { recursive: true });

        // Download file from Firebase Storage to local filesystem
        await file.download({ destination: destPath });

        stats.totalBytes += fileSize;
        stats.downloaded++;

        // Log progress every 10 files
        if ((index + 1) % 10 === 0 || index + 1 === files.length) {
          console.log(`Downloaded ${stats.downloaded}/${files.length} files...`);
        }
      } catch (error) {
        console.error(`Error downloading file ${file.name}:`, error.message);
        stats.errors.push({
          file: file.name,
          error: error.message
        });
      }
    });
  });

  // Execute all download tasks
  await Promise.all(downloadTasks);

  // Log summary
  console.log(`\nDownload complete: Downloaded ${stats.downloaded}/${stats.files} files, ${stats.skipped} skipped, ${stats.errors.length} errors`);
  if (stats.errors.length > 0) {
    console.log('Files with errors:');
    stats.errors.forEach(({ file, error }) => {
      console.log(`  - ${file}: ${error}`);
    });
  }

  return stats;
}

module.exports = { listStorageFiles, copyStorageFiles, copyStorageFilesLocal };
