#!/bin/bash
# Firebase Project Setup Automation Script
# Automates Firebase project configuration for multi-tenant environments
#
# Usage: ./scripts/setup_firebase_project.sh <project_id> <region> [options]
#
# Example:
#   ./scripts/setup_firebase_project.sh rescuenet-testing europe-west1
#   ./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --copy-from=rescuenet-7733b

set -e  # Exit on error (except in conditional checks)

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$SCRIPT_DIR/lib/firebase_utils.sh"

# Default values
DRY_RUN=false
VERBOSE=false
NON_INTERACTIVE=false
SKIP_TESTS=false
COPY_FROM_PROJECT=""

# Status tracking
AUTH_STATUS="⏳"
FIRESTORE_STATUS="⏳"
STORAGE_STATUS="⏳"
HOSTING_STATUS="⏳"
FIRESTORE_RULES_STATUS="⏳"
STORAGE_RULES_STATUS="⏳"
INDEXES_STATUS="⏳"
CORS_STATUS="⏳"
AUTH_TEST_STATUS="⏳"
FIRESTORE_TEST_STATUS="⏳"
STORAGE_TEST_STATUS="⏳"

# Parse command-line arguments
usage() {
  cat << EOF
Firebase Project Setup Automation

Usage: $0 <project_id> <region> [options]

Arguments:
  project_id    Firebase project ID (e.g., rescuenet-testing)
  region        Firebase region (e.g., europe-west1)

Options:
  --copy-from=<project>   Copy rules and indexes from another project
  --skip-tests           Skip verification tests
  --yes                  Non-interactive mode (auto-confirm prompts)
  --verbose              Show detailed output
  --dry-run              Show what would be done without making changes
  -h, --help             Show this help message

Examples:
  # Basic setup
  $0 rescuenet-testing europe-west1

  # Copy configuration from production
  $0 rescuenet-testing europe-west1 --copy-from=rescuenet-7733b

  # Non-interactive setup
  $0 rescuenet-testing europe-west1 --yes --copy-from=rescuenet-7733b

  # Dry run
  $0 rescuenet-testing europe-west1 --dry-run

EOF
  exit 0
}

# Parse arguments
PROJECT_ID=""
REGION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      ;;
    --copy-from=*)
      COPY_FROM_PROJECT="${1#*=}"
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --yes)
      NON_INTERACTIVE=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      if [ -z "$PROJECT_ID" ]; then
        PROJECT_ID=$1
      elif [ -z "$REGION" ]; then
        REGION=$1
      else
        error "Unknown argument: $1"
        echo ""
        usage
      fi
      shift
      ;;
  esac
done

# Validate required arguments
if [ -z "$PROJECT_ID" ] || [ -z "$REGION" ]; then
  error "Missing required arguments"
  echo ""
  usage
fi

# Validate region format
if ! validate_region "$REGION"; then
  error "Invalid region: $REGION"
  echo ""
  echo "Common regions:"
  echo "  - europe-west1 (Belgium)"
  echo "  - us-central1 (Iowa)"
  echo "  - asia-northeast1 (Tokyo)"
  echo ""
  echo "See: https://firebase.google.com/docs/projects/locations"
  exit 1
fi

# Show header
clear
section "Firebase Project Setup"
echo "Project ID: $PROJECT_ID"
echo "Region:     $REGION"
if [ -n "$COPY_FROM_PROJECT" ]; then
  echo "Copy from:  $COPY_FROM_PROJECT"
fi
if [ "$DRY_RUN" = true ]; then
  warning "DRY RUN MODE - No changes will be made"
fi
echo ""

#############################################
# Phase 1: Prerequisites Check
#############################################
section "Phase 1: Prerequisites Check"

# Check Firebase CLI
if command_exists firebase; then
  FIREBASE_VERSION=$(firebase --version)
  success "Firebase CLI installed ($FIREBASE_VERSION)"
else
  error "Firebase CLI not installed"
  echo ""
  echo "Install: npm install -g firebase-tools"
  exit 1
fi

# Check Firebase authentication
if check_firebase_auth; then
  FIREBASE_USER=$(firebase login:list 2>/dev/null | grep -m1 "@" | awk '{print $1}')
  success "Authenticated with Firebase ($FIREBASE_USER)"
else
  error "Not authenticated with Firebase"
  echo ""
  echo "Run: firebase login"
  exit 1
