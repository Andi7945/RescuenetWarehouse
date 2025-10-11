/**
 * Storage Bucket Domain Detector
 *
 * Detects which Firebase Storage bucket domain convention a project uses.
 * Firebase projects may use either .appspot.com (legacy) or .firebasestorage.app (modern).
 *
 * This module provides a pure detection function with clear error handling.
 */

/**
 * Detects which Firebase Storage bucket domain exists for a project
 *
 * Checks both modern (.firebasestorage.app) and legacy (.appspot.com) domains
 * to determine which bucket exists for the given project.
 *
 * @param {string} projectId - Firebase project ID
 * @param {Storage} storage - GCS Storage SDK instance
 * @returns {Promise<string>} Bucket name (e.g., "project-id.appspot.com")
 * @throws {Error} If both buckets exist (ambiguous) or neither exists
 *
 * @example
 * const storage = new Storage({ keyFilename: 'key.json' });
 * const bucketName = await detectStorageBucket('my-project', storage);
 * // Returns: "my-project.appspot.com" or "my-project.firebasestorage.app"
 */
async function detectStorageBucket(projectId, storage) {
  const modernBucket = `${projectId}.firebasestorage.app`;
  const legacyBucket = `${projectId}.appspot.com`;

  // Check both buckets in parallel for performance
  const [modernExists, legacyExists] = await Promise.all([
    checkBucketExists(storage, modernBucket),
    checkBucketExists(storage, legacyBucket)
  ]);

  // Case 1: Only modern exists
  if (modernExists && !legacyExists) {
    return modernBucket;
  }

  // Case 2: Only legacy exists
  if (legacyExists && !modernExists) {
    return legacyBucket;
  }

  // Case 3: Both exist - ambiguous configuration (likely a mistake)
  if (modernExists && legacyExists) {
    throw new Error(
      `Ambiguous storage configuration for project "${projectId}":\n` +
      `Both buckets exist:\n` +
      `  - ${modernBucket} (modern)\n` +
      `  - ${legacyBucket} (legacy)\n\n` +
      `This is likely a mistake. Please:\n` +
      `1. Determine which bucket contains your actual data\n` +
      `2. Delete the unused bucket, OR\n` +
      `3. Use --skip-storage flag to handle storage separately`
    );
  }

  // Case 4: Neither exists - storage not enabled or permissions issue
  throw new Error(
    `No Firebase Storage bucket found for project "${projectId}".\n` +
    `Checked:\n` +
    `  - ${modernBucket}\n` +
    `  - ${legacyBucket}\n\n` +
    `Either:\n` +
    `1. Firebase Storage is not enabled for this project, OR\n` +
    `2. The service account lacks permission to access the bucket\n\n` +
    `To skip storage: Use --skip-storage flag`
  );
}

/**
 * Checks if a GCS bucket exists
 *
 * Helper function that safely checks bucket existence without throwing.
 *
 * @param {Storage} storage - GCS Storage SDK instance
 * @param {string} bucketName - Bucket name to check
 * @returns {Promise<boolean>} True if bucket exists and is accessible
 */
async function checkBucketExists(storage, bucketName) {
  try {
    const [exists] = await storage.bucket(bucketName).exists();
    return exists;
  } catch (error) {
    // If we can't check (permission error, network error), assume doesn't exist
    // This is safe because we'll get a clearer error later if there's a real problem
    return false;
  }
}

module.exports = { detectStorageBucket };
