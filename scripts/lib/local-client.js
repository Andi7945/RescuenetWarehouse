/**
 * Local Filesystem Client Utilities
 *
 * Simple wrapper functions for local filesystem operations.
 * Used by the Firebase data export/import tools as an alternative to GCS.
 */

const fs = require('fs').promises;
const path = require('path');

/**
 * Writes JSON data to a local file
 * Creates parent directories if they don't exist
 *
 * @param {string} filePath - Absolute path to the file
 * @param {object} data - Data to serialize as JSON
 * @returns {Promise<void>}
 * @throws {Error} If permission denied, disk full, or other I/O error
 */
async function writeJSON(filePath, data) {
  try {
    // Ensure parent directory exists
    const dir = path.dirname(filePath);
    await fs.mkdir(dir, { recursive: true });

    // Write JSON with pretty formatting
    const jsonString = JSON.stringify(data, null, 2);
    await fs.writeFile(filePath, jsonString, 'utf8');
  } catch (error) {
    if (error.code === 'EACCES') {
      throw new Error(
        `Permission denied writing to: ${filePath}\n` +
        `Check directory permissions and try again.`
      );
    }
    if (error.code === 'ENOSPC') {
      throw new Error(
        `Disk space full! Cannot write to: ${filePath}\n` +
        `Free up space or use a different directory.`
      );
    }
    throw new Error(`Failed to write JSON to ${filePath}: ${error.message}`);
  }
}

/**
 * Reads and parses JSON data from a local file
 *
 * @param {string} filePath - Absolute path to the file
 * @returns {Promise<object>} Parsed JSON object
 * @throws {Error} If file doesn't exist, permission denied, or contains invalid JSON
 */
async function readJSON(filePath) {
  try {
    const content = await fs.readFile(filePath, 'utf8');

    try {
      return JSON.parse(content);
    } catch (parseError) {
      throw new Error(`Invalid JSON in file ${filePath}: ${parseError.message}`);
    }
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`File not found: ${filePath}`);
    }
    if (error.code === 'EACCES') {
      throw new Error(
        `Permission denied reading from: ${filePath}\n` +
        `Check file permissions and try again.`
      );
    }
    // Re-throw JSON parse errors
    if (error.message.startsWith('Invalid JSON')) {
      throw error;
    }
    throw new Error(`Failed to read JSON from ${filePath}: ${error.message}`);
  }
}

/**
 * Copies a file from source to destination
 * Creates parent directories if they don't exist
 *
 * @param {string} srcPath - Absolute path to the source file
 * @param {string} destPath - Absolute path to the destination file
 * @returns {Promise<void>}
 * @throws {Error} If source doesn't exist, permission denied, or other I/O error
 */
async function copyFile(srcPath, destPath) {
  try {
    // Ensure destination parent directory exists
    const destDir = path.dirname(destPath);
    await fs.mkdir(destDir, { recursive: true });

    // Copy the file
    await fs.copyFile(srcPath, destPath);
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`Source file not found: ${srcPath}`);
    }
    if (error.code === 'EACCES') {
      throw new Error(
        `Permission denied copying file.\n` +
        `Source: ${srcPath}\n` +
        `Destination: ${destPath}\n` +
        `Check permissions and try again.`
      );
    }
    if (error.code === 'ENOSPC') {
      throw new Error(
        `Disk space full! Cannot copy to: ${destPath}\n` +
        `Free up space or use a different directory.`
      );
    }
    throw new Error(`Failed to copy file from ${srcPath} to ${destPath}: ${error.message}`);
  }
}

/**
 * Checks if a file exists at the given path
 *
 * @param {string} filePath - Absolute path to check
 * @returns {Promise<boolean>} True if file exists, false otherwise
 */
async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

/**
 * Recursively gets all files in a directory
 * Returns absolute paths to all files (not directories)
 *
 * @param {string} dir - Absolute path to the directory
 * @returns {Promise<string[]>} Array of absolute file paths
 * @throws {Error} If directory doesn't exist or permission denied
 */
async function getAllFilesRecursive(dir) {
  try {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    const files = [];

    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);

      if (entry.isDirectory()) {
        // Recursively get files from subdirectory
        const subFiles = await getAllFilesRecursive(fullPath);
        files.push(...subFiles);
      } else if (entry.isFile()) {
        files.push(fullPath);
      }
      // Skip symbolic links, sockets, etc.
    }

    return files;
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`Directory not found: ${dir}`);
    }
    if (error.code === 'EACCES') {
      throw new Error(
        `Permission denied reading directory: ${dir}\n` +
        `Check permissions and try again.`
      );
    }
    throw new Error(`Failed to read directory ${dir}: ${error.message}`);
  }
}

module.exports = {
  writeJSON,
  readJSON,
  copyFile,
  fileExists,
  getAllFilesRecursive,
};
