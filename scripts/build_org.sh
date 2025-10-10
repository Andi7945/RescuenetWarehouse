#!/bin/bash
set -e  # Exit on error

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

# Build with dart-define flags
flutter build web \
  --dart-define=ORG="$ORG" \
  --dart-define=ENV="$ENV" \
  --release \
  --web-renderer canvaskit

# Move to environment-specific directory
BUILD_DIR="build/web_${ORG}_${ENV}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r build/web/* "$BUILD_DIR/"

echo "✅ Build complete: $BUILD_DIR"
echo "📦 Firebase project: $ORG-$ENV (verify before deploy)"
