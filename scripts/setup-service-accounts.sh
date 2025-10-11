#!/bin/bash
#
# Setup Service Accounts for Firebase Export Tool
#
# This script creates read-only service accounts for exporting Firebase data.
# It grants minimal permissions: read from Firestore/Storage, write to GCS backup bucket.
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Owner or Editor role on the target Firebase projects
#
# Usage:
#   ./setup-service-accounts.sh <project-id> <key-filename>
#
# Example:
#   ./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
#   ./setup-service-accounts.sh rescuenet-7733b rescuenet-production.json
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_ACCOUNT_NAME="firebase-export-tool"
DISPLAY_NAME="Firebase Export Tool"
DESCRIPTION="Read-only service account for Firebase data export tool"

# Required roles for export functionality
ROLES=(
  "roles/datastore.user"        # Read Firestore collections
  "roles/storage.objectViewer"  # Read Firebase Storage files
  "roles/storage.objectCreator" # Write to GCS backup bucket
)

# =============================================================================
# Functions
# =============================================================================

print_usage() {
  echo "Usage: $0 <project-id> <key-filename>"
  echo ""
  echo "Examples:"
  echo "  $0 rescuenet-testing rescuenet-testing.json"
  echo "  $0 rescuenet-7733b rescuenet-production.json"
  echo ""
  echo "The key file will be created in: scripts/secrets/<key-filename>"
}

print_header() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}→${NC} $1"
}

check_prerequisites() {
  print_header "Checking Prerequisites"

  # Check if gcloud is installed
  if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed"
    echo ""
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
  fi
  print_success "gcloud CLI installed"

  # Check if authenticated
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    print_error "Not authenticated with gcloud"
    echo ""
    echo "Run: gcloud auth login"
    exit 1
  fi
  print_success "gcloud authenticated"

  # Check if secrets directory exists
  if [ ! -d "secrets" ]; then
    print_info "Creating secrets directory"
    mkdir -p secrets
  fi
  print_success "secrets directory exists"

  echo ""
}

create_service_account() {
  local project_id=$1
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"

  print_header "Creating Service Account"
  print_info "Project: ${project_id}"
  print_info "Service Account: ${service_account_email}"
  echo ""

  # Set active project
  print_info "Setting active project..."
  gcloud config set project "${project_id}" --quiet
  print_success "Active project: ${project_id}"

  # Check if service account already exists
  if gcloud iam service-accounts describe "${service_account_email}" &> /dev/null; then
    print_warning "Service account already exists: ${service_account_email}"
    read -p "Do you want to continue and update permissions? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Skipping service account creation"
      return 0
    fi
  else
    # Create service account
    print_info "Creating service account..."
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
      --display-name="${DISPLAY_NAME}" \
      --description="${DESCRIPTION}" \
      --quiet
    print_success "Service account created"
  fi

  echo ""
}

grant_permissions() {
  local project_id=$1
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"

  print_header "Granting Permissions"

  for role in "${ROLES[@]}"; do
    print_info "Granting ${role}..."

    gcloud projects add-iam-policy-binding "${project_id}" \
      --member="serviceAccount:${service_account_email}" \
      --role="${role}" \
      --condition=None \
      --quiet > /dev/null

    print_success "${role}"
  done

  echo ""
}

create_key() {
  local project_id=$1
  local key_filename=$2
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"
  local key_path="secrets/${key_filename}"

  print_header "Creating Service Account Key"

  # Check if key file already exists
  if [ -f "${key_path}" ]; then
    print_warning "Key file already exists: ${key_path}"
    read -p "Do you want to overwrite it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Skipping key creation"
      echo ""
      return 0
    fi
    rm "${key_path}"
  fi

  # Create key
  print_info "Creating JSON key..."
  gcloud iam service-accounts keys create "${key_path}" \
    --iam-account="${service_account_email}" \
    --quiet

  print_success "Key created: ${key_path}"

  # Set restrictive permissions on key file
  chmod 600 "${key_path}"
  print_success "Key file permissions set to 600 (owner read/write only)"

  echo ""
}

print_summary() {
  local project_id=$1
  local key_filename=$2
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"
  local key_path="secrets/${key_filename}"

  print_header "Setup Complete"

  echo "Service Account: ${service_account_email}"
  echo "Key File: ${key_path}"
  echo ""
  echo "Granted Permissions:"
  for role in "${ROLES[@]}"; do
    echo "  - ${role}"
  done
  echo ""

  print_success "Service account is ready to use!"
  echo ""
  echo "Test it with:"
  echo "  cd .."
  echo "  npm run export -- --project=${project_id} --bucket=YOUR_BUCKET --dry-run"
  echo ""
}

# =============================================================================
# Main Script
# =============================================================================

main() {
  # Parse arguments
  if [ $# -ne 2 ]; then
    print_error "Invalid number of arguments"
    echo ""
    print_usage
    exit 1
  fi

  local project_id=$1
  local key_filename=$2

  # Validate arguments
  if [ -z "${project_id}" ]; then
    print_error "Project ID cannot be empty"
    exit 1
  fi

  if [ -z "${key_filename}" ]; then
    print_error "Key filename cannot be empty"
    exit 1
  fi

  # Run setup steps
  check_prerequisites
  create_service_account "${project_id}"
  grant_permissions "${project_id}"
  create_key "${project_id}" "${key_filename}"
  print_summary "${project_id}" "${key_filename}"
}

# Change to scripts directory if not already there
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

# Run main function
main "$@"
