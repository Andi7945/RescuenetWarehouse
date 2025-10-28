#!/bin/bash
# ============================================================================
# Generate org_registry.dart with only the needed Firebase configuration
# ============================================================================
# This script is a pure function: (org, env, template) → generated file
#
# Usage:
#   generate_org_registry.sh <org> <env> <template_path> <output_path>
#
# Arguments:
#   org           - Organization ID (rescuenet, humedica)
#   env           - Environment (staging, production)
#   template_path - Path to org_registry.dart.template
#   output_path   - Path to write generated file
#
# Example:
#   ./generate_org_registry.sh rescuenet staging lib/config/org_registry.dart.template lib/config/org_registry.dart
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
  echo -e "${RED}ERROR: $1${NC}" >&2
  exit 1
}

# Function to print success messages
success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# Function to print warning messages
warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

# Main generation function
generate_org_registry() {
  local org="$1"
  local env="$2"
  local template_path="$3"
  local output_path="$4"

  # Validate inputs
  if [[ -z "$org" ]]; then
    error "Organization ID is required (arg 1)"
  fi

  if [[ -z "$env" ]]; then
    error "Environment is required (arg 2)"
  fi

  if [[ -z "$template_path" ]]; then
    error "Template path is required (arg 3)"
  fi

  if [[ -z "$output_path" ]]; then
    error "Output path is required (arg 4)"
  fi

  # Validate environment
  if [[ "$env" != "staging" && "$env" != "production" ]]; then
    error "Environment must be 'staging' or 'production', got: $env"
  fi

  # Check template exists
  if [[ ! -f "$template_path" ]]; then
    error "Template file not found: $template_path"
  fi

  # Generate imports and config based on org and env
  local firebase_import=""
  local org_config=""

  case "$org" in
    rescuenet)
      case "$env" in
        staging)
          firebase_import="import 'firebase_options_rescuenet_testing.dart' as rescuenet_staging;"
          org_config="  'rescuenet': OrgConfig(
    id: 'rescuenet',
    name: 'RescueNet',
    smallLogoAssetPath: 'assets/images/LogoRN.png',
    largeLogoAssetPath: 'assets/images/rn_logo_big.png',
    productionFirebase:
        rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
    stagingFirebase:
        rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
    features: {},
    allowedEmailDomains: ['rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
  ),"
          ;;
        production)
          firebase_import="import 'firebase_options_rescuenet_production.dart' as rescuenet_prod;"
          org_config="  'rescuenet': OrgConfig(
    id: 'rescuenet',
    name: 'RescueNet',
    smallLogoAssetPath: 'assets/images/LogoRN.png',
    largeLogoAssetPath: 'assets/images/rn_logo_big.png',
    productionFirebase:
        rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
    stagingFirebase:
        rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
    features: {},
    allowedEmailDomains: ['rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
  ),"
          ;;
      esac
      ;;

    humedica)
      case "$env" in
        staging|production)
          firebase_import="import 'firebase_options_humedica_prod.dart' as humedica_prod;"
          org_config="  'humedica': OrgConfig(
    id: 'humedica',
    name: 'Humedica',
    smallLogoAssetPath: 'assets/images/humedica_logo_small.png',
    largeLogoAssetPath: 'assets/images/humedica_logo_big.png',
    productionFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
    stagingFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
    features: {},
    allowedEmailDomains: ['humedica.org', 'rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
  ),"
          ;;
      esac
      ;;

    *)
      error "Unknown organization: $org. Supported: rescuenet, humedica"
      ;;
  esac

  # Generate the file by replacing placeholders
  success "Generating org_registry.dart for $org ($env)..."

  # Read template and replace placeholders
  sed -e "s|// FIREBASE_IMPORTS_PLACEHOLDER|$firebase_import|g" \
      -e "/\/\/ ORG_CONFIG_PLACEHOLDER/r /dev/stdin" \
      -e "/\/\/ ORG_CONFIG_PLACEHOLDER/d" \
      "$template_path" > "$output_path" <<EOF
$org_config
EOF

  # Verify the output was created
  if [[ ! -f "$output_path" ]]; then
    error "Failed to generate output file: $output_path"
  fi

  # Verify it contains the expected imports
  if ! grep -q "$firebase_import" "$output_path"; then
    error "Generated file does not contain expected Firebase import"
  fi

  success "Successfully generated: $output_path"
  echo "  Organization: $org"
  echo "  Environment:  $env"
  echo "  Firebase:     $(echo "$firebase_import" | sed 's/import //' | sed "s/';//" | sed 's/ as.*//')"
}

# Run the function with provided arguments
generate_org_registry "$1" "$2" "$3" "$4"