fi

# Check gcloud CLI
if command_exists gcloud; then
  GCLOUD_VERSION=$(gcloud version --format="value(core.version)" 2>/dev/null)
  success "gcloud CLI installed ($GCLOUD_VERSION)"
  GCLOUD_AVAILABLE=true

  # Check gcloud authentication
  if check_gcloud_auth; then
    GCLOUD_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)
    success "Authenticated with gcloud ($GCLOUD_USER)"
  else
    warning "gcloud not authenticated (some features unavailable)"
    echo "Run: gcloud auth login"
    GCLOUD_AVAILABLE=false
  fi
else
  warning "gcloud CLI not installed (some features unavailable)"
  echo "Install: https://cloud.google.com/sdk/docs/install"
  GCLOUD_AVAILABLE=false
fi

# Check jq
if command_exists jq; then
  success "jq installed"
else
  error "jq not installed (required for JSON parsing)"
  echo ""
  echo "Install:"
  echo "  macOS:  brew install jq"
  echo "  Linux:  apt install jq"
  exit 1
fi

# Check curl
if command_exists curl; then
  success "curl installed"
else
  error "curl not installed"
  exit 1
fi

# Check gsutil (part of gcloud)
if command_exists gsutil; then
  success "gsutil installed"
else
  warning "gsutil not installed (Storage features unavailable)"
  echo "Install with: gcloud components install gsutil"
fi

echo ""
success "Prerequisites check complete!"

#############################################
# Phase 2: Project Validation
#############################################
section "Phase 2: Project Validation"

# Check if project exists
info "Checking if project exists..."
if firebase projects:list 2>/dev/null | grep -q "$PROJECT_ID"; then
  success "Project exists: $PROJECT_ID"
else
  error "Project '$PROJECT_ID' not found"
  echo ""
  echo "Create project at: https://console.firebase.google.com/"
  echo "Or run: firebase projects:create $PROJECT_ID"
  exit 1
fi

# Get project number (if gcloud available)
if [ "$GCLOUD_AVAILABLE" = true ]; then
  PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)" 2>/dev/null || echo "")
  if [ -n "$PROJECT_NUMBER" ]; then
    success "Project number: $PROJECT_NUMBER"
  fi
fi

# Check billing status
if [ "$GCLOUD_AVAILABLE" = true ]; then
  BILLING_ENABLED=$(gcloud beta billing projects describe $PROJECT_ID --format="json" 2>/dev/null | jq -r '.billingEnabled' 2>/dev/null || echo "unknown")
  if [ "$BILLING_ENABLED" = "true" ]; then
    success "Billing enabled"
  elif [ "$BILLING_ENABLED" = "false" ]; then
    warning "Billing not enabled (some features may not work)"
    echo "Enable at: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
  fi
fi

echo ""
success "Project validation complete!"

#############################################
# Phase 3: Service Provisioning
#############################################
section "Phase 3: Service Provisioning"

# 3.1: Check Authentication
info "Checking Firebase Authentication..."
if check_auth_enabled "$PROJECT_ID"; then
  success "Authentication enabled"
  AUTH_STATUS="✅"

  # Check Email/Password provider
  if check_email_provider_enabled "$PROJECT_ID"; then
    success "Email/Password provider enabled"
  else
    warning "Email/Password provider not enabled"
    AUTH_STATUS="⚠️"
    add_manual_step "Enable Email/Password auth provider"
    echo ""
    echo "📋 MANUAL STEP: Enable Email/Password Provider"
    echo ""
    echo "1. Open: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
    echo "2. Click 'Email/Password'"
    echo "3. Toggle 'Enable'"
    echo "4. Click 'Save'"
    wait_for_confirmation
  fi
else
  warning "Authentication not enabled"
  AUTH_STATUS="⚠️"
  add_manual_step "Enable Firebase Authentication"
  echo ""
  echo "📋 MANUAL STEP: Enable Authentication"
  echo ""
  echo "1. Open: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
  echo "2. Click 'Get started'"
  echo "3. Click 'Email/Password' provider"
  echo "4. Toggle 'Enable'"
  echo "5. Click 'Save'"
  wait_for_confirmation
fi

