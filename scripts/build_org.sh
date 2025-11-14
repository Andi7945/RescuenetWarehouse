#!/bin/bash
set -e  # Exit on error

# Source verification library
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/verify_build.sh"

# Parse arguments
ORG=${1:-}
ENV=${2:-staging}

# Validation
if [ -z "$ORG" ]; then
  echo "❌ Error: Organization ID required"
  echo "Usage: ./scripts/build_org.sh <org_id> [environment]"
  echo "Example: ./scripts/build_org.sh rescuenet staging"
  exit 1
fi

# Validate environment
if [[ ! "$ENV" =~ ^(staging|production)$ ]]; then
  echo "❌ Error: Invalid environment '$ENV'. Use 'staging' or 'production'."
  exit 1
fi

echo "🏗️  Building $ORG for $ENV environment..."

# Get expected project ID
EXPECTED_PROJECT_ID=$(get_expected_project_id "$ORG" "$ENV")
if [ -z "$EXPECTED_PROJECT_ID" ]; then
  echo "❌ Error: Unknown org/env combination: $ORG/$ENV"
  exit 1
fi

echo "📋 Target Firebase project: $EXPECTED_PROJECT_ID"

# Clean build directory to prevent contamination
echo "🧹 Cleaning build directory..."
rm -rf build/web

# Generate org_registry.dart with only the needed Firebase configuration
echo "📝 Generating org_registry.dart for $ORG/$ENV..."
TEMPLATE_PATH="lib/config/org_registry.dart.template"
OUTPUT_PATH="lib/config/org_registry.dart"

# Back up existing file if it's not a generated one
if [ -f "$OUTPUT_PATH" ] && ! grep -q "GENERATED at build time" "$OUTPUT_PATH"; then
  echo "   Backing up existing org_registry.dart to org_registry.dart.backup..."
  cp "$OUTPUT_PATH" "${OUTPUT_PATH}.backup"
fi

# Generate the org_registry.dart for this specific org/env
if ! "$SCRIPT_DIR/lib/generate_org_registry.sh" "$ORG" "$ENV" "$TEMPLATE_PATH" "$OUTPUT_PATH"; then
  echo ""
  echo "❌ GENERATION FAILED!"
  echo "Failed to generate org_registry.dart for $ORG/$ENV"
  exit 1
fi

# Build with dart-define flags
flutter build web \
  --dart-define=ORG="$ORG" \
  --dart-define=ENV="$ENV" \
  --release

# Verify the build contains correct Firebase config (single-config enforcement)
echo "🔍 Verifying build configuration (single-config mode)..."
if ! verify_bundle_single_config "build/web/main.dart.js" "$EXPECTED_PROJECT_ID"; then
  echo ""
  echo "❌ SINGLE-CONFIG VERIFICATION FAILED!"
  echo "The compiled bundle either:"
  echo "  - Does not contain the expected Firebase project ID, or"
  echo "  - Contains multiple Firebase configurations (security risk)"
  echo "This build is NOT safe to deploy."
  exit 1
fi

# Create build manifest
MANIFEST_PATH="build/web/.build-manifest.json"
create_build_manifest "$ORG" "$ENV" "$EXPECTED_PROJECT_ID" "$MANIFEST_PATH"
echo "📝 Build manifest created: $MANIFEST_PATH"

# Move to environment-specific directory (including hidden files like .build-manifest.json)
BUILD_DIR="build/web_${ORG}_${ENV}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
# Copy visible files
cp -r build/web/* "$BUILD_DIR/" 2>/dev/null || true

# Copy specific hidden files (safely, without .* which includes .. parent directory)
if [ -f "build/web/.build-manifest.json" ]; then
  cp "build/web/.build-manifest.json" "$BUILD_DIR/"
fi

echo ""
echo "✅ Build complete and verified!"
echo "📦 Build directory: $BUILD_DIR"
echo "🎯 Firebase project: $EXPECTED_PROJECT_ID"
echo "🔒 Manifest: $(cat "$BUILD_DIR/.build-manifest.json")"
