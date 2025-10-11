const COLLECTIONS = [
  'containers',
  'items',
  'work_log',
  'current_locations',
  'module_destinations',
  'container_types',
  'assignments'
];

/**
 * Recursively converts Firestore Timestamp objects to ISO date strings
 * @param {*} value - Any value that may contain Timestamps
 * @returns {*} The value with all Timestamps converted to ISO strings
 */
function convertTimestamps(value) {
  // Handle null/undefined
  if (value === null || value === undefined) {
    return value;
  }

  // Check if Firestore Timestamp (has toDate method)
  if (value && typeof value.toDate === 'function') {
    return value.toDate().toISOString();
  }

  // Recursively handle arrays
  if (Array.isArray(value)) {
    return value.map(item => convertTimestamps(item));
  }

  // Recursively handle objects
  if (typeof value === 'object') {
    const converted = {};
    for (const [key, val] of Object.entries(value)) {
      converted[key] = convertTimestamps(val);
    }
    return converted;
  }

  // Return primitive values as-is
  return value;
}

/**
 * Converts a Firestore DocumentSnapshot to a plain JavaScript object
 * @param {DocumentSnapshot} doc - Firestore document snapshot
 * @returns {Object} Plain object with id and converted data
 */
function docToPlainObject(doc) {
  const data = doc.data();
  const converted = convertTimestamps(data);

  return {
    id: doc.id,
    ...converted
  };
}

/**
 * Exports all documents from a single Firestore collection
 * @param {Firestore} db - Firestore database instance
 * @param {string} collectionName - Name of the collection to export
 * @returns {Promise<Object>} Object with docs array and count
 */
async function exportCollection(db, collectionName) {
  const snapshot = await db.collection(collectionName).get();
  const docs = snapshot.docs.map(doc => docToPlainObject(doc));

  console.log(`Exporting ${collectionName}: ${docs.length} documents`);

  return {
    docs: docs,
    count: docs.length
  };
}

/**
 * Exports all specified collections from Firestore
 * @param {Firestore} db - Firestore database instance
 * @param {string[]} collectionNames - Array of collection names to export
 * @returns {Promise<Object>} Object keyed by collection name with export data
 */
async function exportAllCollections(db, collectionNames = COLLECTIONS) {
  const result = {};

  for (const collectionName of collectionNames) {
    try {
      result[collectionName] = await exportCollection(db, collectionName);
    } catch (error) {
      console.error(`Error exporting collection ${collectionName}:`, error.message);
      // Continue with remaining collections
      result[collectionName] = {
        docs: [],
        count: 0,
        error: error.message
      };
    }
  }

  return result;
}

/**
 * Creates a manifest object with metadata about the export
 * @param {Object} exportData - The exported collection data
 * @param {string} sourceProject - The source Firebase project ID
 * @returns {Object} Manifest object with metadata
 */
function createManifest(exportData, sourceProject) {
  const collections = {};

  for (const [collectionName, data] of Object.entries(exportData)) {
    collections[collectionName] = data.count;
  }

  return {
    version: "1.0",
    timestamp: new Date().toISOString(),
    sourceProject: sourceProject,
    collections: collections
  };
}

module.exports = {
  COLLECTIONS,
  convertTimestamps,
  docToPlainObject,
  exportCollection,
  exportAllCollections,
  createManifest
};