# 3.2: Check Firestore
echo ""
info "Checking Cloud Firestore..."
if check_firestore_exists "$PROJECT_ID"; then
  FIRESTORE_LOCATION=$(get_firestore_location "$PROJECT_ID")
  success "Firestore database exists (location: $FIRESTORE_LOCATION)"
  FIRESTORE_STATUS="✅"

  if [ "$FIRESTORE_LOCATION" != "$REGION" ]; then
    warning "Firestore location ($FIRESTORE_LOCATION) differs from target region ($REGION)"
    echo "   This cannot be changed after creation!"
  fi
else
  warning "Firestore database not created"
  FIRESTORE_STATUS="⚠️"
  add_manual_step "Create Firestore database"

  # Try to create with gcloud
  if [ "$GCLOUD_AVAILABLE" = true ] && [ "$DRY_RUN" = false ]; then
    info "Attempting to create Firestore database..."
    if gcloud firestore databases create --location=$REGION --project=$PROJECT_ID 2>/dev/null; then
      success "Firestore database created in $REGION"
      FIRESTORE_STATUS="✅"
    else
      warning "Could not create Firestore via CLI"
      echo ""
      echo "📋 MANUAL STEP: Create Firestore Database"
      echo ""
      echo "1. Open: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
      echo "2. Click 'Create database'"
      echo "3. Select 'Start in production mode'"
      echo "4. Choose location: $REGION"
      echo "5. Click 'Enable'"
      wait_for_confirmation
    fi
  else
    echo ""
    echo "📋 MANUAL STEP: Create Firestore Database"
    echo ""
    echo "1. Open: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
    echo "2. Click 'Create database'"
    echo "3. Select 'Start in production mode'"
    echo "4. Choose location: $REGION"
    echo "5. Click 'Enable'"
    wait_for_confirmation
  fi
fi

# 3.3: Check Storage
echo ""
info "Checking Cloud Storage..."
DEFAULT_BUCKET="${PROJECT_ID}.appspot.com"
if check_storage_exists "$PROJECT_ID"; then
  STORAGE_LOCATION=$(get_storage_location "$PROJECT_ID")
  success "Storage bucket exists: $DEFAULT_BUCKET"
  if [ -n "$STORAGE_LOCATION" ]; then
    success "Storage location: $STORAGE_LOCATION"
  fi
  STORAGE_STATUS="✅"
else
  warning "Storage bucket not created"
  STORAGE_STATUS="⚠️"
  add_manual_step "Enable Cloud Storage"
  echo ""
  echo "📋 MANUAL STEP: Enable Cloud Storage"
  echo ""
  echo "1. Open: https://console.firebase.google.com/project/$PROJECT_ID/storage"
  echo "2. Click 'Get started'"
  echo "3. Click 'Next' (use default security rules)"
  echo "4. Choose location: $REGION"
  echo "5. Click 'Done'"
  wait_for_confirmation
fi

# 3.4: Check Hosting
echo ""
info "Checking Firebase Hosting..."
HOSTING_SITE=$(firebase hosting:sites:list --project=$PROJECT_ID 2>/dev/null | grep -v "^Site" | head -1 | awk '{print $1}' || echo "")
if [ -n "$HOSTING_SITE" ]; then
  success "Hosting site exists: $HOSTING_SITE"
  HOSTING_STATUS="✅"
else
  info "Hosting will be created on first deployment"
  HOSTING_STATUS="ℹ️"
fi

echo ""
success "Service provisioning check complete!"

#############################################
# Phase 4: Security Configuration
#############################################
section "Phase 4: Security Configuration"

# 4.1: Firestore Rules
info "Checking Firestore security rules..."
if [ -f "firestore.rules" ]; then
  success "Found firestore.rules"

  # Deploy rules
  if [ "$DRY_RUN" = false ]; then
    info "Deploying Firestore rules..."
    if firebase deploy --only firestore:rules --project=$PROJECT_ID 2>&1 | grep -q "Deploy complete"; then
      success "Firestore rules deployed"
      FIRESTORE_RULES_STATUS="✅"
    else
      warning "Failed to deploy Firestore rules"
      FIRESTORE_RULES_STATUS="⚠️"
    fi
  else
    info "[DRY RUN] Would deploy firestore.rules"
    FIRESTORE_RULES_STATUS="🔍"
  fi
