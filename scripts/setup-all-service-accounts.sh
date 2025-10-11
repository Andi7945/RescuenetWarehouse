#!/bin/bash
#
# Setup Service Accounts for All Firebase Projects
#
# This is a convenience script that sets up service accounts for both
# testing and production environments.
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup All Service Accounts${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "This will create service accounts for:"
echo "  1. rescuenet-testing"
echo "  2. rescuenet-7733b (production)"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled"
  exit 0
fi
echo ""

# Change to script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

# Setup testing environment
echo -e "${GREEN}=== Testing Environment ===${NC}"
./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
echo ""
echo ""

# Setup production environment
echo -e "${GREEN}=== Production Environment ===${NC}"
./setup-service-accounts.sh rescuenet-7733b rescuenet-production.json
echo ""
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All Service Accounts Created!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "You can now run exports:"
echo ""
echo "  # Test with staging"
echo "  npm run export -- --project=rescuenet-testing --bucket=YOUR_BUCKET --dry-run"
echo ""
echo "  # Production export"
echo "  npm run export -- --project=rescuenet-7733b --bucket=YOUR_BUCKET --dry-run"
echo ""
