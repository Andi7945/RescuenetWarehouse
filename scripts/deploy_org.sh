#!/bin/bash
set -e

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

# Safety check for production
if [ "$ENV" = "production" ]; then
  read -p "⚠️  Deploy to PRODUCTION for $ORG? (yes/no): " confirm
  if [ "$confirm" != "yes" ]; then
    echo "❌ Production deploy cancelled"
    exit 1
  fi
fi

BUILD_DIR="build/web_${ORG}_${ENV}"

# Verify build exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Error: Build not found at $BUILD_DIR"
  echo "Run: ./scripts/build_org.sh $ORG $ENV"
  exit 1
fi

# Copy build to firebase public directory
rm -rf build/web
cp -r "$BUILD_DIR" build/web

# Switch to correct Firebase project
RC_FILE=".firebaserc_${ORG}_${ENV}"
if [ ! -f "$RC_FILE" ]; then
  echo "❌ Error: Firebase RC file not found: $RC_FILE"
  exit 1
fi

cp "$RC_FILE" .firebaserc

echo "🚀 Deploying $ORG to $ENV..."
firebase deploy --only hosting

echo "✅ Deploy complete!"
echo "🌍 URL: https://$(jq -r '.projects.default' .firebaserc).web.app"
