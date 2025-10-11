#!/bin/bash
#
# Setup GCS Bucket for Firebase Export Tool
#
# This script creates a Google Cloud Storage bucket for storing Firebase backups.
# It grants the firebase-export-tool service account appropriate permissions.
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Owner or Editor role on the target Firebase project
# - Service account already created (run setup-service-accounts.sh first)
#
# Usage:
#   ./setup-gcs-bucket.sh <project-id> <bucket-name> [region]
#
# Example:
#   ./setup-gcs-bucket.sh rescuenet-testing rescuenet-testing-backups
#   ./setup-gcs-bucket.sh rescuenet-7733b rescuenet-production-backups europe-west1
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
DEFAULT_REGION="europe-west1"
STORAGE_CLASS="STANDARD"

# =============================================================================
# Functions
# =============================================================================

print_usage() {
  echo "Usage: $0 <project-id> <bucket-name> [region]"
  echo ""
  echo "Arguments:"
  echo "  project-id   Firebase project ID (e.g., rescuenet-testing)"
  echo "  bucket-name  GCS bucket name (e.g., rescuenet-testing-backups)"
  echo "  region       Optional, defaults to europe-west1"
  echo ""
  echo "Examples:"
  echo "  $0 rescuenet-testing rescuenet-testing-backups"
  echo "  $0 rescuenet-7733b rescuenet-production-backups europe-west1"
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

  echo ""
}

check_service_account() {
  local project_id=$1
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"

  print_header "Verifying Service Account"
  print_info "Service Account: ${service_account_email}"
  echo ""

  # Set active project
  print_info "Setting active project..."
  gcloud config set project "${project_id}" --quiet
  print_success "Active project: ${project_id}"

  # Check if service account exists
  if ! gcloud iam service-accounts describe "${service_account_email}" &> /dev/null; then
    print_error "Service account does not exist: ${service_account_email}"
    echo ""
    echo "Create it first by running:"
    echo "  ./setup-service-accounts.sh ${project_id} ${project_id}.json"
    exit 1
  fi
  print_success "Service account exists"

  echo ""
}

create_bucket() {
  local project_id=$1
  local bucket_name=$2
  local region=$3

  print_header "Creating GCS Bucket"
  print_info "Project: ${project_id}"
  print_info "Bucket: gs://${bucket_name}"
  print_info "Region: ${region}"
  print_info "Storage Class: ${STORAGE_CLASS}"
  echo ""

  # Check if bucket already exists
  if gcloud storage buckets describe "gs://${bucket_name}" --project="${project_id}" &> /dev/null; then
    print_warning "Bucket already exists: gs://${bucket_name}"
    print_info "Skipping bucket creation"
    echo ""
    return 0
  fi

  # Create bucket using gcloud storage (modern replacement for gsutil)
  print_info "Creating bucket..."
  gcloud storage buckets create "gs://${bucket_name}" \
    --project="${project_id}" \
    --location="${region}" \
    --default-storage-class="${STORAGE_CLASS}"

  print_success "Bucket created: gs://${bucket_name}"

  echo ""
}

grant_bucket_permissions() {
  local project_id=$1
  local bucket_name=$2
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"

  print_header "Granting Bucket Permissions"
  print_info "Granting Storage Object Admin role to service account..."
  echo ""

  # Grant Storage Object Admin role on the bucket
  # This allows the service account to create, read, update, and delete objects
  gcloud storage buckets add-iam-policy-binding "gs://${bucket_name}" \
    --member="serviceAccount:${service_account_email}" \
    --role="roles/storage.objectAdmin" \
    --quiet

  print_success "Storage Object Admin role granted"

  echo ""
}

verify_bucket_access() {
  local bucket_name=$1

  print_header "Verifying Bucket Access"

  # Try to describe bucket (this verifies we can access it)
  print_info "Testing bucket access..."
  if gcloud storage buckets describe "gs://${bucket_name}" &> /dev/null; then
    print_success "Bucket is accessible"
  else
    print_error "Failed to access bucket"
    exit 1
  fi

  # Get bucket details
  print_info "Bucket details:"
  gcloud storage buckets describe "gs://${bucket_name}" --format="table(location,storageClass,timeCreated)" 2>/dev/null || true

  echo ""
}

print_summary() {
  local project_id=$1
  local bucket_name=$2
  local region=$3
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${project_id}.iam.gserviceaccount.com"

  print_header "Setup Complete"

  echo "Project: ${project_id}"
  echo "Bucket: gs://${bucket_name}"
  echo "Region: ${region}"
  echo "Service Account: ${service_account_email}"
  echo "Permissions: roles/storage.objectAdmin"
  echo ""

  print_success "GCS bucket is ready to use!"
  echo ""
  echo "Test it with:"
  echo "  cd .."
  echo "  npm run export -- --project=${project_id} --bucket=${bucket_name} --dry-run"
  echo ""
}

# =============================================================================
# Main Script
# =============================================================================

main() {
  # Parse arguments
  if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    print_error "Invalid number of arguments"
    echo ""
    print_usage
    exit 1
  fi

  local project_id=$1
  local bucket_name=$2
  local region=${3:-$DEFAULT_REGION}

  # Validate arguments
  if [ -z "${project_id}" ]; then
    print_error "Project ID cannot be empty"
    exit 1
  fi

  if [ -z "${bucket_name}" ]; then
    print_error "Bucket name cannot be empty"
    exit 1
  fi

  # Validate bucket name format
  # GCS bucket names must be lowercase, 3-63 chars, alphanumeric or dashes
  if ! [[ "${bucket_name}" =~ ^[a-z0-9][a-z0-9_-]{1,61}[a-z0-9]$ ]]; then
    print_error "Invalid bucket name: ${bucket_name}"
    echo ""
    echo "Bucket names must:"
    echo "  - Be 3-63 characters long"
    echo "  - Contain only lowercase letters, numbers, dashes, and underscores"
    echo "  - Start and end with a letter or number"
    exit 1
  fi

  # Run setup steps
  check_prerequisites
  check_service_account "${project_id}"
  create_bucket "${project_id}" "${bucket_name}" "${region}"
  grant_bucket_permissions "${project_id}" "${bucket_name}"
  verify_bucket_access "${bucket_name}"
  print_summary "${project_id}" "${bucket_name}" "${region}"
}

# Change to scripts directory if not already there
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

# Run main function
main "$@"
