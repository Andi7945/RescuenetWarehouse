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

# Build with dart-define flags
flutter build web \
  --dart-define=ORG="$ORG" \
  --dart-define=ENV="$ENV" \
  --release \
  --web-renderer canvaskit

# Verify the build contains correct Firebase config
echo "🔍 Verifying build configuration..."
if ! verify_bundle_project_id "build/web/main.dart.js" "$EXPECTED_PROJECT_ID"; then
  echo ""
  echo "❌ BUILD VERIFICATION FAILED!"
  echo "The compiled bundle does not contain the expected Firebase project ID."
  echo "This build is NOT safe to deploy."
  exit 1
fi

# Create build manifest
MANIFEST_PATH="build/web/.build-manifest.json"
create_build_manifest "$ORG" "$ENV" "$EXPECTED_PROJECT_ID" "$MANIFEST_PATH"
echo "📝 Build manifest created: $MANIFEST_PATH"

# Move to environment-specific directory
BUILD_DIR="build/web_${ORG}_${ENV}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r build/web/* "$BUILD_DIR/"

echo ""
echo "✅ Build complete and verified!"
echo "📦 Build directory: $BUILD_DIR"
echo "🎯 Firebase project: $EXPECTED_PROJECT_ID"
echo "🔒 Manifest: $(cat "$BUILD_DIR/.build-manifest.json")"
