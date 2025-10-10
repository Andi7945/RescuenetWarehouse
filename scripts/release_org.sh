#!/bin/bash
set -e

ORG=${1:-}
ENV=${2:-staging}

if [ -z "$ORG" ]; then
  echo "Usage: ./scripts/release_org.sh <org_id> [environment]"
  exit 1
fi

echo "🔄 Building and deploying $ORG to $ENV..."

./scripts/build_org.sh "$ORG" "$ENV"
./scripts/deploy_org.sh "$ORG" "$ENV"

echo "🎉 Release complete!"
