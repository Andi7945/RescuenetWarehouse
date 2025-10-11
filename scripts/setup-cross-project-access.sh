#!/bin/bash
#
# Setup Cross-Project GCS Bucket Access
#
# Grants a service account from one Firebase project access to a GCS bucket
# in another Firebase project. Required for cross-project data migration.
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Owner or Editor role on the project containing the bucket
# - Service accounts already created in both projects
#
# Usage:
#   ./setup-cross-project-access.sh <bucket-name> <source-project-id> <access-level>
#
# Example:
#   ./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin
#   ./setup-cross-project-access.sh rescuenet-testing-backups rescuenet-testing viewer
#
# Access Levels:
#   admin   - Full read/write access (roles/storage.objectAdmin)
#   creator - Create and read access (roles/storage.objectCreator)
#   viewer  - Read-only access (roles/storage.objectViewer)
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

# =============================================================================
# Functions
# =============================================================================

print_usage() {
  echo "Usage: $0 <bucket-name> <source-project-id> <access-level>"
  echo ""
  echo "Arguments:"
  echo "  bucket-name       GCS bucket name (e.g., rescuenet-migrations)"
  echo "  source-project-id Project ID of service account to grant access (e.g., rescuenet-7733b)"
  echo "  access-level      Access level: admin, creator, or viewer"
  echo ""
  echo "Access Levels:"
  echo "  admin   - Full read/write/delete access (roles/storage.objectAdmin)"
  echo "  creator - Create and read access (roles/storage.objectCreator)"
  echo "  viewer  - Read-only access (roles/storage.objectViewer)"
  echo ""
  echo "Examples:"
  echo "  # Allow production to write to testing's migration bucket"
  echo "  $0 rescuenet-migrations rescuenet-7733b admin"
  echo ""
  echo "  # Allow testing to read from production's backup bucket"
  echo "  $0 rescuenet-production-backups rescuenet-testing viewer"
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

# Pure function: Maps access level to IAM role
get_role_for_access_level() {
  local access_level=$1

  case "${access_level}" in
    admin)
      echo "roles/storage.objectAdmin"
      ;;
    creator)
      echo "roles/storage.objectCreator"
      ;;
    viewer)
      echo "roles/storage.objectViewer"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Pure function: Gets description for access level
get_access_description() {
  local access_level=$1

  case "${access_level}" in
    admin)
      echo "Full read/write/delete access"
      ;;
    creator)
      echo "Create and read access"
      ;;
    viewer)
      echo "Read-only access"
      ;;
    *)
      echo "Unknown"
      ;;
  esac
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

verify_bucket_exists() {
  local bucket_name=$1

  print_header "Verifying Bucket"
  print_info "Bucket: gs://${bucket_name}"

  # Check if bucket exists
  if ! gcloud storage buckets describe "gs://${bucket_name}" &> /dev/null; then
    print_error "Bucket does not exist: gs://${bucket_name}"
    echo ""
    echo "Create it first by running:"
    echo "  ./setup-gcs-bucket.sh <project-id> ${bucket_name}"
    exit 1
  fi

  print_success "Bucket exists"

  # Get bucket project
  local bucket_project=$(gcloud storage buckets describe "gs://${bucket_name}" \
    --format="value(metadata.projectNumber)" 2>/dev/null || echo "unknown")

  print_info "Bucket project: ${bucket_project}"
  echo ""
}

verify_service_account() {
  local source_project_id=$1
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"

  print_header "Verifying Service Account"
  print_info "Service account: ${service_account_email}"

  # Check if service account exists
  if ! gcloud iam service-accounts describe "${service_account_email}" \
    --project="${source_project_id}" &> /dev/null; then
    print_error "Service account does not exist: ${service_account_email}"
    echo ""
    echo "Create it first by running:"
    echo "  ./setup-service-accounts.sh ${source_project_id} ${source_project_id}.json"
    exit 1
  fi

  print_success "Service account exists"
  echo ""
}

grant_bucket_access() {
  local bucket_name=$1
  local source_project_id=$2
  local access_level=$3
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"

  # Get IAM role for access level
  local role=$(get_role_for_access_level "${access_level}")
  local description=$(get_access_description "${access_level}")

  print_header "Granting Access"
  print_info "Bucket: gs://${bucket_name}"
  print_info "Service Account: ${service_account_email}"
  print_info "Access Level: ${access_level} (${description})"
  print_info "IAM Role: ${role}"
  echo ""

  # Grant access
  print_info "Granting permissions..."
  gcloud storage buckets add-iam-policy-binding "gs://${bucket_name}" \
    --member="serviceAccount:${service_account_email}" \
    --role="${role}" \
    --quiet

  print_success "Permissions granted"
  echo ""
}

verify_access() {
  local bucket_name=$1
  local source_project_id=$2
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"

  print_header "Verifying Access"

  # Get bucket IAM policy
  print_info "Checking IAM policy..."
  local has_access=$(gcloud storage buckets get-iam-policy "gs://${bucket_name}" \
    --format="value(bindings.members)" 2>/dev/null | \
    grep -c "serviceAccount:${service_account_email}" || echo "0")

  if [ "${has_access}" -gt 0 ]; then
    print_success "Service account has access to bucket"
  else
    print_warning "Could not verify access (may take a few seconds to propagate)"
  fi

  echo ""
}

print_summary() {
  local bucket_name=$1
  local source_project_id=$2
  local access_level=$3
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"
  local description=$(get_access_description "${access_level}")

  print_header "Setup Complete"

  echo "Bucket: gs://${bucket_name}"
  echo "Service Account: ${service_account_email}"
  echo "Access Level: ${access_level} (${description})"
  echo ""

  print_success "Cross-project access configured!"
  echo ""

  # Provide usage examples based on access level
  case "${access_level}" in
    admin|creator)
      echo "You can now export to this bucket:"
      echo "  cd .."
      echo "  npm run export -- \\"
      echo "    --project ${source_project_id} \\"
      echo "    --bucket ${bucket_name}"
      echo ""
      ;;
    viewer)
      echo "You can now import from this bucket:"
      echo "  cd .."
      echo "  npm run import -- \\"
      echo "    --source gs://${bucket_name}/exports/path/manifest.json \\"
      echo "    --project ${source_project_id}"
      echo ""
      ;;
  esac
}

# =============================================================================
# Main Script
# =============================================================================

main() {
  # Parse arguments
  if [ $# -ne 3 ]; then
    print_error "Invalid number of arguments"
    echo ""
    print_usage
    exit 1
  fi

  local bucket_name=$1
  local source_project_id=$2
  local access_level=$3

  # Validate arguments
  if [ -z "${bucket_name}" ]; then
    print_error "Bucket name cannot be empty"
    exit 1
  fi

  if [ -z "${source_project_id}" ]; then
    print_error "Source project ID cannot be empty"
    exit 1
  fi

  # Validate access level
  local role=$(get_role_for_access_level "${access_level}")
  if [ -z "${role}" ]; then
    print_error "Invalid access level: ${access_level}"
    echo ""
    echo "Valid access levels: admin, creator, viewer"
    exit 1
  fi

  # Run setup steps
  check_prerequisites
  verify_bucket_exists "${bucket_name}"
  verify_service_account "${source_project_id}"
  grant_bucket_access "${bucket_name}" "${source_project_id}" "${access_level}"
  verify_access "${bucket_name}" "${source_project_id}"
  print_summary "${bucket_name}" "${source_project_id}" "${access_level}"
}

# Change to scripts directory if not already there
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

# Run main function
main "$@"
