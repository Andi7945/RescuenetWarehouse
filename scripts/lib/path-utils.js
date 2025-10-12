const path = require('path');

/**
 * Pure functions for path manipulation
 * These functions have no side effects and are deterministic
 */

/**
 * Normalizes a local path to absolute
 * @param {string} inputPath - Path to normalize
 * @returns {string} Absolute path
 */
function normalizeLocalPath(inputPath) {
  return path.resolve(inputPath);
}

/**
 * Gets the file path for a collection
 * @param {string} basePath - Base directory or GCS prefix
 * @param {string} collectionName - Name of the collection
 * @param {string} mode - Either 'local' or 'gcs'
 * @returns {string} File path
 */
function getCollectionFilePath(basePath, collectionName, mode) {
  const relativePath = `firestore/${collectionName}.json`;
  return mode === 'local'
    ? path.join(basePath, relativePath)
    : relativePath;
}

/**
 * Gets the storage directory path
 * @param {string} basePath - Base directory or GCS prefix
 * @param {string} mode - Either 'local' or 'gcs'
 * @returns {string} Storage directory path
 */
function getStorageDirectory(basePath, mode) {
  return mode === 'local'
    ? path.join(basePath, 'storage')
    : 'storage/';
}

/**
 * Gets the manifest file path
 * @param {string} basePath - Base directory or GCS prefix
 * @param {string} mode - Either 'local' or 'gcs'
 * @returns {string} Manifest file path
 */
function getManifestPath(basePath, mode) {
  return mode === 'local'
    ? path.join(basePath, 'manifest.json')
    : 'manifest.json';
}

module.exports = {
  normalizeLocalPath,
  getCollectionFilePath,
  getStorageDirectory,
  getManifestPath
};
