# Local File Export/Import Support

## 1. OVERVIEW

### Summary
Add support for exporting Firebase (Firestore + Storage) to local filesystem and importing from local filesystem, alongside existing GCS bucket functionality.

### Why It's Valuable
**Use Cases:**
- **Local development/testing**: Export prod data to local, import to dev project without GCS dependency
- **Quick backups**: Direct filesystem backups for ad-hoc scenarios
- **Cost optimization**: Avoid GCS storage costs for temporary exports
- **Air-gapped environments**: Export to local, transfer via secure channels
- **Faster iteration**: No network latency for local dev workflows
- **CI/CD flexibility**: Store exports as build artifacts without GCS setup

### High-Level Approach
1. Add CLI flags `--local-output <path>` and `--local-input <path>`
2. Create thin filesystem adapter matching GCS interface
3. Extract pure functions for path/manifest manipulation
4. Keep GCS and local code paths separate (no premature abstraction)
5. Reuse existing export/import business logic

**Philosophy**: Simple conditional branches at CLI level, not complex abstraction layers. Let Node.js `fs` module handle local I/O, keep `@google-cloud/storage` for GCS.

## 2. ARCHITECTURE DECISIONS

### Local vs GCS Abstraction
**Decision: NO storage abstraction layer**

**Why:**
- **KISS**: Two simple code paths beat one complex abstraction
- **Different semantics**: GCS has buckets/blobs, local has directories/files
- **Startup velocity**: Abstraction takes time, adds complexity, harder to debug
- **Low duplication**: Actual I/O is small % of codebase

**Implementation:**
```javascript
// GOOD: Simple branching
if (localPath) {
  await writeLocalJSON(localPath, data);
} else {
  await writeGCSJSON(bucketName, blobPath, data);
}

// BAD: Over-engineered
const storage = createStorageAdapter(config);
await storage.write(path, data); // Unnecessary abstraction
```

### Module Structure
**Keep existing modules, add parallel local modules:**
```
lib/
├── gcs-client.js           # GCS operations (existing)
├── local-client.js         # NEW: Local filesystem operations
├── firestore-export.js     # Pure logic (no changes needed)
├── firestore-import.js     # Pure logic (no changes needed)
├── storage-export.js       # Modify: branch on local vs GCS
├── storage-import.js       # Modify: branch on local vs GCS
└── manifest.js             # NEW: Pure functions for manifest manipulation
```

### Pure Function Opportunities
Extract these pure functions (no side effects, easy to test):
```javascript
// manifest.js
function createManifest(metadata) { ... }
function parseManifest(jsonString) { ... }
function validateManifest(manifest) { ... }
function getManifestPath(basePath, format) { ... } // format: 'gcs' | 'local'

// path-utils.js (NEW)
function normalizeLocalPath(path) { ... }
function ensureDirectoryPath(path) { ... }
function getCollectionFilePath(basePath, collectionName) { ... }
function getStorageFilePath(basePath, fileName) { ... }
```

### What NOT to Abstract
- **No unified Storage interface**: GCS SDK and `fs` are different, forcing them together adds friction
- **No repository pattern**: Direct I/O calls are fine for this use case
- **No dependency injection**: Simple module imports work
- **No complex factory patterns**: Conditional logic is clearer

## 3. FILE STRUCTURE CHANGES

### New Files

**`lib/local-client.js`**
- Purpose: Local filesystem read/write operations
- Responsibilities:
  - Write JSON files
  - Read JSON files
  - Copy files (for Storage)
  - Create directories
  - Check file existence
- Why: Single module for all local I/O, mirrors `gcs-client.js`

**`lib/manifest.js`**
- Purpose: Pure functions for manifest creation/parsing
- Responsibilities:
  - Create manifest object from metadata
  - Serialize/deserialize manifest
  - Validate manifest structure
  - Generate manifest file paths
- Why: Currently embedded in export script, extract for reuse and testability

**`lib/path-utils.js`**
- Purpose: Pure functions for path manipulation
- Responsibilities:
  - Normalize paths (handle trailing slashes, etc.)
  - Generate collection file paths
  - Generate storage subdirectories
  - Resolve relative paths
- Why: Path logic used in multiple places, centralize to avoid bugs

### Modified Files

**`export-firebase.js`**
- Add `--local-output <path>` CLI argument
- Branch logic: detect local vs GCS mode
- Call local or GCS functions based on mode
- Update logging to show local path or GCS bucket

**`import-firebase.js`**
- Add `--local-input <path>` CLI argument
- Branch logic: detect local vs GCS mode
- Call local or GCS functions based on mode
- Update logging

