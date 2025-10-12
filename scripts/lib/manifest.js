/**
 * @fileoverview Pure functions for manifest creation, validation, and path management.
 * This module handles metadata about Firebase exports without any side effects.
 */

const path = require('path');

/**
 * Creates a manifest object describing an export.
 * This is a pure function with no side effects.
 *
 * @param {Object} params - Parameters for manifest creation
 * @param {string} params.projectId - Firebase project ID
 * @param {string} params.timestamp - ISO 8601 timestamp of export
 * @param {Array<{name: string, count: number}>} params.collections - Collection metadata
 * @param {Array<{name: string, size?: number}>} params.storageFiles - Storage file metadata
 * @returns {Object} Manifest object with version, metadata, and file references
 *
 * @example
 * const manifest = createManifest({
 *   projectId: 'my-project',
 *   timestamp: '2025-01-15T10:00:00Z',
 *   collections: [{ name: 'items', count: 100 }],
 *   storageFiles: [{ name: 'image.jpg', size: 1024 }]
 * });
 */
function createManifest({ projectId, timestamp, collections, storageFiles }) {
  return {
    version: '1.0',
    exportedAt: timestamp,
    projectId,
    collections: collections.map(c => ({
      name: c.name,
      documentCount: c.count,
      filePath: `firestore/${c.name}.json`, // Relative path
    })),
    storage: {
      fileCount: storageFiles.length,
      path: 'storage/', // Relative path
      files: storageFiles.map(f => ({
        name: f.name,
        size: f.size || 0,
      })),
    },
  };
}

/**
 * Validates a manifest object structure.
 * Throws descriptive errors if the manifest is invalid.
 * This is a pure function - it only reads the input and throws on invalid data.
 *
 * @param {Object} manifest - Manifest object to validate
 * @throws {Error} If manifest is missing required fields or has invalid structure
 * @returns {boolean} True if validation passes
 *
 * @example
 * try {
 *   validateManifest(manifest);
 *   console.log('Manifest is valid');
 * } catch (error) {
 *   console.error('Invalid manifest:', error.message);
 * }
 */
function validateManifest(manifest) {
  if (!manifest) {
    throw new Error('Invalid manifest: manifest is null or undefined');
  }

  if (!manifest.version) {
    throw new Error('Invalid manifest: missing "version" field');
  }

  if (typeof manifest.version !== 'string') {
    throw new Error('Invalid manifest: "version" must be a string');
  }

  if (!manifest.projectId) {
    throw new Error('Invalid manifest: missing "projectId" field');
  }

  if (typeof manifest.projectId !== 'string') {
    throw new Error('Invalid manifest: "projectId" must be a string');
  }

  if (!manifest.exportedAt) {
    throw new Error('Invalid manifest: missing "exportedAt" field');
  }

  if (typeof manifest.exportedAt !== 'string') {
    throw new Error('Invalid manifest: "exportedAt" must be a string');
  }

  if (!Array.isArray(manifest.collections)) {
    throw new Error('Invalid manifest: "collections" must be an array');
  }

  // Validate each collection entry
  manifest.collections.forEach((collection, index) => {
    if (!collection.name) {
      throw new Error(`Invalid manifest: collection at index ${index} missing "name" field`);
    }
    if (typeof collection.name !== 'string') {
      throw new Error(`Invalid manifest: collection at index ${index} "name" must be a string`);
    }
    if (!collection.filePath) {
      throw new Error(`Invalid manifest: collection at index ${index} missing "filePath" field`);
    }
    if (typeof collection.filePath !== 'string') {
      throw new Error(`Invalid manifest: collection at index ${index} "filePath" must be a string`);
    }
  });

  if (!manifest.storage) {
    throw new Error('Invalid manifest: missing "storage" field');
  }

  if (typeof manifest.storage !== 'object') {
    throw new Error('Invalid manifest: "storage" must be an object');
  }

  if (typeof manifest.storage.fileCount !== 'number') {
    throw new Error('Invalid manifest: storage.fileCount must be a number');
  }

  if (!manifest.storage.path) {
    throw new Error('Invalid manifest: storage.path is required');
  }

  if (typeof manifest.storage.path !== 'string') {
    throw new Error('Invalid manifest: storage.path must be a string');
  }

  return true;
}

/**
 * Returns the appropriate manifest file path based on storage mode.
 * This is a pure function - no side effects, deterministic output.
 *
 * @param {string} basePath - Base path for the export (local directory or GCS prefix)
 * @param {'local'|'gcs'} mode - Storage mode
 * @returns {string} Full path to manifest file
 *
 * @example
 * // Local mode
 * getManifestPath('/backups/2025-01-15', 'local')
 * // => '/backups/2025-01-15/manifest.json'
 *
 * // GCS mode (returns blob path, not filesystem path)
 * getManifestPath('exports/2025-01-15', 'gcs')
 * // => 'exports/2025-01-15/manifest.json'
 */
function getManifestPath(basePath, mode) {
  if (mode === 'local') {
    return path.join(basePath, 'manifest.json');
  } else if (mode === 'gcs') {
    // GCS blob paths use forward slashes, no path.join needed
    const normalized = basePath.endsWith('/') ? basePath : `${basePath}/`;
    return `${normalized}manifest.json`;
  } else {
    throw new Error(`Invalid mode: "${mode}". Must be "local" or "gcs"`);
  }
}

module.exports = {
  createManifest,
  validateManifest,
  getManifestPath,
};
