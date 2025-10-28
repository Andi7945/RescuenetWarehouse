#!/bin/bash
# Verification library for safe deployments
# Provides pure functions for Firebase project ID extraction and validation

# Extract all Firebase project IDs from compiled JavaScript bundle
# Pure function: input (file path) -> output (list of project IDs, one per line)
extract_all_project_ids_from_bundle() {
  local bundle_path="$1"
  # Extract all projectIds from Firebase configs in JavaScript
  # Pattern: Firebase configs appear as: "project-id","project-id.firebaseapp.com"
  # Multi-tenant apps may contain multiple Firebase configs
  grep -oE '"[a-z0-9-]+","[a-z0-9-]+\.firebaseapp\.com"' "$bundle_path" | \
    grep -oE '^"[a-z0-9-]+"' | \
    tr -d '"' | \
    sort -u
}

# Check if specific project ID exists in bundle
# Pure function: input (file path, project ID) -> output (0=found, 1=not found)
check_project_id_in_bundle() {
  local bundle_path="$1"
  local expected_id="$2"

  extract_all_project_ids_from_bundle "$bundle_path" | grep -q "^${expected_id}$"
  return $?
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
# Note: Multi-tenant apps may contain multiple Firebase configs.
# This verifies the expected project ID exists in the bundle.
verify_bundle_project_id() {
  local bundle_path="$1"
  local expected_id="$2"

  # Get all project IDs from bundle
  local all_ids=$(extract_all_project_ids_from_bundle "$bundle_path")

  if [ -z "$all_ids" ]; then
    echo "❌ Error: Could not extract any project IDs from bundle"
    echo "   Bundle may be corrupted or missing Firebase configuration"
    return 1
  fi

  # Check if expected ID exists in bundle
  if ! check_project_id_in_bundle "$bundle_path" "$expected_id"; then
    echo "❌ PROJECT ID NOT FOUND!"
    echo "   Expected: $expected_id"
    echo "   Found in bundle:"
    echo "$all_ids" | sed 's/^/     - /'
    echo ""
    echo "   The build does not contain the Firebase config for $expected_id"
    return 1
  fi

  # Show all IDs found (informational for multi-tenant apps)
  local id_count=$(echo "$all_ids" | wc -l | tr -d ' ')
  if [ "$id_count" -gt 1 ]; then
    echo "✅ Project ID verified: $expected_id (multi-tenant build with $id_count configs)"
  else
    echo "✅ Project ID verified: $expected_id"
  fi

  return 0
}

# Verify bundle contains ONLY the expected project ID (single-config enforcement)
# Returns: 0 (success) or 1 (failure)
# Note: This is STRICTER than verify_bundle_project_id() which allows multiple configs.
# Single-config builds should only contain ONE Firebase configuration for security and clarity.
# This function enforces that exactly one config exists and it matches the expected ID.
verify_bundle_single_config() {
  local bundle_path="$1"
  local expected_id="$2"

  # Get all project IDs from bundle (reusing existing helper)
  local all_ids=$(extract_all_project_ids_from_bundle "$bundle_path")

  if [ -z "$all_ids" ]; then
    echo "❌ Error: Could not extract any project IDs from bundle"
    echo "   Bundle may be corrupted or missing Firebase configuration"
    return 1
  fi

  # Count how many configs exist
  local id_count=$(echo "$all_ids" | wc -l | tr -d ' ')

  # Check if expected ID exists in bundle (reusing existing helper)
  if ! check_project_id_in_bundle "$bundle_path" "$expected_id"; then
    echo "❌ EXPECTED PROJECT ID NOT FOUND!"
    echo "   Expected: $expected_id"
    echo "   Found in bundle ($id_count config(s)):"
    echo "$all_ids" | sed 's/^/     - /'
    echo ""
    echo "   The build does not contain the Firebase config for $expected_id"
    return 1
  fi

  # Strict check: verify ONLY one config exists
  if [ "$id_count" -ne 1 ]; then
    echo "❌ MULTIPLE FIREBASE CONFIGS DETECTED!"
    echo "   Expected: Single config for $expected_id"
    echo "   Found: $id_count configs in bundle:"
    echo "$all_ids" | sed 's/^/     - /'
    echo ""
    echo "   ⚠️  SECURITY RISK: Bundle contains configs for multiple Firebase projects"
    echo "   This may expose credentials or data access to unintended environments"
    echo "   Single-config builds should contain EXACTLY ONE Firebase configuration"
    return 1
  fi

  # Success: single config matches expected ID
  echo "✅ Single-config verified: $expected_id (exactly 1 config in bundle)"
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