**`lib/storage-export.js`**
- Add `copyStorageFilesLocal()` function
- Keep existing `copyStorageFiles()` for GCS
- Download Firebase Storage files to local directory
- Export both functions

**`lib/storage-import.js`**
- Add `restoreStorageFilesLocal()` function
- Keep existing `restoreStorageFiles()` for GCS
- Upload files from local directory to Firebase Storage
- Export both functions

**`lib/gcs-client.js`**
- Extract manifest logic to `lib/manifest.js`
- Keep GCS-specific I/O logic
- Simplify function signatures

## 4. DETAILED IMPLEMENTATION PLAN

### Export Implementation

**CLI Argument Handling:**
```javascript
// export-firebase.js
const argv = yargs(process.argv.slice(2))
  .option('local-output', {
    alias: 'l',
    type: 'string',
    description: 'Local directory path for export output (alternative to GCS bucket)',
    conflicts: 'bucket', // Can't use both
  })
  .option('bucket', {
    alias: 'b',
    type: 'string',
    description: 'GCS bucket name for export output',
  })
  .check((argv) => {
    if (!argv.localOutput && !argv.bucket) {
      throw new Error('Must specify either --local-output or --bucket');
    }
    return true;
  })
  .argv;

const isLocalMode = Boolean(argv.localOutput);
```

**Local File Writing Strategy:**
```javascript
// lib/local-client.js
const fs = require('fs').promises;
const path = require('path');

async function writeJSON(filePath, data) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
}

async function readJSON(filePath) {
  const content = await fs.readFile(filePath, 'utf8');
  return JSON.parse(content);
}

async function copyFile(srcPath, destPath) {
  await fs.mkdir(path.dirname(destPath), { recursive: true });
  await fs.copyFile(srcPath, destPath);
}

async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}
```

**Directory Structure:**
```
<local-output>/
├── manifest.json                    # Export metadata
├── firestore/
│   ├── items.json                  # Each collection as JSON file
│   ├── containers.json
│   ├── assignments.json
│   └── ...
└── storage/
    ├── <file1.jpg>                 # Storage files (flat or mirrored structure)
    ├── <file2.pdf>
    └── ...
```

**Manifest Handling:**
```javascript
// lib/manifest.js (pure functions)
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
    },
  };
}

function getManifestPath(basePath, mode) {
  if (mode === 'local') {
    return path.join(basePath, 'manifest.json');
  } else {
    // GCS blob path
    return 'manifest.json';
  }
}

// export-firebase.js usage
const manifest = createManifest({ projectId, timestamp, collections, storageFiles });

if (isLocalMode) {
  const manifestPath = getManifestPath(argv.localOutput, 'local');
  await localClient.writeJSON(manifestPath, manifest);
} else {
  await gcsClient.writeJSON(bucketName, 'manifest.json', manifest);
}
```

**Storage File Handling:**
```javascript
// lib/storage-export.js
async function copyStorageFilesLocal(sourceBucket, localOutputDir) {
  const storageDir = path.join(localOutputDir, 'storage');
  await fs.mkdir(storageDir, { recursive: true });

  const [files] = await sourceBucket.getFiles();
  const copiedFiles = [];

  for (const file of files) {
    const destPath = path.join(storageDir, file.name);
    await fs.mkdir(path.dirname(destPath), { recursive: true });

    // Download from Firebase Storage to local
    await file.download({ destination: destPath });

    copiedFiles.push({
      name: file.name,
      size: (await fs.stat(destPath)).size,
    });

    console.log(`Downloaded: ${file.name}`);
  }

  return copiedFiles;
}

// export-firebase.js usage
if (isLocalMode) {
  storageFiles = await copyStorageFilesLocal(bucket, argv.localOutput);
} else {
  storageFiles = await copyStorageFiles(bucket, destBucket);
}
```

### Import Implementation

**CLI Argument Handling:**
```javascript
// import-firebase.js
const argv = yargs(process.argv.slice(2))
  .option('local-input', {
    alias: 'l',
    type: 'string',
    description: 'Local directory path containing export data',
    conflicts: 'bucket',
  })
  .option('bucket', {
    alias: 'b',
    type: 'string',
    description: 'GCS bucket containing export data',
  })
  .check((argv) => {
    if (!argv.localInput && !argv.bucket) {
      throw new Error('Must specify either --local-input or --bucket');
    }
    return true;
  })
  .argv;

const isLocalMode = Boolean(argv.localInput);
```

