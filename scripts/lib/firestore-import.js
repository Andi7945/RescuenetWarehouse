const admin = require('firebase-admin');

/**
 * Validates the structure of an import manifest
 * @param {Object} manifest - The manifest object to validate
 * @returns {Object} Object with { valid: boolean, errors: Array<string> }
 */
function validateManifest(manifest) {
  const errors = [];

  if (!manifest) {
    errors.push('Manifest is null or undefined');
    return { valid: false, errors };
  }

  if (!manifest.version) {
    errors.push('Missing required field: version');
  }

  if (!manifest.timestamp) {
    errors.push('Missing required field: timestamp');
  }

  if (!manifest.sourceProject) {
    errors.push('Missing required field: sourceProject');
  }

  if (!manifest.collections) {
    errors.push('Missing required field: collections');
  } else if (typeof manifest.collections !== 'object') {
    errors.push('Field "collections" must be an object');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

/**
 * Recursively converts ISO date strings back to Firestore Timestamps
 * @param {*} value - Any value that may contain ISO date strings
 * @returns {*} The value with all ISO strings converted to Timestamps
 */
function restoreTimestamps(value) {
  // Handle null/undefined
  if (value === null || value === undefined) {
    return value;
  }

  // Check if it's a string that looks like an ISO date
  if (typeof value === 'string') {
    // ISO 8601 format regex (basic check)
    const isoDateRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$/;
    if (isoDateRegex.test(value)) {
      try {
        const date = new Date(value);
        // Check if it's a valid date
        if (!isNaN(date.getTime())) {
          return admin.firestore.Timestamp.fromDate(date);
        }
      } catch (error) {
        // Not a valid date, return as-is
        return value;
      }
    }
    return value;
  }

  // Recursively handle arrays
  if (Array.isArray(value)) {
    return value.map(item => restoreTimestamps(item));
  }

  // Recursively handle objects
  if (typeof value === 'object') {
    const restored = {};
    for (const [key, val] of Object.entries(value)) {
      restored[key] = restoreTimestamps(val);
    }
    return restored;
  }

  // Return primitive values as-is
  return value;
}

/**
 * Deletes all documents from a collection in batches
 * @param {Firestore} db - Firestore database instance
 * @param {string} collectionName - Name of the collection to clear
 * @param {number} batchSize - Maximum documents per batch (default 500)
 * @returns {Promise<number>} Number of deleted documents
 */
async function clearCollection(db, collectionName, batchSize = 500) {
  const collectionRef = db.collection(collectionName);
  let totalDeleted = 0;

  console.log(`Clearing collection: ${collectionName}`);

  while (true) {
    // Query a batch of documents
    const snapshot = await collectionRef.limit(batchSize).get();

    if (snapshot.empty) {
      break;
    }

    // Create a batch for deletion
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    totalDeleted += snapshot.size;

    console.log(`  Deleted ${totalDeleted} documents from ${collectionName}...`);
  }

  console.log(`Cleared ${collectionName}: ${totalDeleted} documents deleted`);
  return totalDeleted;
}

/**
 * Imports documents into a collection using batched writes
 * @param {Firestore} db - Firestore database instance
 * @param {string} collectionName - Name of the collection to import into
 * @param {Array} docs - Array of document objects with id field
 * @param {number} batchSize - Maximum operations per batch (default 500)
 * @returns {Promise<Object>} Object with { imported: number, errors: Array }
 */
async function importCollection(db, collectionName, docs, batchSize = 500) {
  const collectionRef = db.collection(collectionName);
  const errors = [];
  let imported = 0;

  console.log(`Importing ${collectionName}: ${docs.length} documents`);

  // Process in batches
  for (let i = 0; i < docs.length; i += batchSize) {
    const batch = db.batch();
    const batchDocs = docs.slice(i, i + batchSize);

    for (const doc of batchDocs) {
      try {
        const { id, ...data } = doc;

        if (!id) {
          errors.push({
            collection: collectionName,
            error: 'Document missing id field',
            doc
          });
          continue;
        }

        // Restore timestamps in the data
        const restoredData = restoreTimestamps(data);

        const docRef = collectionRef.doc(id);
        batch.set(docRef, restoredData);
      } catch (error) {
        errors.push({
          collection: collectionName,
          docId: doc.id,
          error: error.message
        });
      }
    }

    try {
      await batch.commit();
      imported += batchDocs.length - batchDocs.filter(d => !d.id).length;
      console.log(`  Imported ${imported}/${docs.length} documents...`);
    } catch (error) {
      errors.push({
        collection: collectionName,
        error: `Batch commit failed: ${error.message}`,
        batchIndex: Math.floor(i / batchSize)
      });
    }
  }

  console.log(`Imported ${collectionName}: ${imported} documents, ${errors.length} errors`);

  return {
    imported,
    errors
  };
}

/**
 * Imports all collections from export data
 * @param {Firestore} db - Firestore database instance
 * @param {Object} collectionsData - Object keyed by collection name with docs arrays
 * @param {boolean} clearFirst - Whether to clear collections before import (default true)
 * @returns {Promise<Object>} Object keyed by collection name with import results
 */
async function importAllCollections(db, collectionsData, clearFirst = true) {
  const results = {};

  for (const [collectionName, data] of Object.entries(collectionsData)) {
    try {
      const collectionResult = {
        deleted: 0,
        imported: 0,
        errors: []
      };

      // Clear collection first if requested
      if (clearFirst) {
        try {
          collectionResult.deleted = await clearCollection(db, collectionName);
        } catch (error) {
          console.error(`Error clearing ${collectionName}:`, error.message);
          collectionResult.errors.push({
            phase: 'clear',
            error: error.message
          });
          // Continue with import even if clear fails
        }
      }

      // Import documents
      if (data.docs && Array.isArray(data.docs)) {
        const importResult = await importCollection(db, collectionName, data.docs);
        collectionResult.imported = importResult.imported;
        collectionResult.errors.push(...importResult.errors);
      } else {
        console.warn(`No docs array found for collection ${collectionName}, skipping import`);
      }

      results[collectionName] = collectionResult;
    } catch (error) {
      console.error(`Error importing collection ${collectionName}:`, error.message);
      results[collectionName] = {
        deleted: 0,
        imported: 0,
        errors: [{
          phase: 'import',
          error: error.message
        }]
      };
      // Continue with remaining collections
    }
  }

  return results;
}

module.exports = {
  validateManifest,
  restoreTimestamps,
  clearCollection,
  importCollection,
  importAllCollections
};
