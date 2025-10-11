const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

/**
 * Maps project IDs to their service account file paths
 * @param {string} projectId - Firebase project ID
 * @returns {string} Path to service account JSON file
 * @throws {Error} If project ID is unknown
 */
function getServiceAccountPath(projectId) {
  const serviceAccountMap = {
    'rescuenet-7733b': 'secrets/rescuenet-production.json',
    'rescuenet-testing': 'secrets/rescuenet-testing.json'
  };

  const serviceAccountPath = serviceAccountMap[projectId];

  if (!serviceAccountPath) {
    throw new Error(
      `Unknown project ID: ${projectId}. ` +
      `Valid project IDs are: ${Object.keys(serviceAccountMap).join(', ')}`
    );
  }

  return serviceAccountPath;
}

/**
 * Initializes Firebase Admin SDK in read-only mode
 * @param {string} projectId - Firebase project ID
 * @returns {Promise<{db: admin.firestore.Firestore, storageBucket: admin.storage.Storage, projectId: string}>}
 * @throws {Error} If service account file doesn't exist or initialization fails
 */
async function initFirebaseReadOnly(projectId) {
  // Get service account path for this project
  const serviceAccountPath = getServiceAccountPath(projectId);
  const absolutePath = path.resolve(serviceAccountPath);

  // Check if service account file exists
  if (!fs.existsSync(absolutePath)) {
    throw new Error(
      `Service account file not found: ${absolutePath}\n` +
      `Please ensure the service account key exists at this location.`
    );
  }

  // Read and parse service account
  const serviceAccount = require(path.resolve(serviceAccountPath));

  // Initialize Firebase Admin SDK with named app
  const app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: `${projectId}.appspot.com`
  }, projectId); // Use projectId as app name for multiple connections

  // Get Firestore and Storage instances
  const db = app.firestore();
  const storageBucket = app.storage().bucket();

  return {
    db,
    storageBucket,
    projectId
  };
}

module.exports = { initFirebaseReadOnly, getServiceAccountPath };
