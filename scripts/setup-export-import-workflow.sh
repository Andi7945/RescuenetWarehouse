#!/bin/bash
#
# Setup Complete Export/Import Workflow
#
# This script orchestrates the complete setup for cross-project data migration:
# 1. Creates service accounts in both production and testing projects
# 2. Creates intermediate GCS bucket for data transfer
# 3. Grants cross-project access permissions
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Owner or Editor role on both Firebase projects
#
# Usage:
#   ./setup-export-import-workflow.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PRODUCTION_PROJECT="rescuenet-7733b"
TESTING_PROJECT="rescuenet-testing"
MIGRATION_BUCKET="rescuenet-testing-migrations"

# =============================================================================
# Functions
# =============================================================================

print_header() {
  echo ""
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""
}

print_step() {
  echo -e "${CYAN}>>> $1${NC}"
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
  echo ""
  echo -e "${BLUE}$1${NC}"
  echo ""
}

# =============================================================================
# Main Script
# =============================================================================

# Change to script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

# Print welcome message
print_header "Export/Import Workflow Setup"

echo "This script will set up the complete infrastructure for cross-project"
echo "data migration between production and testing environments:"
echo ""
echo "  Production:  ${PRODUCTION_PROJECT}"
echo "  Testing:     ${TESTING_PROJECT}"
echo "  Migration:   gs://${MIGRATION_BUCKET}"
echo ""
echo "Steps:"
echo "  1. Create service accounts (both projects)"
echo "  2. Create intermediate GCS bucket"
echo "  3. Grant cross-project permissions"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled"
  exit 0
fi

# =============================================================================
# Step 1: Setup Service Accounts
# =============================================================================

print_header "Step 1: Setup Service Accounts"

print_step "Creating service accounts for both projects..."
echo ""

if [ -f "./setup-all-service-accounts.sh" ]; then
  ./setup-all-service-accounts.sh
else
  print_warning "setup-all-service-accounts.sh not found, setting up individually..."

  # Setup testing
  print_info "Setting up testing service account..."
  ./setup-service-accounts.sh "${TESTING_PROJECT}" rescuenet-testing.json

  # Setup production
  print_info "Setting up production service account..."
  ./setup-service-accounts.sh "${PRODUCTION_PROJECT}" rescuenet-production.json
fi

print_success "Service accounts created"

# =============================================================================
# Step 2: Create Intermediate GCS Bucket
# =============================================================================

print_header "Step 2: Create Migration Bucket"

print_step "Creating intermediate bucket: ${MIGRATION_BUCKET}"
echo ""

./setup-gcs-bucket.sh "${TESTING_PROJECT}" "${MIGRATION_BUCKET}"

print_success "Migration bucket ready"

# =============================================================================
# Step 3: Grant Cross-Project Access
# =============================================================================

print_header "Step 3: Grant Cross-Project Access"

print_step "Granting production service account access to migration bucket..."
echo ""

./setup-cross-project-access.sh "${MIGRATION_BUCKET}" "${PRODUCTION_PROJECT}" admin

print_success "Cross-project permissions configured"

# =============================================================================
# Summary
# =============================================================================

print_header "Setup Complete!"

echo -e "${GREEN}✓ Service accounts created:${NC}"
echo "  - firebase-export-tool@${PRODUCTION_PROJECT}.iam.gserviceaccount.com"
echo "  - firebase-export-tool@${TESTING_PROJECT}.iam.gserviceaccount.com"
echo ""

echo -e "${GREEN}✓ Migration bucket created:${NC}"
echo "  - gs://${MIGRATION_BUCKET}"
echo ""

echo -e "${GREEN}✓ Cross-project access granted:${NC}"
echo "  - Production can write to migration bucket"
echo "  - Testing can read from migration bucket"
echo ""

print_info "🚀 You can now perform cross-project data migration!"

echo "Export from production:"
echo -e "${CYAN}  cd ..${NC}"
echo -e "${CYAN}  npm run export -- --project=${PRODUCTION_PROJECT} --bucket=${MIGRATION_BUCKET}${NC}"
echo ""

echo "Import to testing:"
echo -e "${CYAN}  npm run import -- \\${NC}"
echo -e "${CYAN}    --source gs://${MIGRATION_BUCKET}/exports/YYYY-MM-DD-${PRODUCTION_PROJECT}/manifest.json \\${NC}"
echo -e "${CYAN}    --project=${TESTING_PROJECT} \\${NC}"
echo -e "${CYAN}    --execute${NC}"
echo ""

echo "For more details, see:"
echo "  - scripts/README-export.md"
echo "  - scripts/README-import.md"
echo "  - scripts/README-cross-project.md"
echo ""