else
  warning "No firestore.rules file found"

  # Offer to copy from source project
  if [ -n "$COPY_FROM_PROJECT" ]; then
    info "Copying Firestore rules from $COPY_FROM_PROJECT..."
    if [ "$DRY_RUN" = false ] && [ "$GCLOUD_AVAILABLE" = true ]; then
      # Fetch rules using gcloud
      RULES_CONTENT=$(gcloud firestore databases get-ruleset --project=$COPY_FROM_PROJECT --format=json 2>/dev/null | jq -r '.source.files[0].content' 2>/dev/null || echo "")
      if [ -n "$RULES_CONTENT" ] && [ "$RULES_CONTENT" != "null" ]; then
        echo "$RULES_CONTENT" > firestore.rules
        success "Rules copied from $COPY_FROM_PROJECT"

        # Deploy the copied rules
        info "Deploying copied rules..."
        if firebase deploy --only firestore:rules --project=$PROJECT_ID 2>&1 | grep -q "Deploy complete"; then
          success "Firestore rules deployed"
          FIRESTORE_RULES_STATUS="✅"
        else
          warning "Failed to deploy Firestore rules"
          FIRESTORE_RULES_STATUS="⚠️"
        fi
      else
        warning "Could not fetch rules from $COPY_FROM_PROJECT"
        create_default_firestore_rules
        success "Created default firestore.rules"
        FIRESTORE_RULES_STATUS="⚠️"
      fi
    else
      info "[DRY RUN] Would copy rules from $COPY_FROM_PROJECT"
      FIRESTORE_RULES_STATUS="🔍"
    fi
  else
    # Create default rules
    info "Creating default Firestore rules..."
    if [ "$DRY_RUN" = false ]; then
      create_default_firestore_rules
      success "Created firestore.rules with basic authentication"
      warning "IMPORTANT: Customize these rules for your data model!"
      FIRESTORE_RULES_STATUS="⚠️"
    else
      info "[DRY RUN] Would create default firestore.rules"
      FIRESTORE_RULES_STATUS="🔍"
    fi
  fi
fi

# 4.2: Storage Rules
echo ""
info "Checking Storage security rules..."
if [ -f "storage.rules" ]; then
  success "Found storage.rules"

  # Deploy rules
  if [ "$DRY_RUN" = false ]; then
    info "Deploying Storage rules..."
    if firebase deploy --only storage --project=$PROJECT_ID 2>&1 | grep -q "Deploy complete"; then
      success "Storage rules deployed"
      STORAGE_RULES_STATUS="✅"
    else
      warning "Failed to deploy Storage rules"
      STORAGE_RULES_STATUS="⚠️"
    fi
  else
    info "[DRY RUN] Would deploy storage.rules"
    STORAGE_RULES_STATUS="🔍"
  fi
else
  warning "No storage.rules file found"

  # Offer to copy from source project
  if [ -n "$COPY_FROM_PROJECT" ]; then
    info "Attempting to copy Storage rules from $COPY_FROM_PROJECT..."
    if [ "$DRY_RUN" = false ] && command_exists gsutil; then
      SOURCE_BUCKET="${COPY_FROM_PROJECT}.appspot.com"
      if gsutil cat "gs://$SOURCE_BUCKET/.rules" 2>/dev/null > storage.rules; then
        success "Rules copied from $COPY_FROM_PROJECT"

        # Deploy the copied rules
        info "Deploying copied rules..."
        if firebase deploy --only storage --project=$PROJECT_ID 2>&1 | grep -q "Deploy complete"; then
          success "Storage rules deployed"
          STORAGE_RULES_STATUS="✅"
        else
          warning "Failed to deploy Storage rules"
          STORAGE_RULES_STATUS="⚠️"
        fi
      else
        warning "Could not copy rules from $COPY_FROM_PROJECT"
        create_default_storage_rules
        success "Created default storage.rules"
        STORAGE_RULES_STATUS="⚠️"
      fi
    else
      info "[DRY RUN] Would copy rules from $COPY_FROM_PROJECT"
      STORAGE_RULES_STATUS="🔍"
    fi
  else
    # Create default rules
    info "Creating default Storage rules..."
    if [ "$DRY_RUN" = false ]; then
      create_default_storage_rules
      success "Created storage.rules with basic authentication"
      STORAGE_RULES_STATUS="⚠️"
    else
      info "[DRY RUN] Would create default storage.rules"
      STORAGE_RULES_STATUS="🔍"
    fi
  fi
fi

# 4.3: Firestore Indexes
echo ""
info "Checking Firestore indexes..."
if [ -f "firestore.indexes.json" ]; then
  success "Found firestore.indexes.json"
