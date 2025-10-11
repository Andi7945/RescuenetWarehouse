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
 * @returns {Promise<{db: admin.firestore.Firestore, projectId: string}>}
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
  // Note: We don't specify storageBucket here because we use GCS Storage SDK
  // directly with auto-detection for better compatibility with legacy projects
  const app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  }, projectId); // Use projectId as app name for multiple connections

  // Get Firestore instance
  const db = app.firestore();

  return {
    db,
    projectId
  };
}

module.exports = { initFirebaseReadOnly, getServiceAccountPath };