**Local File Reading Strategy:**
```javascript
// import-firebase.js main flow
let manifest;

if (isLocalMode) {
  // Validate directory exists
  const manifestPath = path.join(argv.localInput, 'manifest.json');
  if (!await localClient.fileExists(manifestPath)) {
    throw new Error(`Manifest not found at: ${manifestPath}`);
  }

  manifest = await localClient.readJSON(manifestPath);
} else {
  manifest = await gcsClient.readJSON(bucketName, 'manifest.json');
}

// Validate manifest
validateManifest(manifest);

// Import Firestore collections
for (const collection of manifest.collections) {
  let collectionData;

  if (isLocalMode) {
    const collectionPath = path.join(argv.localInput, collection.filePath);
    collectionData = await localClient.readJSON(collectionPath);
  } else {
    collectionData = await gcsClient.readJSON(bucketName, collection.filePath);
  }

  await importCollection(firestore, collection.name, collectionData);
}

// Import Storage files
if (isLocalMode) {
  await restoreStorageFilesLocal(
    path.join(argv.localInput, 'storage'),
    targetBucket
  );
} else {
  await restoreStorageFiles(sourceBucket, targetBucket);
}
```

**Validation:**
```javascript
// lib/manifest.js
function validateManifest(manifest) {
  if (!manifest.version) {
    throw new Error('Invalid manifest: missing version');
  }
  if (!manifest.projectId) {
    throw new Error('Invalid manifest: missing projectId');
  }
  if (!Array.isArray(manifest.collections)) {
    throw new Error('Invalid manifest: collections must be an array');
  }
  // Additional validation...
  return true;
}
```

**Storage Import:**
```javascript
// lib/storage-import.js
async function restoreStorageFilesLocal(localStorageDir, targetBucket) {
  if (!await fs.access(localStorageDir).then(() => true).catch(() => false)) {
    console.warn(`Storage directory not found: ${localStorageDir}, skipping...`);
    return [];
  }

  const files = await getAllFilesRecursive(localStorageDir);
  const uploadedFiles = [];

  for (const localFilePath of files) {
    // Get relative path from storage dir
    const relativePath = path.relative(localStorageDir, localFilePath);

    // Upload to Firebase Storage
    await targetBucket.upload(localFilePath, {
      destination: relativePath,
    });

    uploadedFiles.push(relativePath);
    console.log(`Uploaded: ${relativePath}`);
  }

  return uploadedFiles;
}

async function getAllFilesRecursive(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...await getAllFilesRecursive(fullPath));
    } else {
      files.push(fullPath);
    }
  }

  return files;
}
```

## 5. CODE DESIGN PATTERNS

### Pure Functions to Extract

**Manifest Operations (lib/manifest.js):**
```javascript
// Pure: no side effects, deterministic
function createManifest({ projectId, timestamp, collections, storageFiles }) {
  return {
    version: '1.0',
    exportedAt: timestamp,
    projectId,
    collections: collections.map(c => ({
      name: c.name,
      documentCount: c.count,
      filePath: `firestore/${c.name}.json`,
    })),
    storage: {
      fileCount: storageFiles.length,
      path: 'storage/',
    },
  };
}

function parseManifest(jsonString) {
  return JSON.parse(jsonString);
}

function validateManifest(manifest) {
  if (!manifest.version) throw new Error('Missing version');
  if (!manifest.projectId) throw new Error('Missing projectId');
  if (!Array.isArray(manifest.collections)) throw new Error('Invalid collections');
  return true;
}
```

**Path Utilities (lib/path-utils.js):**
```javascript
// Pure: deterministic path calculations
const path = require('path');

function getCollectionFilePath(basePath, collectionName, mode) {
  const relativePath = `firestore/${collectionName}.json`;
  return mode === 'local'
    ? path.join(basePath, relativePath)
    : relativePath; // GCS uses blob paths
}

function getStorageDirectory(basePath, mode) {
  return mode === 'local'
    ? path.join(basePath, 'storage')
    : 'storage/';
}

function normalizeLocalPath(inputPath) {
  return path.resolve(inputPath);
}
```

### Shared Utilities

**Error Handling Wrapper:**
```javascript
// lib/errors.js
class ExportError extends Error {
  constructor(message, cause) {
    super(message);
    this.name = 'ExportError';
    this.cause = cause;
  }
}

class ImportError extends Error {
  constructor(message, cause) {
    super(message);
    this.name = 'ImportError';
    this.cause = cause;
  }
}

function wrapError(fn, ErrorClass) {
  return async (...args) => {
    try {
      return await fn(...args);
    } catch (error) {
      throw new ErrorClass(error.message, error);
    }
  };
}

module.exports = { ExportError, ImportError, wrapError };
```

### Interface Between Modules