else
  warning "No firestore.indexes.json file"

  # Copy from source or create default
  if [ -n "$COPY_FROM_PROJECT" ]; then
    info "Copying indexes from $COPY_FROM_PROJECT..."
    if [ "$DRY_RUN" = false ]; then
      firebase firestore:indexes --project=$COPY_FROM_PROJECT 2>/dev/null > firestore.indexes.json || create_default_indexes
      success "Indexes copied from $COPY_FROM_PROJECT"
    else
      info "[DRY RUN] Would copy indexes from $COPY_FROM_PROJECT"
    fi
  else
    if [ "$DRY_RUN" = false ]; then
      create_default_indexes
      success "Created default firestore.indexes.json"
    else
      info "[DRY RUN] Would create default firestore.indexes.json"
    fi
  fi
fi

# Deploy indexes
if [ -f "firestore.indexes.json" ] && [ "$DRY_RUN" = false ]; then
  info "Deploying Firestore indexes..."
  if firebase deploy --only firestore:indexes --project=$PROJECT_ID 2>&1 | grep -q "Deploy complete"; then
    success "Firestore indexes deployed"
    INDEXES_STATUS="✅"
  else
    warning "Failed to deploy indexes (may not be critical)"
    INDEXES_STATUS="⚠️"
  fi
else
  INDEXES_STATUS="🔍"
fi

# 4.4: Storage CORS
echo ""
info "Checking Storage CORS configuration..."
if command_exists gsutil && check_storage_exists "$PROJECT_ID"; then
  CORS_CONFIG=$(gsutil cors get "gs://$DEFAULT_BUCKET" 2>/dev/null || echo "[]")

  if [ -n "$CORS_CONFIG" ] && [ "$CORS_CONFIG" != "[]" ]; then
    success "CORS configured for Storage bucket"
    CORS_STATUS="✅"
  else
    warning "CORS not configured (web uploads may fail)"

    if [ "$DRY_RUN" = false ]; then
      info "Configuring CORS for Storage..."

      # Determine if production (more restrictive CORS)
      IS_PRODUCTION=false
      if [[ "$PROJECT_ID" == *"production"* ]] || [[ "$PROJECT_ID" == *"prod"* ]]; then
        IS_PRODUCTION=true
      fi

      create_cors_config "/tmp/cors.json" "$IS_PRODUCTION"

      if gsutil cors set /tmp/cors.json "gs://$DEFAULT_BUCKET" 2>/dev/null; then
        success "CORS configured"
        CORS_STATUS="✅"

        if [ "$IS_PRODUCTION" = true ]; then
          info "Production project detected: CORS restricted to Firebase domains"
        else
          info "Staging project: CORS allows all origins (*)"
        fi
      else
        warning "Failed to configure CORS"
        CORS_STATUS="⚠️"
      fi

      rm -f /tmp/cors.json
    else
      info "[DRY RUN] Would configure CORS"
      CORS_STATUS="🔍"
    fi
  fi
else
  info "Skipping CORS check (gsutil or Storage not available)"
  CORS_STATUS="⏭️"
fi

echo ""
success "Security configuration complete!"

#############################################
# Phase 5: Verification Tests
#############################################
if [ "$SKIP_TESTS" = false ] && [ "$DRY_RUN" = false ]; then
  section "Phase 5: Verification Tests"

  # 5.1: Test Authentication
  info "Testing Firebase Authentication..."
  if check_auth_enabled "$PROJECT_ID"; then
    success "Authentication API responding"
    AUTH_TEST_STATUS="✅"
  else
    warning "Authentication API not responding"
    AUTH_TEST_STATUS="⚠️"
  fi

  # 5.2: Test Firestore
  echo ""
  info "Testing Cloud Firestore..."
  if firebase firestore:indexes --project=$PROJECT_ID &> /dev/null; then
    success "Firestore database accessible"
    FIRESTORE_TEST_STATUS="✅"
  else
    warning "Cannot access Firestore database"
    FIRESTORE_TEST_STATUS="⚠️"
  fi

  # 5.3: Test Storage
  echo ""
  info "Testing Cloud Storage..."
  if command_exists gsutil && check_storage_exists "$PROJECT_ID"; then
    TEST_FILE="setup_test_$(date +%s).txt"
    echo "Firebase setup test" > "/tmp/$TEST_FILE"

    if gsutil cp "/tmp/$TEST_FILE" "gs://$DEFAULT_BUCKET/test/$TEST_FILE" &> /dev/null; then
      success "Storage upload successful"

      # Test download
      if gsutil cp "gs://$DEFAULT_BUCKET/test/$TEST_FILE" "/tmp/${TEST_FILE}_download" &> /dev/null; then
        success "Storage download successful"
        STORAGE_TEST_STATUS="✅"
      else
        warning "Storage download failed"
        STORAGE_TEST_STATUS="⚠️"
      fi

      # Clean up
      gsutil rm "gs://$DEFAULT_BUCKET/test/$TEST_FILE" &> /dev/null
      rm -f "/tmp/$TEST_FILE" "/tmp/${TEST_FILE}_download"
    else
      warning "Storage upload failed"
      STORAGE_TEST_STATUS="⚠️"
    fi
  else
    info "Skipping Storage test (gsutil or bucket not available)"
    STORAGE_TEST_STATUS="⏭️"
  fi

  echo ""
  success "Verification tests complete!"
