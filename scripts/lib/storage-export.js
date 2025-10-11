const pLimit = require('p-limit');

/**
 * Lists all files in a storage bucket with optional prefix filter
 * @param {object} sourceBucket - Firebase storage bucket instance
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
 * @param {object} sourceBucket - Source Firebase storage bucket
 * @param {object} targetBucket - Target Firebase storage bucket
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

        // Copy file to target bucket
        await file.copy(targetBucket.file(targetPath));

        // Get file metadata for size
        const [metadata] = await file.getMetadata();
        const fileSize = parseInt(metadata.size || 0);

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

module.exports = { listStorageFiles, copyStorageFiles };