**Contract: All I/O modules must provide:**
```javascript
// Minimal interface (no formal abstraction needed, just convention)

// Read operations
async function readJSON(path) { ... }
async function fileExists(path) { ... }

// Write operations
async function writeJSON(path, data) { ... }

// File operations
async function copyFile(src, dest) { ... }
```

**Usage in main scripts:**
```javascript
// export-firebase.js
const ioClient = isLocalMode ? require('./lib/local-client') : require('./lib/gcs-client');

// Both modules expose same function names, different implementations
await ioClient.writeJSON(targetPath, data);
```

### Avoiding Duplication

**Strategy: Extract business logic from I/O:**
```javascript
// BEFORE (duplication risk):
// In export-firebase.js
if (isLocalMode) {
  // Logic for preparing data
  const manifest = { ... };
  await localClient.writeJSON(path, manifest);
} else {
  // Same logic repeated
  const manifest = { ... };
  await gcsClient.writeJSON(path, manifest);
}

// AFTER (no duplication):
// Pure function extracts business logic
const manifest = createManifest({ projectId, collections, storageFiles });

// I/O separated
if (isLocalMode) {
  await localClient.writeJSON(manifestPath, manifest);
} else {
  await gcsClient.writeJSON(bucketName, 'manifest.json', manifest);
}
```

## 6. TESTING STRATEGY

### What MUST Be Tested (Critical Paths)

**1. Pure Functions (100% coverage, easy to test):**
- `createManifest()` - different input combinations
- `validateManifest()` - valid and invalid manifests
- `getCollectionFilePath()` - local vs GCS paths
- Path normalization functions

**Test Example:**
```javascript
// test/manifest.test.js
const { createManifest, validateManifest } = require('../lib/manifest');

describe('createManifest', () => {
  it('creates valid manifest with collections and storage', () => {
    const manifest = createManifest({
      projectId: 'test-project',
      timestamp: '2025-01-15T10:00:00Z',
      collections: [{ name: 'items', count: 100 }],
      storageFiles: [{ name: 'file1.jpg' }],
    });

    expect(manifest.version).toBe('1.0');
    expect(manifest.projectId).toBe('test-project');
    expect(manifest.collections).toHaveLength(1);
    expect(manifest.storage.fileCount).toBe(1);
  });
});

describe('validateManifest', () => {
  it('throws on missing version', () => {
    expect(() => validateManifest({})).toThrow('Missing version');
  });

  it('validates correct manifest', () => {
    const valid = {
      version: '1.0',
      projectId: 'test',
      collections: [],
    };
    expect(() => validateManifest(valid)).not.toThrow();
  });
});
```

**2. Integration Tests (Key Workflows):**
- Export to local directory (full flow)
- Import from local directory (full flow)
- Round-trip: export → import → verify data matches

**Test Example (using temp directories):**
```javascript
// test/integration/local-export.test.js
const { exportToLocal } = require('../export-firebase');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');

describe('Local Export Integration', () => {
  let tempDir;

  beforeEach(async () => {
    tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'firebase-export-'));
  });

  afterEach(async () => {
    await fs.rm(tempDir, { recursive: true, force: true });
  });

  it('exports Firestore and Storage to local directory', async () => {
    // Mock Firebase Admin SDK (or use emulator)
    await exportToLocal(tempDir, { projectId: 'test-project' });

    // Verify structure
    const manifest = JSON.parse(
      await fs.readFile(path.join(tempDir, 'manifest.json'), 'utf8')
    );
    expect(manifest.version).toBe('1.0');

    const firestoreDir = path.join(tempDir, 'firestore');
    const files = await fs.readdir(firestoreDir);
    expect(files.length).toBeGreaterThan(0);
  });
});
```

### What Should NOT Be Tested (Over-Testing)

**DON'T test:**
- Node.js built-in APIs (`fs.writeFile`, `path.join`) - trust the platform
- Firebase Admin SDK methods - trust Google's library
- `@google-cloud/storage` SDK - trust the library
- Trivial getters/setters
- Simple logging statements
- Exact console output formatting

**DON'T mock excessively:**
- Filesystem in integration tests - use temp directories instead
- Simple pure functions - test them directly

### Testing Approach

**Unit Tests:**
- Pure functions in `lib/manifest.js`
- Pure functions in `lib/path-utils.js`
- Fast, no I/O, deterministic

**Integration Tests:**
- Full export to temp directory
- Full import from temp directory
- Use Firebase Emulator for Firestore/Storage
- Clean up temp files after each test

**Manual Testing (Startup Pragmatism):**
- Test with real Firebase project in dev environment
- Verify GCS functionality still works
- Test error scenarios manually (invalid paths, permissions)

**Coverage Target:**
- Pure functions: 100%
- Integration paths: Critical flows only
- Total coverage: ~70% (pragmatic, not dogmatic)