else
  if [ "$SKIP_TESTS" = true ]; then
    info "Skipping verification tests (--skip-tests)"
  else
    info "Skipping verification tests (dry-run mode)"
  fi
  AUTH_TEST_STATUS="⏭️"
  FIRESTORE_TEST_STATUS="⏭️"
  STORAGE_TEST_STATUS="⏭️"
fi

#############################################
# Phase 6: Summary Report
#############################################
section "🎉 Setup Complete - Summary Report"

echo "Project: $PROJECT_ID"
echo "Region:  $REGION"
echo ""

print_separator
echo "Services Status:"
echo "  Authentication:       $AUTH_STATUS"
echo "  Firestore:            $FIRESTORE_STATUS"
echo "  Storage:              $STORAGE_STATUS"
echo "  Hosting:              $HOSTING_STATUS"
print_separator
echo ""

print_separator
echo "Security Configuration:"
echo "  Firestore Rules:      $FIRESTORE_RULES_STATUS"
echo "  Storage Rules:        $STORAGE_RULES_STATUS"
echo "  Firestore Indexes:    $INDEXES_STATUS"
echo "  Storage CORS:         $CORS_STATUS"
print_separator
echo ""

if [ "$SKIP_TESTS" = false ]; then
  print_separator
  echo "Verification Tests:"
  echo "  Auth Test:            $AUTH_TEST_STATUS"
  echo "  Firestore Test:       $FIRESTORE_TEST_STATUS"
  echo "  Storage Test:         $STORAGE_TEST_STATUS"
  print_separator
  echo ""
fi

if [ -n "$MANUAL_STEPS" ]; then
  warning "Manual Steps Required:"
  echo -e "$MANUAL_STEPS"
  echo ""
fi

# Determine overall status
if [ "$AUTH_STATUS" = "✅" ] && [ "$FIRESTORE_STATUS" = "✅" ] && [ "$STORAGE_STATUS" = "✅" ]; then
  if [ "$AUTH_TEST_STATUS" = "✅" ] || [ "$AUTH_TEST_STATUS" = "⏭️" ]; then
    success "All critical services configured and tested!"
  else
    warning "Services configured but some tests failed"
  fi
else
  warning "Some services need manual configuration"
fi

echo ""
section "📝 Next Steps"

echo "1. Update Firebase options file:"
echo "   flutterfire configure --project=$PROJECT_ID --out=lib/config/firebase_options_${PROJECT_ID}.dart"
echo ""

echo "2. Test your app:"
echo "   flutter run -d chrome --dart-define=ORG=yourorg --dart-define=ENV=staging"
echo ""

echo "3. Deploy to hosting:"
echo "   ./scripts/build_org.sh yourorg staging"
echo "   ./scripts/deploy_org.sh yourorg staging"
echo ""

if [[ "$PROJECT_ID" == *"production"* ]] || [[ "$PROJECT_ID" == *"prod"* ]]; then
  warning "⚠️  PRODUCTION PROJECT DETECTED"
  echo "Before deploying to production:"
  echo "  - Review and test all security rules"
  echo "  - Verify Firestore indexes are optimized"
  echo "  - Test authentication flow thoroughly"
  echo "  - Check Storage CORS is properly restricted"
  echo ""
fi

success "Setup script completed successfully! 🎉"
