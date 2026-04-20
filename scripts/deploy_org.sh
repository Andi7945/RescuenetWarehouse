#!/bin/bash
set -e

# Source verification library
source "$(dirname "$0")/lib/verify_build.sh"

# Parse arguments
ORG=${1:-}
ENV=${2:-staging}

# Validation
if [ -z "$ORG" ]; then
  echo "❌ Error: Organization ID required"
  echo "Usage: ./scripts/deploy_org.sh <org_id> [environment]"
  exit 1
fi

if [[ ! "$ENV" =~ ^(staging|production)$ ]]; then
  echo "❌ Error: Invalid environment '$ENV'"
  exit 1
fi

BUILD_DIR="build/web_${ORG}_${ENV}"

# Verify build exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Error: Build not found at $BUILD_DIR"
  echo "Run: ./scripts/build_org.sh $ORG $ENV"
  exit 1
fi

# Verify manifest exists and matches
echo "🔍 Verifying build manifest..."
MANIFEST_PATH="$BUILD_DIR/.build-manifest.json"
if ! verify_manifest_matches "$MANIFEST_PATH" "$ORG" "$ENV"; then
  echo ""
  echo "❌ DEPLOYMENT BLOCKED!"
  echo "Build manifest does not match requested deployment."
  exit 1
fi

# Re-verify bundle project ID
EXPECTED_PROJECT_ID=$(get_expected_project_id "$ORG" "$ENV")
echo "🔍 Re-verifying bundle configuration..."
if ! verify_bundle_single_config "$BUILD_DIR/main.dart.js" "$EXPECTED_PROJECT_ID"; then
  echo ""
  echo "❌ DEPLOYMENT BLOCKED!"
  echo "Bundle verification failed. Build may be corrupted."
  exit 1
fi

# Check build age
if ! check_build_age "$MANIFEST_PATH" 48; then
  read -p "Continue with stale build? (yes/no): " continue_stale
  if [ "$continue_stale" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
  fi
fi

# Switch to correct Firebase project
RC_FILE=".firebaserc_${ORG}_${ENV}"
if [ ! -f "$RC_FILE" ]; then
  echo "❌ Error: Firebase RC file not found: $RC_FILE"
  exit 1
fi

cp "$RC_FILE" .firebaserc

# Extract project ID from .firebaserc
PROJECT_ID=$(jq -r '.projects.default' .firebaserc)

# Verify .firebaserc matches expected
if [ "$PROJECT_ID" != "$EXPECTED_PROJECT_ID" ]; then
  echo "❌ Error: .firebaserc contains wrong project ID"
  echo "   Expected: $EXPECTED_PROJECT_ID"
  echo "   Found:    $PROJECT_ID"
  exit 1
fi

# Show comprehensive deployment summary
BUILD_INFO=$(cat "$MANIFEST_PATH")
BUILD_TIMESTAMP=$(echo "$BUILD_INFO" | jq -r '.timestamp')
GIT_COMMIT=$(echo "$BUILD_INFO" | jq -r '.git_commit')

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  DEPLOYMENT SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo "  Organization:      $ORG"
echo "  Environment:       $ENV"
echo "  Firebase Project:  $PROJECT_ID"
echo "  Build Timestamp:   $BUILD_TIMESTAMP"
echo "  Git Commit:        $GIT_COMMIT"
echo "  Target URL:        https://$PROJECT_ID.web.app"
echo "═══════════════════════════════════════════════════════"
echo ""

# Enhanced confirmation for production
if [ "$ENV" = "production" ]; then
  echo "⚠️  PRODUCTION DEPLOYMENT"
  echo "To confirm, type the exact Firebase project ID: $PROJECT_ID"
  read -p "> " typed_id
  if [ "$typed_id" != "$PROJECT_ID" ]; then
    echo "❌ Production deploy cancelled (project ID mismatch)"
    exit 1
  fi
else
  read -p "Deploy to staging? (yes/no): " confirm
  if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
  fi
fi

# Copy build to firebase public directory
rm -rf build/web
cp -r "$BUILD_DIR" build/web

# Clear Firebase CLI cache
rm -rf .firebase/

echo "🚀 Deploying $ORG to $ENV (project: $PROJECT_ID)..."
firebase deploy --only hosting --project "$PROJECT_ID"

echo ""
echo "✅ Deploy complete!"
echo "🌍 URL: https://$PROJECT_ID.web.app"

# Log deployment
./scripts/lib/log_deployment.sh "$ORG" "$ENV" "$PROJECT_ID" "$GIT_COMMIT"