## 7. MIGRATION & COMPATIBILITY

### Backward Compatibility

**100% backward compatible:**
- Existing GCS-based workflows unchanged
- No breaking changes to CLI arguments
- `--bucket` flag continues to work exactly as before
- No changes to GCS output format or structure

**New functionality is additive:**
```bash
# OLD: Still works
node export-firebase.js --project my-project --bucket my-backup-bucket

# NEW: Alternative approach
node export-firebase.js --project my-project --local-output ./backups/2025-01-15
```

### How Existing Scripts/Docs Continue to Work

**No action required for existing users:**
- Default behavior unchanged
- Documentation examples remain valid
- CI/CD pipelines unaffected
- Existing backup buckets continue working

**Scripts using programmatic API:**
```javascript
// Old code still works
const { exportAllCollections } = require('./lib/firestore-export');
const { copyStorageFiles } = require('./lib/storage-export');

// New functions are additions, not replacements
const { copyStorageFilesLocal } = require('./lib/storage-export');
```

### Deprecation Strategy

**No deprecation needed:**
- GCS support is NOT deprecated
- Both modes coexist indefinitely
- No plans to remove GCS functionality
- Users choose mode based on needs

**Future consideration:**
- If 99% of users switch to local, THEN consider deprecation (years away)
- Announce deprecation 6+ months in advance
- Maintain GCS code for legacy projects

## 8. EDGE CASES & ERROR HANDLING

### Invalid Paths

**Problem:** User provides non-existent or invalid local path

**Handling:**
```javascript
// export-firebase.js
if (isLocalMode) {
  const resolvedPath = path.resolve(argv.localOutput);

  // Check parent directory exists (we'll create target dir)
  const parentDir = path.dirname(resolvedPath);
  try {
    await fs.access(parentDir, fs.constants.W_OK);
  } catch (error) {
    console.error(`❌ Parent directory not accessible: ${parentDir}`);
    console.error('Ensure the parent directory exists and is writable.');
    process.exit(1);
  }

  // Create target directory
  await fs.mkdir(resolvedPath, { recursive: true });
}

// import-firebase.js
if (isLocalMode) {
  const resolvedPath = path.resolve(argv.localInput);

  try {
    await fs.access(resolvedPath, fs.constants.R_OK);
  } catch (error) {
    console.error(`❌ Input directory not accessible: ${resolvedPath}`);
    console.error('Ensure the directory exists and is readable.');
    process.exit(1);
  }
}
```

### Permission Errors

**Problem:** Insufficient filesystem permissions

**Handling:**
```javascript
// lib/local-client.js
async function writeJSON(filePath, data) {
  try {
    await fs.mkdir(path.dirname(filePath), { recursive: true });
    await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
  } catch (error) {
    if (error.code === 'EACCES') {
      throw new Error(
        `Permission denied writing to: ${filePath}\n` +
        `Check directory permissions and try again.`
      );
    }
    throw error; // Re-throw other errors
  }
}

// Similar for read operations
async function readJSON(filePath) {
  try {
    const content = await fs.readFile(filePath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    if (error.code === 'EACCES') {
      throw new Error(`Permission denied reading: ${filePath}`);
    }
    if (error.code === 'ENOENT') {
      throw new Error(`File not found: ${filePath}`);
    }
    throw error;
  }
}
```

### Disk Space Issues

**Problem:** Insufficient disk space during export

**Handling:**
```javascript
// Pre-flight check (optional, nice-to-have)
async function checkDiskSpace(targetDir, estimatedSizeGB) {
  const diskusage = require('diskusage');
  const { available } = await diskusage.check(targetDir);
  const availableGB = available / (1024 ** 3);

  if (availableGB < estimatedSizeGB * 1.2) { // 20% buffer
    console.warn(
      `⚠️  Low disk space: ${availableGB.toFixed(2)}GB available, ` +
      `estimated need: ${estimatedSizeGB.toFixed(2)}GB`
    );
    console.warn('Export may fail if disk fills up.');
  }
}

// Graceful failure during write
async function writeJSON(filePath, data) {
  try {
    await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
  } catch (error) {
    if (error.code === 'ENOSPC') {
      throw new Error(
        'Disk space full! Export cannot continue.\n' +
        'Free up space or use a different directory.'
      );
    }
    throw error;
  }
}
```

**Practical approach:**
- Don't implement disk space pre-checks in MVP (complexity, dependencies)
- Handle ENOSPC error gracefully
- Log clear error message with recovery steps
- Let OS/Node handle low-level disk management

### Partial Exports/Imports

**Problem:** Export/import interrupted mid-process

