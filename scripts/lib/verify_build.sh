#!/bin/bash
# Verification library for safe deployments
# Provides pure functions for Firebase project ID extraction and validation

# Extract Firebase project ID from compiled JavaScript bundle
# Pure function: input (file path) -> output (project ID or empty)
extract_project_id_from_bundle() {
  local bundle_path="$1"
  # Extract projectId from Firebase config in JavaScript
  # Pattern: look for Firebase config object with projectId
  grep -oE '"[a-z0-9-]+","[a-z0-9-]+\.firebaseapp\.com"' "$bundle_path" | \
    grep -oE '[a-z0-9-]+' | head -1
}

# Get expected project ID for org/env combination
# Pure function: input (org, env) -> output (expected project ID)
get_expected_project_id() {
  local org="$1"
  local env="$2"

  case "$org/$env" in
    rescuenet/production) echo "rescuenet-7733b" ;;
    rescuenet/staging) echo "rescuenet-testing" ;;
    humedica/production) echo "humedica-e767c" ;;
    humedica/staging) echo "humedica-e767c" ;;  # Uses same project
    *) echo "" ;;
  esac
}

# Verify bundle contains expected project ID
# Returns: 0 (success) or 1 (failure)
verify_bundle_project_id() {
  local bundle_path="$1"
  local expected_id="$2"

  local actual_id=$(extract_project_id_from_bundle "$bundle_path")

  if [ -z "$actual_id" ]; then
    echo "❌ Error: Could not extract project ID from bundle"
    return 1
  fi

  if [ "$actual_id" != "$expected_id" ]; then
    echo "❌ PROJECT ID MISMATCH!"
    echo "   Expected: $expected_id"
    echo "   Found:    $actual_id"
    return 1
  fi

  echo "✅ Project ID verified: $actual_id"
  return 0
}

# Create build manifest JSON
create_build_manifest() {
  local org="$1"
  local env="$2"
  local project_id="$3"
  local output_file="$4"

  local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$output_file" <<EOF
{
  "org": "$org",
  "env": "$env",
  "project_id": "$project_id",
  "timestamp": "$timestamp",
  "git_commit": "$git_commit",
  "verified": true
}
EOF
}

# Verify manifest matches requested deployment
verify_manifest_matches() {
  local manifest_path="$1"
  local requested_org="$2"
  local requested_env="$3"

  if [ ! -f "$manifest_path" ]; then
    echo "❌ Error: Build manifest not found at $manifest_path"
    return 1
  fi

  local manifest_org=$(jq -r '.org' "$manifest_path")
  local manifest_env=$(jq -r '.env' "$manifest_path")
  local manifest_verified=$(jq -r '.verified' "$manifest_path")

  if [ "$manifest_org" != "$requested_org" ] || [ "$manifest_env" != "$requested_env" ]; then
    echo "❌ MANIFEST MISMATCH!"
    echo "   Requested: $requested_org/$requested_env"
    echo "   Manifest:  $manifest_org/$manifest_env"
    return 1
  fi

  if [ "$manifest_verified" != "true" ]; then
    echo "❌ Error: Build was not verified"
    return 1
  fi

  echo "✅ Manifest verified"
  return 0
}

# Check build age and warn if stale
check_build_age() {
  local manifest_path="$1"
  local max_age_hours=${2:-24}

  if [ ! -f "$manifest_path" ]; then
    return 1
  fi

  local build_timestamp=$(jq -r '.timestamp' "$manifest_path")
  local build_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$build_timestamp" "+%s" 2>/dev/null || echo "0")
  local now_epoch=$(date "+%s")
  local age_hours=$(( (now_epoch - build_epoch) / 3600 ))

  if [ $age_hours -gt $max_age_hours ]; then
    echo "⚠️  Warning: Build is $age_hours hours old (threshold: $max_age_hours hours)"
    return 1
  fi

  return 0
}
