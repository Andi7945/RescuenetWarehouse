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
 * @param {{files: number, totalBytes: number}|null} params.storageFiles - Storage summary stats or null
 * @returns {Object} Manifest object with version, metadata, and file references
 *
 * @example
 * const manifest = createManifest({
 *   projectId: 'my-project',
 *   timestamp: '2025-01-15T10:00:00Z',
 *   collections: [{ name: 'items', count: 100 }],
 *   storageFiles: { files: 5, totalBytes: 1048576 }
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
    storage: storageFiles ? {
      fileCount: storageFiles.files || 0,
      totalBytes: storageFiles.totalBytes || 0,
      path: 'storage/', // Relative path
    } : null,
  };
}

/**
 * Validates a manifest object structure.
 * Collects all validation errors and returns them in a result object.
 * This is a pure function - it only reads the input and returns validation results.
 *
 * @param {Object} manifest - Manifest object to validate
 * @returns {{valid: boolean, errors: string[]}} Validation result with errors array
 *
 * @example
 * const result = validateManifest(manifest);
 * if (result.valid) {
 *   console.log('Manifest is valid');
 * } else {
 *   console.error('Invalid manifest:');
 *   result.errors.forEach(err => console.error('  -', err));
 * }
 */
function validateManifest(manifest) {
  const errors = [];

  // Early return for null/undefined manifest
  if (!manifest) {
    return { valid: false, errors: ['Invalid manifest: manifest is null or undefined'] };
  }

  if (!manifest.version) {
    errors.push('Invalid manifest: missing "version" field');
  }

  if (typeof manifest.version !== 'string') {
    errors.push('Invalid manifest: "version" must be a string');
  }

  if (!manifest.projectId) {
    errors.push('Invalid manifest: missing "projectId" field');
  }

  if (typeof manifest.projectId !== 'string') {
    errors.push('Invalid manifest: "projectId" must be a string');
  }

  if (!manifest.exportedAt) {
    errors.push('Invalid manifest: missing "exportedAt" field');
  }

  if (typeof manifest.exportedAt !== 'string') {
    errors.push('Invalid manifest: "exportedAt" must be a string');
  }

  if (!Array.isArray(manifest.collections)) {
    errors.push('Invalid manifest: "collections" must be an array');
  }

  // Validate each collection entry (with defensive check)
  if (Array.isArray(manifest.collections)) {
    manifest.collections.forEach((collection, index) => {
      if (!collection.name) {
        errors.push(`Invalid manifest: collection at index ${index} missing "name" field`);
      }
      if (typeof collection.name !== 'string') {
        errors.push(`Invalid manifest: collection at index ${index} "name" must be a string`);
      }
      if (!collection.filePath) {
        errors.push(`Invalid manifest: collection at index ${index} missing "filePath" field`);
      }
      if (typeof collection.filePath !== 'string') {
        errors.push(`Invalid manifest: collection at index ${index} "filePath" must be a string`);
      }
    });
  }

  // Storage field is optional (can be null if no storage was exported)
  if (manifest.storage !== null && manifest.storage !== undefined) {
    if (typeof manifest.storage !== 'object') {
      errors.push('Invalid manifest: "storage" must be an object or null');
    }

    // Defensive check before accessing storage properties
    if (typeof manifest.storage === 'object' && manifest.storage !== null) {
      if (typeof manifest.storage.fileCount !== 'number') {
        errors.push('Invalid manifest: storage.fileCount must be a number');
      }

      if (!manifest.storage.path) {
        errors.push('Invalid manifest: storage.path is required');
      }

      if (typeof manifest.storage.path !== 'string') {
        errors.push('Invalid manifest: storage.path must be a string');
      }
    }
  }

  return { valid: errors.length === 0, errors };
}

/**
 * Normalizes collections from array format to object format.
 * Converts new manifest format to legacy format expected by import code.
 * This is a pure function with defensive checks for invalid inputs.
 *
 * @param {Array<{name: string, filePath: string, documentCount: number}>} collections - Array of collection objects
 * @returns {Object<string, {file: string, count: number}>} Object keyed by collection name
 *
 * @example
 * // New format (from manifest)
 * const collections = [
 *   { name: "items", filePath: "firestore/items.json", documentCount: 326 },
 *   { name: "containers", filePath: "firestore/containers.json", documentCount: 42 }
 * ];
 *
 * // Convert to legacy format
 * normalizeCollections(collections);
 * // => {
 * //   items: { file: "items.json", count: 326 },
 * //   containers: { file: "containers.json", count: 42 }
 * // }
 */
function normalizeCollections(collections) {
  // Defensive checks: return empty object for invalid inputs
  if (!collections || !Array.isArray(collections)) {
    return {};
  }

  return collections.reduce((acc, collection) => {
    // Skip entries missing required fields
    if (!collection.name || !collection.filePath) {
      return acc;
    }

    // Extract filename from path (e.g., "firestore/items.json" → "items.json")
    const filename = path.basename(collection.filePath);

    // Build legacy format: { [name]: { file: filename, count: documentCount } }
    acc[collection.name] = {
      file: filename,
      count: collection.documentCount || 0,
    };

    return acc;
  }, {});
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
  normalizeCollections,
  getManifestPath,
};