**Export Handling:**
```javascript
// export-firebase.js
const exportState = {
  collectionsCompleted: [],
  storageCompleted: false,
  manifestWritten: false,
};

try {
  // Export collections
  for (const collectionName of collectionNames) {
    await exportCollection(collectionName);
    exportState.collectionsCompleted.push(collectionName);
  }

  // Export storage
  await exportStorage();
  exportState.storageCompleted = true;

  // Write manifest (last step)
  await writeManifest();
  exportState.manifestWritten = true;

  console.log('✅ Export completed successfully');
} catch (error) {
  console.error('❌ Export failed:', error.message);
  console.error('Partial export state:', exportState);
  console.error('To resume, re-run the export command.');
  process.exit(1);
}
```

**Import Validation:**
```javascript
// import-firebase.js
async function validateCompleteExport(manifest, basePath, isLocal) {
  const errors = [];

  // Check all collection files exist
  for (const collection of manifest.collections) {
    const filePath = isLocal
      ? path.join(basePath, collection.filePath)
      : collection.filePath;

    const exists = isLocal
      ? await localClient.fileExists(filePath)
      : await gcsClient.fileExists(bucketName, filePath);

    if (!exists) {
      errors.push(`Missing collection file: ${collection.filePath}`);
    }
  }

  if (errors.length > 0) {
    throw new Error(
      'Incomplete export detected:\n' + errors.join('\n') +
      '\n\nExport may have been interrupted. Please re-export.'
    );
  }
}

// Run validation before import
await validateCompleteExport(manifest, inputPath, isLocalMode);
```

**Recovery Strategy:**
- No automatic retry (KISS principle)
- Clear error messages indicating what failed
- User re-runs command (export is idempotent)
- Consider adding `--resume` flag in Phase 2 (nice-to-have)

### Conflicting Flags

**Problem:** User specifies both `--bucket` and `--local-output`

**Handling:**
```javascript
// CLI validation (yargs)
.check((argv) => {
  if (argv.bucket && argv.localOutput) {
    throw new Error(
      'Cannot use both --bucket and --local-output.\n' +
      'Choose one export destination.'
    );
  }
  if (!argv.bucket && !argv.localOutput) {
    throw new Error(
      'Must specify export destination:\n' +
      '  --bucket <name>  OR  --local-output <path>'
    );
  }
  return true;
})
```

## 9. IMPLEMENTATION PHASES

### Phase 1: MVP (Minimum Viable Product)

**Goal:** Local export/import working for core use case

**Scope:**
1. ✅ Export Firestore to local JSON files
2. ✅ Export Storage to local directory (flat structure)
3. ✅ Import Firestore from local JSON files
4. ✅ Import Storage from local directory
5. ✅ Manifest creation/validation
6. ✅ Basic error handling (file not found, permissions)
7. ✅ CLI argument parsing
8. ✅ Unit tests for pure functions
9. ✅ One integration test (export + import round-trip)
10. ✅ Update README with examples

**Estimated Time:** 1-2 days for experienced dev

**Deliverables:**
- Working `--local-output` flag
- Working `--local-input` flag
- Basic documentation
- Core tests passing

**What's NOT in MVP:**
- Disk space pre-checks
- Resume/retry logic
- Progress bars
- Compression
- Parallel uploads/downloads

### Phase 2: Nice-to-Haves

**Goal:** Polish and performance

**Scope:**
1. ⏳ Parallel file operations (faster Storage export/import)
2. ⏳ Progress bars for long operations
3. ⏳ `--dry-run` flag (show what would be exported/imported)
4. ⏳ Disk space validation before export
5. ⏳ `--resume` flag for interrupted exports
6. ⏳ Compression option (`--compress` for .tar.gz output)
7. ⏳ More comprehensive integration tests
8. ⏳ Performance benchmarks

**Estimated Time:** 2-3 days

**Prioritization:**
- Parallel operations: High value (10x faster for large Storage)
- Progress bars: Medium value (UX improvement)
- Dry-run: Medium value (safety feature)
- Everything else: Low priority (ship if time allows)

### What Can Be Punted

