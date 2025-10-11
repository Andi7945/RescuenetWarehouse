/**
 * GCS Client Utilities
 *
 * Simple wrapper functions for Google Cloud Storage operations.
 * Used by the Firebase data export tool.
 */

/**
 * Writes JSON data to a file in the GCS bucket
 *
 * @param {object} bucket - GCS Bucket object from Firebase Storage
 * @param {string} path - File path within the bucket
 * @param {object} data - Data to serialize as JSON
 * @returns {Promise<string>} GCS URI in format: gs://{bucketName}/{path}
 */
async function writeJSON(bucket, path, data) {
  const file = bucket.file(path);
  const jsonString = JSON.stringify(data, null, 2);

  await file.save(jsonString, {
    contentType: 'application/json',
  });

  return getGcsUri(bucket, path);
}

/**
 * Reads and parses JSON data from a file in the GCS bucket
 *
 * @param {object} bucket - GCS Bucket object from Firebase Storage
 * @param {string} path - File path within the bucket
 * @returns {Promise<object>} Parsed JSON object
 * @throws {Error} If file doesn't exist or contains invalid JSON
 */
async function readJSON(bucket, path) {
  const file = bucket.file(path);
  const [fileExists] = await file.exists();

  if (!fileExists) {
    throw new Error(`File not found: ${getGcsUri(bucket, path)}`);
  }

  const [contents] = await file.download();
  const jsonString = contents.toString('utf-8');

  try {
    return JSON.parse(jsonString);
  } catch (error) {
    throw new Error(`Invalid JSON in file ${getGcsUri(bucket, path)}: ${error.message}`);
  }
}

/**
 * Checks if a file exists at the given path in the bucket
 *
 * @param {object} bucket - GCS Bucket object from Firebase Storage
 * @param {string} path - File path within the bucket
 * @returns {Promise<boolean>} True if file exists, false otherwise
 */
async function exists(bucket, path) {
  const file = bucket.file(path);
  const [fileExists] = await file.exists();
  return fileExists;
}

/**
 * Formats and returns GCS URI for a given bucket and path
 *
 * @param {object} bucket - GCS Bucket object from Firebase Storage
 * @param {string} path - File path within the bucket
 * @returns {string} GCS URI in format: gs://{bucketName}/{path}
 */
function getGcsUri(bucket, path) {
  return `gs://${bucket.name}/${path}`;
}

/**
 * Parses a GCS URI into its bucket and path components
 *
 * @param {string} uri - GCS URI in format: gs://bucket/path
 * @returns {{bucketName: string, path: string}} Object with bucketName and path
 * @throws {Error} If URI format is invalid
 */
function parseGcsUri(uri) {
  if (typeof uri !== 'string') {
    throw new Error('GCS URI must be a string');
  }

  if (!uri.startsWith('gs://')) {
    throw new Error(`Invalid GCS URI format: ${uri}. Must start with gs://`);
  }

  const withoutProtocol = uri.slice(5); // Remove 'gs://'
  const firstSlashIndex = withoutProtocol.indexOf('/');

  if (firstSlashIndex === -1) {
    throw new Error(`Invalid GCS URI format: ${uri}. Must include path after bucket name`);
  }

  const bucketName = withoutProtocol.slice(0, firstSlashIndex);
  const path = withoutProtocol.slice(firstSlashIndex + 1);

  if (!bucketName) {
    throw new Error(`Invalid GCS URI format: ${uri}. Bucket name cannot be empty`);
  }

  if (!path) {
    throw new Error(`Invalid GCS URI format: ${uri}. Path cannot be empty`);
  }

  return { bucketName, path };
}

module.exports = { writeJSON, readJSON, exists, getGcsUri, parseGcsUri };
