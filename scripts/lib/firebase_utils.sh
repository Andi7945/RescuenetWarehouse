#!/bin/bash
# Firebase Setup Utility Functions
# Shared functions for Firebase automation scripts

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
MANUAL_STEPS=""
ALL_CHECKS_PASSED=true

# Output functions
info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
  echo -e "${GREEN}✅ $1${NC}"
}

warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
  echo -e "${RED}❌ $1${NC}"
  ALL_CHECKS_PASSED=false
}

section() {
  echo ""
  echo "========================================"
  echo "  $1"
  echo "========================================"
  echo ""
}

# Add manual step to tracking
add_manual_step() {
  MANUAL_STEPS="${MANUAL_STEPS}\n- $1"
}

# Check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Check if Firebase CLI is authenticated
check_firebase_auth() {
  firebase projects:list &> /dev/null
  return $?
}

# Check if gcloud is authenticated
check_gcloud_auth() {
  gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q "@"
  return $?
}

# Get Firebase API key for project
get_firebase_api_key() {
  local project_id=$1

  # Try to get from firebase config
  local api_key=$(firebase apps:sdkconfig --project=$project_id 2>/dev/null | grep "apiKey" | awk -F'"' '{print $4}')

  if [ -z "$api_key" ]; then
    # Try alternative method using gcloud
    api_key=$(gcloud alpha firebase apps:list --project=$project_id --format="json" 2>/dev/null | jq -r '.[0].apiKeyId' 2>/dev/null)
  fi

  echo "$api_key"
}

# Get access token for API calls
get_access_token() {
  gcloud auth print-access-token 2>/dev/null
}

# Check if Firestore database exists
check_firestore_exists() {
  local project_id=$1

  local count=$(gcloud firestore databases list --project=$project_id 2>/dev/null | grep -c "(default)")

  [ "$count" -gt 0 ]
  return $?
}

# Get Firestore location
get_firestore_location() {
  local project_id=$1

  gcloud firestore databases describe --database="(default)" --project=$project_id --format="value(locationId)" 2>/dev/null
}

# Check if Storage bucket exists
check_storage_exists() {
  local project_id=$1
  local bucket="${project_id}.appspot.com"

  gsutil ls -b "gs://$bucket" &> /dev/null
  return $?
}

# Get Storage bucket location
get_storage_location() {
  local project_id=$1
  local bucket="${project_id}.appspot.com"

  gsutil ls -L -b "gs://$bucket" 2>/dev/null | grep "Location constraint" | awk '{print $3}'
}

# Check if Authentication is enabled
check_auth_enabled() {
  local project_id=$1
  local token=$(get_access_token)

  if [ -z "$token" ]; then
    return 1
  fi

  local response=$(curl -s -H "Authorization: Bearer $token" \
    "https://identitytoolkit.googleapis.com/v1/projects/$project_id/config" 2>/dev/null)

  echo "$response" | jq -e '.signIn' > /dev/null 2>&1
  return $?
}

# Check if Email/Password auth provider is enabled
check_email_provider_enabled() {
  local project_id=$1
  local token=$(get_access_token)

  if [ -z "$token" ]; then
    return 1
  fi

  local enabled=$(curl -s -H "Authorization: Bearer $token" \
    "https://identitytoolkit.googleapis.com/v1/projects/$project_id/config" 2>/dev/null \
    | jq -r '.signIn.email.enabled' 2>/dev/null)

  [ "$enabled" = "true" ]
  return $?
}

# Wait for user confirmation
wait_for_confirmation() {
  local message=${1:-"Press Enter to continue after completing this step"}

  if [ "$NON_INTERACTIVE" = true ]; then
    warning "Non-interactive mode: skipping manual step"
    return 0
  fi

  echo ""
  read -p "$message..."
}

# Open URL in browser (if possible)
open_url() {
  local url=$1

  if command_exists open; then
    # macOS
    open "$url" 2>/dev/null
  elif command_exists xdg-open; then
    # Linux
    xdg-open "$url" 2>/dev/null
  elif command_exists start; then
    # Windows
    start "$url" 2>/dev/null
  fi
}

# Validate region format
validate_region() {
  local region=$1

  # Common Firebase regions
  case "$region" in
    us-central1|us-east1|us-east4|us-west1|us-west2|us-west3|us-west4|\
    europe-west1|europe-west2|europe-west3|europe-west6|europe-central2|\
    asia-east1|asia-east2|asia-northeast1|asia-northeast2|asia-northeast3|\
    asia-south1|asia-southeast1|asia-southeast2|\
    australia-southeast1|southamerica-east1)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Create default Firestore rules
create_default_firestore_rules() {
  local output_file=${1:-"firestore.rules"}

  cat > "$output_file" << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Default: Authenticated users can read/write all documents
    // ⚠️ CUSTOMIZE THIS FOR YOUR APP'S DATA MODEL!
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
EOF
}

# Create default Storage rules
create_default_storage_rules() {
  local output_file=${1:-"storage.rules"}

  cat > "$output_file" << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Default: Authenticated users can read/write
    // ⚠️ CUSTOMIZE THIS FOR YOUR APP'S SECURITY REQUIREMENTS!
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
EOF
}

# Create default indexes file
create_default_indexes() {
  local output_file=${1:-"firestore.indexes.json"}

  cat > "$output_file" << 'EOF'
{
  "indexes": [],
  "fieldOverrides": []
}
EOF
}

# Create CORS configuration for Storage
create_cors_config() {
  local output_file=${1:-"/tmp/cors.json"}
  local production=${2:-false}

  if [ "$production" = true ]; then
    # More restrictive CORS for production
    cat > "$output_file" << 'EOF'
[
  {
    "origin": ["https://*.web.app", "https://*.firebaseapp.com"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"],
    "maxAgeSeconds": 3600
  }
]
EOF
  else
    # Permissive CORS for staging
    cat > "$output_file" << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"],
    "maxAgeSeconds": 3600
  }
]
EOF
  fi
}

# Check if running in dry-run mode
is_dry_run() {
  [ "$DRY_RUN" = true ]
}

# Execute command (or show in dry-run mode)
execute_or_show() {
  local description=$1
  shift
  local command="$@"

  if is_dry_run; then
    info "[DRY RUN] Would execute: $command"
    return 0
  else
    if [ "$VERBOSE" = true ]; then
      info "Executing: $command"
    fi
    eval "$command"
    return $?
  fi
}

# Print separator line
print_separator() {
  echo "----------------------------------------"
}