**Features to skip (not needed for MVP or Phase 2):**
- Incremental backups (too complex)
- Encryption at rest (use OS-level encryption)
- Cloud-agnostic abstraction (YAGNI - You Aren't Gonna Need It)
- GUI/web interface (CLI is sufficient)
- Differential exports (full exports are fine)
- Custom serialization formats (JSON is sufficient)
- Transaction log replay (out of scope)

**Rationale:**
- MVP gets 80% of value with 20% of effort
- Ship fast, gather user feedback
- Add features based on real user needs, not speculation

## 10. DOCUMENTATION UPDATES NEEDED

### README Changes

**Add new section: "Local Filesystem Export/Import"**

```markdown
## Export/Import Options

### Export to Google Cloud Storage (GCS)

Export your Firebase data to a GCS bucket for cloud backups:

```bash
node export-firebase.js \
  --project my-firebase-project \
  --bucket my-backup-bucket \
  --service-account-key ./keys/service-account.json
```

### Export to Local Filesystem

Export your Firebase data to a local directory:

```bash
node export-firebase.js \
  --project my-firebase-project \
  --local-output ./backups/$(date +%Y-%m-%d) \
  --service-account-key ./keys/service-account.json
```

**Output structure:**
```
backups/2025-01-15/
├── manifest.json           # Export metadata
├── firestore/
│   ├── items.json
│   ├── containers.json
│   └── ...
└── storage/
    ├── image1.jpg
    └── ...
```

### Import from Google Cloud Storage

```bash
node import-firebase.js \
  --project my-firebase-project \
  --bucket my-backup-bucket \
  --service-account-key ./keys/service-account.json
```

### Import from Local Filesystem

```bash
node import-firebase.js \
  --project my-firebase-project \
  --local-input ./backups/2025-01-15 \
  --service-account-key ./keys/service-account.json
```

### Which Option Should I Use?

**Use GCS (--bucket) when:**
- You need cloud backups for disaster recovery
- You're automating backups via CI/CD
- You want to share exports across team members
- You need long-term archival storage

**Use Local (--local-output / --local-input) when:**
- You want quick local backups for development
- You're testing export/import functionality
- You need to transfer data via secure channels
- You want to avoid GCS storage costs
- You're working in an air-gapped environment
```

### Example Commands

**Add to README-export.md:**
```markdown
## Local Export Examples

### Basic Local Export
```bash
node scripts/export-firebase.js \
  --project rescuenet-staging \
  --local-output ./backups/manual-backup \
  --service-account-key ./keys/staging-service-account.json
```

### Timestamped Local Backup
```bash
node scripts/export-firebase.js \
  --project rescuenet-production \
  --local-output ./backups/prod-$(date +%Y%m%d-%H%M%S) \
  --service-account-key ./keys/prod-service-account.json
```

### Cross-Project Export (Local)
```bash
# Export from staging to local
node scripts/export-firebase.js \
  --project rescuenet-staging \
  --local-output ./transfer/staging-data \
  --service-account-key ./keys/staging-key.json

# Import to production
node scripts/import-firebase.js \
  --project rescuenet-production \
  --local-input ./transfer/staging-data \
  --service-account-key ./keys/prod-key.json
```
```

**Add to README-import.md:**
```markdown
## Local Import Examples

### Basic Local Import
```bash
node scripts/import-firebase.js \
  --project rescuenet-staging \
  --local-input ./backups/manual-backup \
  --service-account-key ./keys/staging-service-account.json
```

### Restore from Timestamped Backup
```bash
# List available backups
ls -lh ./backups/

# Import specific backup
node scripts/import-firebase.js \
  --project rescuenet-staging \
  --local-input ./backups/prod-20250115-143022 \
  --service-account-key ./keys/staging-key.json
```
```

### Migration Guide

**Add new file: `README-local-backups.md`**

```markdown
# Local Filesystem Backups Guide

This guide explains how to use local filesystem export/import instead of Google Cloud Storage buckets.

## When to Use Local Backups

✅ **Good use cases:**
- Quick backups before making changes
- Local development and testing
- Transferring data via secure/offline channels
- Avoiding GCS costs for temporary backups
- CI/CD build artifacts

❌ **Not recommended for:**
- Production disaster recovery (use GCS)
- Long-term archival (use GCS)
- Automated scheduled backups (use GCS)
- Team collaboration on backups (use GCS)

## Quick Start

### Export
```bash
node scripts/export-firebase.js \
  --project my-project \
  --local-output ./my-backup \
  --service-account-key ./keys/key.json
```

### Import
```bash
node scripts/import-firebase.js \
  --project my-project \
  --local-input ./my-backup \
  --service-account-key ./keys/key.json
```

## Local Backup Structure

After export, you'll have:

```
my-backup/
├── manifest.json              # Metadata about the export
├── firestore/                 # Firestore collections
│   ├── items.json
│   ├── containers.json
│   └── ...
└── storage/                   # Firebase Storage files
    ├── images/
    │   └── item123.jpg
    └── documents/
        └── label.pdf
```

## Tips

- Use timestamped directory names: `./backups/$(date +%Y%m%d-%H%M%S)`
- Store backups outside your git repository (add to .gitignore)
- Compress large backups: `tar -czf backup.tar.gz ./my-backup/`
- Test imports on staging before production

## Troubleshooting

**"Permission denied" error:**
- Ensure parent directory exists and is writable
- Check filesystem permissions

**"Disk space full" error:**
- Free up disk space
- Use a different directory with more space
- Consider exporting to GCS instead

**"Incomplete export" error:**
- Re-run the export command (it's safe to overwrite)
- Check available disk space before exporting

## Switching from GCS to Local

Existing workflows using `--bucket` will continue working unchanged. To switch:

**Before (GCS):**
```bash
node scripts/export-firebase.js --project my-project --bucket my-bucket
```

**After (Local):**
```bash
node scripts/export-firebase.js --project my-project --local-output ./backups/latest
```

No code changes needed, just swap the CLI flag.
```

### Update Existing Docs

**Changes to README-cross-project.md:**
```markdown
## Cross-Project Export/Import Workflow

### Option 1: Using GCS Bucket (Original)
[Existing content...]

### Option 2: Using Local Filesystem (New)

1. Export from source project:
```bash
node scripts/export-firebase.js \
  --project source-project \
  --local-output ./transfer/source-data \
  --service-account-key ./keys/source-key.json
```

2. Import to target project:
```bash
node scripts/import-firebase.js \
  --project target-project \
  --local-input ./transfer/source-data \
  --service-account-key ./keys/target-key.json
```

**Benefits of local approach:**
- No GCS bucket setup required
- No cross-project bucket permissions needed
- Simpler for one-time transfers
- No storage costs
```

### CLI Help Text

**Update export-firebase.js help:**
```javascript
const argv = yargs(process.argv.slice(2))
  .usage('Usage: $0 [options]')
  .example(
    '$0 --project my-project --bucket my-backup-bucket',
    'Export to GCS bucket'
  )
  .example(
    '$0 --project my-project --local-output ./backups/$(date +%Y-%m-%d)',
    'Export to local directory'
  )
  .option('bucket', {
    alias: 'b',
    type: 'string',
    description: 'GCS bucket name for export output',
  })
  .option('local-output', {
    alias: 'l',
    type: 'string',
    description: 'Local directory for export output (alternative to --bucket)',
  })
  .check((argv) => {
    if (argv.bucket && argv.localOutput) {
      throw new Error('Cannot use both --bucket and --local-output. Choose one.');
    }
    if (!argv.bucket && !argv.localOutput) {
      throw new Error('Must specify either --bucket or --local-output.');
    }
    return true;
  })
  .help()
  .alias('help', 'h')
  .argv;
```

**Update import-firebase.js help similarly.**

---

## Summary Checklist

**Architecture:**
- [x] No storage abstraction layer (KISS)
- [x] Separate local/GCS code paths with simple branching
- [x] Pure functions extracted for testability
- [x] SRP maintained across modules

**Implementation:**
- [x] New `lib/local-client.js` for filesystem I/O
- [x] New `lib/manifest.js` for pure manifest functions
- [x] New `lib/path-utils.js` for path operations
- [x] Modified export/import scripts with CLI flags
- [x] Modified storage-export/import for local mode

**Testing:**
- [x] Unit tests for pure functions
- [x] Integration test for round-trip
- [x] No over-testing (trust platform APIs)

**Documentation:**
- [x] README updates with examples
- [x] New local backups guide
- [x] Cross-project workflow updated
- [x] CLI help text enhanced

**Compatibility:**
- [x] 100% backward compatible
- [x] GCS workflows unchanged
- [x] No deprecation needed

**Error Handling:**
- [x] Invalid paths
- [x] Permission errors
- [x] Disk space issues
- [x] Partial exports/imports

**Phasing:**
- [x] Phase 1 (MVP): Core functionality
- [x] Phase 2: Polish and performance
- [x] Identified features to punt

---

## Implementation Order

1. **Day 1 Morning:** Create pure functions
   - `lib/manifest.js`
   - `lib/path-utils.js`
   - Write unit tests

2. **Day 1 Afternoon:** Local client
   - `lib/local-client.js`
   - Test with temp directories

3. **Day 2 Morning:** Export integration
   - Modify `export-firebase.js`
   - Modify `lib/storage-export.js`
   - Test local export end-to-end

4. **Day 2 Afternoon:** Import integration
   - Modify `import-firebase.js`
   - Modify `lib/storage-import.js`
   - Test local import end-to-end
   - Round-trip integration test

5. **Day 3:** Documentation & polish
   - Update all README files
   - Manual testing with real Firebase project
   - Edge case handling
   - Code review and cleanup

**Velocity:** Ship MVP in 2-3 days, iterate based on feedback.
