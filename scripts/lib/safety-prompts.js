const prompts = require('prompts');
const chalk = require('chalk');

/**
 * Determines if a project ID is a production project.
 * Returns true for projects containing 'rescuenet-7733b', '-prod', or 'production'.
 *
 * @param {string} projectId - Firebase project ID
 * @returns {boolean} True if production project
 */
function isProductionProject(projectId) {
  if (!projectId) return false;
  const lowerProjectId = projectId.toLowerCase();
  return (
    lowerProjectId.includes('rescuenet-7733b') ||
    lowerProjectId.includes('-prod') ||
    lowerProjectId.includes('production')
  );
}

/**
 * Displays formatted manifest details with warnings.
 * Shows collection counts, storage file counts, and age warnings.
 *
 * @param {Object} manifest - The manifest object from export
 */
function displayManifest(manifest) {
  console.log(chalk.cyan('\n=== Export Manifest ==='));
  console.log(chalk.white('Export Version:'), manifest.version || 'unknown');
  console.log(chalk.white('Export Timestamp:'), manifest.timestamp || 'unknown');
  console.log(chalk.white('Source Project:'), manifest.sourceProject || 'unknown');

  // Display collection counts
  if (manifest.collections) {
    console.log(chalk.cyan('\nCollections:'));
    for (const [collectionName, info] of Object.entries(manifest.collections)) {
      console.log(`  ${chalk.white(collectionName)}: ${info.count} documents`);
    }
  }

  // Display storage file counts
  if (manifest.storage) {
    console.log(chalk.cyan('\nStorage Files:'));
    console.log(`  Total files: ${manifest.storage.fileCount || 0}`);
    console.log(`  Total size: ${formatBytes(manifest.storage.totalBytes || 0)}`);
  }

  // Warn if export is old (>7 days)
  if (manifest.timestamp) {
    const exportDate = new Date(manifest.timestamp);
    const now = new Date();
    const daysSinceExport = (now - exportDate) / (1000 * 60 * 60 * 24);

    if (daysSinceExport > 7) {
      console.log(chalk.yellow('\n⚠️  WARNING: This export is more than 7 days old!'));
      console.log(chalk.yellow(`   Export age: ${Math.floor(daysSinceExport)} days`));
      console.log(chalk.yellow('   Data may be outdated.'));
    }
  }

  console.log(''); // Empty line for spacing
}

/**
 * Formats bytes to human-readable string.
 *
 * @param {number} bytes - Number of bytes
 * @returns {string} Formatted string (e.g., "1.5 MB")
 */
function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

/**
 * Prompts user for confirmation before destructive import operation.
 * Implements full safety confirmation flow with multiple checks.
 *
 * @param {Object} importDetails - Details about what will be imported
 * @param {string} targetProject - Target Firebase project ID
 * @returns {Promise<boolean>} True if user confirmed, false otherwise
 */
async function confirmImport(importDetails, targetProject) {
  // Handle Ctrl+C gracefully
  prompts.override({ onCancel: () => {
    console.log(chalk.yellow('\n\nOperation cancelled by user.'));
    process.exit(0);
  }});

  // Display red warning
  console.log(chalk.red.bold('\n⚠️  DESTRUCTIVE OPERATION ⚠️'));
  console.log(chalk.red('This operation will REPLACE existing data in the target project.'));
  console.log(chalk.red('All existing data in imported collections will be DELETED.'));
  console.log(chalk.white('\nTarget Project:'), chalk.yellow.bold(targetProject));

  // Check if production project
  const isProd = isProductionProject(targetProject);
  if (isProd) {
    console.log(chalk.red.bold('\n🚨 PRODUCTION PROJECT DETECTED 🚨'));
    console.log(chalk.red('You are about to modify a PRODUCTION environment!'));
  }

  // Display manifest preview
  if (importDetails.manifest) {
    displayManifest(importDetails.manifest);
  }

  // First confirmation: understand the operation
  console.log(chalk.yellow('\nYou must confirm that you understand this is a destructive operation.'));
  const confirmUnderstand = await prompts({
    type: 'confirm',
    name: 'value',
    message: 'Do you understand this will DELETE and REPLACE data?',
    initial: false
  });

  if (!confirmUnderstand.value) {
    console.log(chalk.yellow('\nOperation cancelled.'));
    return false;
  }

  // Second confirmation: type exact project name
  console.log(chalk.yellow('\nTo proceed, type the EXACT target project name:'));
  console.log(chalk.white('Expected:'), chalk.cyan(targetProject));

  const confirmProjectName = await prompts({
    type: 'text',
    name: 'value',
    message: 'Project name:',
    validate: value => value === targetProject || 'Project name does not match'
  });

  if (confirmProjectName.value !== targetProject) {
    console.log(chalk.red('\n❌ Project name does not match. Operation cancelled.'));
    return false;
  }

  // Production extra confirmation
  if (isProd) {
    console.log(chalk.red.bold('\n🚨 FINAL PRODUCTION WARNING 🚨'));
    console.log(chalk.red('This is your last chance to cancel.'));
    console.log(chalk.red('Are you ABSOLUTELY SURE you want to modify production?'));

    const finalConfirm = await prompts({
      type: 'confirm',
      name: 'value',
      message: 'Proceed with PRODUCTION import?',
      initial: false
    });

    if (!finalConfirm.value) {
      console.log(chalk.yellow('\nOperation cancelled.'));
      return false;
    }
  }

  // All confirmations passed
  console.log(chalk.green('\n✓ Confirmed. Proceeding with import...\n'));
  return true;
}

module.exports = {
  confirmImport,
  displayManifest,
  isProductionProject
};
