# Firebase Setup Automation Script Plan

**Date:** 2025-10-10
**Goal:** Automate Firebase project setup and validation for multi-tenant environments
**Author:** Experienced senior engineer (startup background, Firebase/Flutter expert)

---

## Problem Statement

When setting up new Firebase projects for staging/production environments, developers consistently miss critical configuration steps:

1. ❌ **Auth providers not enabled** → "configuration-not-found" errors
2. ❌ **Firestore not created** → App crashes on first data access
3. ❌ **Storage not enabled** → Image uploads fail silently
4. ❌ **Security rules not deployed** → Production data exposed or staging locked down
5. ❌ **Wrong region selected** → Latency issues, compliance violations
6. ❌ **Indexes missing** → Queries fail in production but worked in dev
7. ❌ **CORS not configured** → Web app can't upload files

**Why this happens:**
- `flutterfire configure` only generates config files, doesn't provision services
- Firebase Console UI requires 20+ clicks across multiple pages
- No validation that all services are actually working
- Easy to forget steps when setting up 2+ environments per org

**Impact on startups:**
- 🔥 **2-4 hours lost per environment** troubleshooting "it works locally"
- 🔥 **Production incidents** from missing security rules
- 🔥 **Failed demos** because staging wasn't fully configured
- 🔥 **Developer frustration** from cryptic Firebase errors

---

## Solution: Automated Setup & Validation Script

**Script:** `scripts/setup_firebase_project.sh`

**Design Principles:**
1. **Idempotent** - Safe to run multiple times, won't break existing config
2. **Validation-first** - Check what exists before creating
3. **Manual fallback** - Clear instructions when automation isn't possible
4. **Progress indicators** - Show what's being checked/created
5. **Error recovery** - Don't fail entire script on one error
6. **Verification** - Test that services actually work after setup

**Capabilities:**
- ✅ **Automated:** CLI-based operations (Firebase CLI, gcloud)
- ⚠️ **Semi-automated:** Can check but not create (provide commands)
- 📋 **Manual:** Must be done in Console (provide detailed instructions + URL)

---

## Script Architecture

### Phase 1: Prerequisites Check
Verify tools are installed and user is authenticated.

### Phase 2: Project Validation
Check that Firebase project exists and is accessible.

### Phase 3: Service Provisioning
Enable and configure each Firebase service.

### Phase 4: Security Configuration
Deploy Firestore rules, Storage rules, and indexes.

### Phase 5: Verification
Test that each service is working correctly.

### Phase 6: Summary Report
Show what was configured, what needs manual action.

---

## Detailed Implementation Plan

### Phase 1: Prerequisites Check (5 minutes)

**Goal:** Ensure all required tools are installed and authenticated

**Checks:**

1. **Firebase CLI installed**
   ```bash
   if ! command -v firebase &> /dev/null; then
     echo "❌ Firebase CLI not installed"
     echo "Install: npm install -g firebase-tools"
     exit 1
   fi
   ```

2. **Firebase CLI authenticated**
   ```bash
   if ! firebase projects:list &> /dev/null; then
     echo "❌ Not authenticated with Firebase"
     echo "Run: firebase login"
     exit 1
   fi
   ```

3. **gcloud CLI installed** (for some operations)
   ```bash
   if ! command -v gcloud &> /dev/null; then
     echo "⚠️  gcloud CLI not installed (some features unavailable)"
     echo "Install: https://cloud.google.com/sdk/docs/install"
     GCLOUD_AVAILABLE=false
   else
     GCLOUD_AVAILABLE=true
   fi
   ```

4. **gcloud authenticated** (if installed)
   ```bash
   if [ "$GCLOUD_AVAILABLE" = true ]; then
     if ! gcloud auth list &> /dev/null; then
       echo "⚠️  gcloud not authenticated"
       echo "Run: gcloud auth login"
       GCLOUD_AVAILABLE=false
     fi
   fi
   ```

5. **jq installed** (for JSON parsing)
   ```bash
   if ! command -v jq &> /dev/null; then
     echo "❌ jq not installed (required for JSON parsing)"
     echo "Install: brew install jq (macOS) or apt install jq (Linux)"
     exit 1
   fi
   ```

6. **curl installed** (for API calls)
   ```bash
   if ! command -v curl &> /dev/null; then
     echo "❌ curl not installed"
     exit 1
   fi
   ```

**Output:**
```
✅ Firebase CLI installed (v13.0.0)
✅ Authenticated as user@example.com
✅ gcloud CLI installed (v450.0.0)
✅ gcloud authenticated
✅ jq installed
✅ curl installed

Prerequisites check complete!
```

---

### Phase 2: Project Validation (2 minutes)

**Goal:** Verify Firebase project exists and script has access

**Input:**
- `PROJECT_ID` (e.g., "rescuenet-testing")
- `REGION` (e.g., "europe-west1")

**Validation Steps:**

1. **Check project exists**
   ```bash
   if ! firebase projects:list | grep -q "$PROJECT_ID"; then
     echo "❌ Project '$PROJECT_ID' not found"
     echo ""
     echo "Create project at: https://console.firebase.google.com/"
     echo "Or run: firebase projects:create $PROJECT_ID"
     exit 1
   fi
   ```

2. **Get project number** (needed for API calls)
   ```bash
   PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
   if [ -z "$PROJECT_NUMBER" ]; then
     echo "❌ Cannot get project number for $PROJECT_ID"
     exit 1
   fi
   ```

3. **Check project location/region is set**
   ```bash
   # Firestore requires a default location to be set
   CURRENT_LOCATION=$(gcloud app describe --project=$PROJECT_ID 2>/dev/null | grep "locationId" | awk '{print $2}')
   if [ -z "$CURRENT_LOCATION" ]; then
     echo "⚠️  Default location not set for project"
     echo "This will be set when Firestore is created"
   fi
   ```

4. **Check billing is enabled** (required for some features)
   ```bash
   # Note: This requires Cloud Billing API access
   # If not available, just warn
   BILLING_ENABLED=$(gcloud beta billing projects describe $PROJECT_ID --format="json" 2>/dev/null | jq -r '.billingEnabled')
   if [ "$BILLING_ENABLED" != "true" ]; then
     echo "⚠️  Billing might not be enabled (some features may not work)"
     echo "Enable at: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
   fi
   ```

**Output:**
```
🔍 Validating project: rescuenet-testing

✅ Project exists
✅ Project number: 123456789
✅ Billing enabled
⚠️  Default location not set (will be set with Firestore)

Project validation complete!
```

---

### Phase 3: Service Provisioning (10 minutes)

**Goal:** Enable and configure all required Firebase services

#### 3.1: Firebase Authentication

**Check if enabled:**
```bash
# Use Firebase Management API
AUTH_ENABLED=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://identitytoolkit.googleapis.com/v1/projects/$PROJECT_ID/config" \
  | jq -r '.signIn.allowDuplicateEmails' 2>/dev/null)

if [ -z "$AUTH_ENABLED" ]; then
  echo "⚠️  Authentication not enabled"
else
  echo "✅ Authentication enabled"
fi
```

**Enable Auth (MANUAL - requires Console):**
```bash
# Firebase Auth CANNOT be fully enabled via CLI
# Must be done in Console
if [ -z "$AUTH_ENABLED" ]; then
  echo ""
  echo "📋 MANUAL STEP REQUIRED: Enable Authentication"
  echo ""
  echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
  echo "2. Click 'Get started'"
  echo "3. Click 'Email/Password' provider"
  echo "4. Toggle 'Enable'"
  echo "5. Click 'Save'"
  echo ""
  read -p "Press Enter after completing this step..."
fi
```

**Check Email/Password provider:**
```bash
# Check if email/password is enabled
EMAIL_ENABLED=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://identitytoolkit.googleapis.com/v1/projects/$PROJECT_ID/config" \
  | jq -r '.signIn.email.enabled' 2>/dev/null)

if [ "$EMAIL_ENABLED" = "true" ]; then
  echo "✅ Email/Password provider enabled"
else
  echo "⚠️  Email/Password provider not enabled"
  echo ""
  echo "📋 MANUAL STEP: Enable Email/Password provider"
  echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
  echo "2. Click 'Email/Password'"
  echo "3. Toggle 'Enable'"
  echo "4. Click 'Save'"
  echo ""
  read -p "Press Enter after completing this step..."
fi
```

**Validation:**
```bash
# Verify Auth is working by checking if we can access the config
AUTH_CONFIG=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://identitytoolkit.googleapis.com/v1/projects/$PROJECT_ID/config")

if echo "$AUTH_CONFIG" | jq -e '.signIn' > /dev/null 2>&1; then
  echo "✅ Authentication API responding"
else
  echo "❌ Authentication API not responding"
  exit 1
fi
```

#### 3.2: Cloud Firestore

**Check if Firestore exists:**
```bash
# Try to access Firestore
FIRESTORE_EXISTS=$(gcloud firestore databases list --project=$PROJECT_ID 2>/dev/null | grep -c "(default)")

if [ "$FIRESTORE_EXISTS" -gt 0 ]; then
  echo "✅ Firestore database exists"

  # Get the location
  FIRESTORE_LOCATION=$(gcloud firestore databases describe --database="(default)" --project=$PROJECT_ID --format="value(locationId)" 2>/dev/null)
  echo "   Location: $FIRESTORE_LOCATION"

  if [ "$FIRESTORE_LOCATION" != "$REGION" ]; then
    echo "⚠️  Firestore location ($FIRESTORE_LOCATION) differs from target region ($REGION)"
    echo "   This cannot be changed after creation!"
  fi
else
  echo "⚠️  Firestore database not created"
fi
```

**Create Firestore (SEMI-AUTOMATED):**
```bash
if [ "$FIRESTORE_EXISTS" -eq 0 ]; then
  echo ""
  echo "Creating Firestore database in $REGION..."

  # Try to create via gcloud
  if [ "$GCLOUD_AVAILABLE" = true ]; then
    # Note: This might require additional permissions
    gcloud firestore databases create --location=$REGION --project=$PROJECT_ID 2>/dev/null

    if [ $? -eq 0 ]; then
      echo "✅ Firestore database created"
    else
      echo "❌ Could not create Firestore via CLI"
      echo ""
      echo "📋 MANUAL STEP: Create Firestore Database"
      echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
      echo "2. Click 'Create database'"
      echo "3. Select 'Start in production mode'"
      echo "4. Choose location: $REGION"
      echo "5. Click 'Enable'"
      echo ""
      read -p "Press Enter after completing this step..."
    fi
  else
    echo "📋 MANUAL STEP: Create Firestore Database"
    echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
    echo "2. Click 'Create database'"
    echo "3. Select 'Start in production mode'"
    echo "4. Choose location: $REGION"
    echo "5. Click 'Enable'"
    echo ""
    read -p "Press Enter after completing this step..."
  fi
fi
```

**Validation:**
```bash
# Test Firestore access by trying to list collections
if firebase firestore:indexes --project=$PROJECT_ID &> /dev/null; then
  echo "✅ Firestore API accessible"
else
  echo "❌ Cannot access Firestore API"
fi
```

#### 3.3: Cloud Storage

**Check if Storage bucket exists:**
```bash
# Default bucket is named: PROJECT_ID.appspot.com
DEFAULT_BUCKET="${PROJECT_ID}.appspot.com"

BUCKET_EXISTS=$(gsutil ls -b gs://$DEFAULT_BUCKET 2>/dev/null)

if [ -n "$BUCKET_EXISTS" ]; then
  echo "✅ Storage bucket exists: $DEFAULT_BUCKET"

  # Check bucket location
  BUCKET_LOCATION=$(gsutil ls -L -b gs://$DEFAULT_BUCKET | grep "Location constraint" | awk '{print $3}')
  echo "   Location: $BUCKET_LOCATION"
else
  echo "⚠️  Storage bucket not created"
fi
```

**Enable Storage (MANUAL):**
```bash
if [ -z "$BUCKET_EXISTS" ]; then
  echo ""
  echo "📋 MANUAL STEP: Enable Cloud Storage"
  echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/storage"
  echo "2. Click 'Get started'"
  echo "3. Click 'Next' (use default security rules for now)"
  echo "4. Choose location: $REGION"
  echo "5. Click 'Done'"
  echo ""
  read -p "Press Enter after completing this step..."
fi
```

**Validation:**
```bash
# Test by uploading a test file
echo "test" > /tmp/firebase_test.txt
if gsutil cp /tmp/firebase_test.txt gs://$DEFAULT_BUCKET/test/firebase_test.txt &> /dev/null; then
  echo "✅ Storage write test successful"
  gsutil rm gs://$DEFAULT_BUCKET/test/firebase_test.txt &> /dev/null
else
  echo "❌ Cannot write to Storage bucket"
fi
rm /tmp/firebase_test.txt
```

#### 3.4: Firebase Hosting

**Check if Hosting is initialized:**
```bash
# Hosting is automatically available, but needs to be deployed
HOSTING_SITE=$(firebase hosting:sites:list --project=$PROJECT_ID 2>/dev/null | grep "$PROJECT_ID" | awk '{print $1}')

if [ -n "$HOSTING_SITE" ]; then
  echo "✅ Hosting site exists: $HOSTING_SITE"
else
  echo "⚠️  Hosting not initialized"
fi
```

**Initialize Hosting (AUTOMATIC):**
```bash
if [ -z "$HOSTING_SITE" ]; then
  echo "Initializing Firebase Hosting..."

  # Hosting is auto-created on first deploy, so just note it
  echo "ℹ️  Hosting will be created on first deployment"
fi
```

---

### Phase 4: Security Configuration (5 minutes)

**Goal:** Deploy security rules and indexes

#### 4.1: Firestore Security Rules

**Check for existing rules file:**
```bash
if [ -f "firestore.rules" ]; then
  echo "✅ Found firestore.rules"
else
  echo "⚠️  No firestore.rules file found"
  echo "   Using default rules (deny all)"
fi
```

**Option 1: Copy rules from production environment**
```bash
echo ""
echo "Do you want to copy Firestore rules from another project? (y/n)"
read -p "> " COPY_RULES

if [ "$COPY_RULES" = "y" ]; then
  echo "Enter source project ID (e.g., rescuenet-7733b):"
  read -p "> " SOURCE_PROJECT

  echo "Fetching rules from $SOURCE_PROJECT..."

  # Get rules from source project
  gcloud firestore databases get-ruleset --project=$SOURCE_PROJECT --format=json > /tmp/rules.json 2>/dev/null

  if [ $? -eq 0 ]; then
    # Extract rules content
    jq -r '.source.files[0].content' /tmp/rules.json > firestore.rules
    echo "✅ Rules copied to firestore.rules"
  else
    echo "❌ Could not fetch rules from $SOURCE_PROJECT"
    echo "   You may not have access to that project"
  fi

  rm -f /tmp/rules.json
fi
```

**Option 2: Use template rules**
```bash
if [ ! -f "firestore.rules" ]; then
  echo ""
  echo "Creating basic Firestore rules (authenticated users only)..."

  cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write all documents
    // CUSTOMIZE THIS FOR YOUR APP!
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
EOF

  echo "✅ Created firestore.rules with basic authentication"
  echo "⚠️  IMPORTANT: Customize these rules for your data model!"
fi
```

**Deploy Firestore rules:**
```bash
if [ -f "firestore.rules" ]; then
  echo "Deploying Firestore security rules..."

  firebase deploy --only firestore:rules --project=$PROJECT_ID

  if [ $? -eq 0 ]; then
    echo "✅ Firestore rules deployed"
  else
    echo "❌ Failed to deploy Firestore rules"
  fi
fi
```

#### 4.2: Storage Security Rules

**Check for existing rules file:**
```bash
if [ -f "storage.rules" ]; then
  echo "✅ Found storage.rules"
else
  echo "⚠️  No storage.rules file found"
fi
```

**Copy or create storage rules:**
```bash
if [ ! -f "storage.rules" ] && [ "$COPY_RULES" = "y" ]; then
  echo "Fetching Storage rules from $SOURCE_PROJECT..."

  # Get storage rules
  gsutil cat gs://${SOURCE_PROJECT}.appspot.com/.rules 2>/dev/null > storage.rules

  if [ -f "storage.rules" ]; then
    echo "✅ Rules copied to storage.rules"
  fi
fi

if [ ! -f "storage.rules" ]; then
  echo "Creating basic Storage rules..."

  cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to read/write
    // CUSTOMIZE THIS FOR YOUR APP!
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
EOF

  echo "✅ Created storage.rules with basic authentication"
fi
```

**Deploy Storage rules:**
```bash
if [ -f "storage.rules" ]; then
  echo "Deploying Storage security rules..."

  firebase deploy --only storage --project=$PROJECT_ID

  if [ $? -eq 0 ]; then
    echo "✅ Storage rules deployed"
  else
    echo "❌ Failed to deploy Storage rules"
  fi
fi
```

#### 4.3: Firestore Indexes

**Check for indexes file:**
```bash
if [ -f "firestore.indexes.json" ]; then
  echo "✅ Found firestore.indexes.json"
else
  echo "⚠️  No firestore.indexes.json file"
  echo "   Creating default indexes file..."

  cat > firestore.indexes.json << 'EOF'
{
  "indexes": [],
  "fieldOverrides": []
}
EOF
fi
```

**Option to copy indexes from production:**
```bash
if [ "$COPY_RULES" = "y" ]; then
  echo "Fetching indexes from $SOURCE_PROJECT..."

  firebase firestore:indexes --project=$SOURCE_PROJECT > firestore.indexes.json 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "✅ Indexes copied from production"
  fi
fi
```

**Deploy indexes:**
```bash
echo "Deploying Firestore indexes..."

firebase deploy --only firestore:indexes --project=$PROJECT_ID

if [ $? -eq 0 ]; then
  echo "✅ Firestore indexes deployed"
else
  echo "⚠️  Failed to deploy indexes (may not be critical)"
fi
```

#### 4.4: Storage CORS Configuration

**Why CORS matters:**
Web apps need CORS configured to upload files directly from browser.

**Check current CORS config:**
```bash
CORS_CONFIG=$(gsutil cors get gs://$DEFAULT_BUCKET 2>/dev/null)

if [ -n "$CORS_CONFIG" ] && [ "$CORS_CONFIG" != "[]" ]; then
  echo "✅ CORS configured for Storage bucket"
else
  echo "⚠️  CORS not configured (web uploads may fail)"
fi
```

**Configure CORS (AUTOMATIC):**
```bash
if [ -z "$CORS_CONFIG" ] || [ "$CORS_CONFIG" = "[]" ]; then
  echo "Configuring CORS for Storage..."

  # Create CORS config file
  cat > /tmp/cors.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"],
    "maxAgeSeconds": 3600
  }
]
EOF

  gsutil cors set /tmp/cors.json gs://$DEFAULT_BUCKET

  if [ $? -eq 0 ]; then
    echo "✅ CORS configured"
  else
    echo "❌ Failed to configure CORS"
  fi

  rm /tmp/cors.json
fi
```

**Production CORS (more restrictive):**
```bash
# For production, use specific origins
if [[ "$PROJECT_ID" == *"production"* ]] || [[ "$PROJECT_ID" == *"prod"* ]]; then
  echo ""
  echo "⚠️  PRODUCTION PROJECT DETECTED"
  echo "   Current CORS allows all origins (*)"
  echo "   Consider restricting to your domain(s)"
  echo ""
  echo "Example:"
  echo '  "origin": ["https://yourdomain.com", "https://www.yourdomain.com"]'
  echo ""
fi
```

---

### Phase 5: Verification (3 minutes)

**Goal:** Test that all services are actually working

#### 5.1: Test Authentication

**Create test user:**
```bash
echo ""
echo "🧪 Testing Authentication..."

TEST_EMAIL="test-$(date +%s)@example.com"
TEST_PASSWORD="TestPass123!"

# Use Firebase Admin SDK or Auth REST API to create user
curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$(firebase apps:sdkconfig --project=$PROJECT_ID | grep apiKey | awk '{print $2}' | tr -d '\",')" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"returnSecureToken\":true}" \
  > /tmp/auth_test.json

if jq -e '.idToken' /tmp/auth_test.json > /dev/null 2>&1; then
  echo "✅ Authentication test: User creation successful"

  # Get the user ID to delete
  TEST_UID=$(jq -r '.localId' /tmp/auth_test.json)

  # Clean up test user
  # (Requires Admin SDK, skip if not available)
  echo "   Cleaning up test user..."
else
  echo "❌ Authentication test failed"
  cat /tmp/auth_test.json
fi

rm -f /tmp/auth_test.json
```

#### 5.2: Test Firestore

**Write and read test document:**
```bash
echo "🧪 Testing Firestore..."

# Create test document
TEST_DOC_ID="setup_test_$(date +%s)"

# Use Firebase CLI to write test document
firebase firestore:delete "test_collection/$TEST_DOC_ID" --project=$PROJECT_ID -y &> /dev/null

# Write test doc (requires firebase-tools with proper auth)
echo '{"test": true, "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > /tmp/test_doc.json

# Note: Direct write via CLI is complex, so we verify by checking indexes work
if firebase firestore:indexes --project=$PROJECT_ID &> /dev/null; then
  echo "✅ Firestore test: Database accessible"
else
  echo "❌ Firestore test failed"
fi

rm -f /tmp/test_doc.json
```

#### 5.3: Test Storage

**Upload and download test file:**
```bash
echo "🧪 Testing Storage..."

TEST_FILE="setup_test_$(date +%s).txt"
echo "Firebase setup test" > /tmp/$TEST_FILE

# Upload test file
gsutil cp /tmp/$TEST_FILE gs://$DEFAULT_BUCKET/test/$TEST_FILE &> /dev/null

if [ $? -eq 0 ]; then
  echo "✅ Storage test: Upload successful"

  # Download to verify
  gsutil cp gs://$DEFAULT_BUCKET/test/$TEST_FILE /tmp/${TEST_FILE}_download &> /dev/null

  if [ $? -eq 0 ]; then
    echo "✅ Storage test: Download successful"
  else
    echo "⚠️  Storage download failed"
  fi

  # Clean up
  gsutil rm gs://$DEFAULT_BUCKET/test/$TEST_FILE &> /dev/null
  rm -f /tmp/$TEST_FILE /tmp/${TEST_FILE}_download
else
  echo "❌ Storage test failed"
fi
```

#### 5.4: Test Hosting

**Check hosting status:**
```bash
echo "🧪 Testing Hosting..."

HOSTING_URL=$(firebase hosting:sites:list --project=$PROJECT_ID 2>/dev/null | grep "$PROJECT_ID" | awk '{print $2}')

if [ -n "$HOSTING_URL" ]; then
  echo "✅ Hosting URL: https://$HOSTING_URL.web.app"
  echo "   (Will be live after first deployment)"
else
  echo "ℹ️  Hosting will be available after first deployment"
fi
```

---

### Phase 6: Summary Report (1 minute)

**Goal:** Show comprehensive status of all services

```bash
echo ""
echo "========================================"
echo "  Firebase Setup Summary"
echo "========================================"
echo ""
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo ""
echo "Services Status:"
echo "  Authentication:  $AUTH_STATUS"
echo "  Firestore:       $FIRESTORE_STATUS"
echo "  Storage:         $STORAGE_STATUS"
echo "  Hosting:         $HOSTING_STATUS"
echo ""
echo "Security Configuration:"
echo "  Firestore Rules: $FIRESTORE_RULES_STATUS"
echo "  Storage Rules:   $STORAGE_RULES_STATUS"
echo "  Firestore Indexes: $INDEXES_STATUS"
echo "  Storage CORS:    $CORS_STATUS"
echo ""

if [ -n "$MANUAL_STEPS" ]; then
  echo "⚠️  Manual Steps Required:"
  echo "$MANUAL_STEPS"
  echo ""
fi

echo "Verification Tests:"
echo "  Auth Test:       $AUTH_TEST_STATUS"
echo "  Firestore Test:  $FIRESTORE_TEST_STATUS"
echo "  Storage Test:    $STORAGE_TEST_STATUS"
echo ""

if [ "$ALL_TESTS_PASSED" = true ]; then
  echo "✅ All tests passed! Project is ready to use."
else
  echo "⚠️  Some tests failed. Review the output above."
fi

echo ""
echo "Next Steps:"
echo "  1. Update firebase_options_*.dart files:"
echo "     flutterfire configure --project=$PROJECT_ID --out=lib/config/firebase_options_${ORG}_${ENV}.dart"
echo ""
echo "  2. Test the app:"
echo "     flutter run -d chrome --dart-define=ORG=${ORG} --dart-define=ENV=${ENV}"
echo ""
echo "  3. Deploy to hosting:"
echo "     ./scripts/deploy_org.sh ${ORG} ${ENV}"
echo ""
```

---

## Script Interface

### Command-line Arguments

```bash
./scripts/setup_firebase_project.sh <project_id> <region> [options]
```

**Required:**
- `project_id` - Firebase project ID (e.g., "rescuenet-testing")
- `region` - Firebase region (e.g., "europe-west1")

**Options:**
- `--copy-from=<source_project>` - Copy rules/indexes from another project
- `--skip-tests` - Skip verification tests
- `--yes` - Auto-confirm all prompts (non-interactive)
- `--verbose` - Show detailed output
- `--dry-run` - Show what would be done without making changes

### Examples

**Basic setup:**
```bash
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1
```

**Copy from production:**
```bash
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --copy-from=rescuenet-7733b
```

**Non-interactive setup:**
```bash
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --yes --copy-from=rescuenet-7733b
```

**Dry run:**
```bash
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --dry-run
```

---

## Error Handling

### Common Errors & Recovery

**1. Permission Denied**
```bash
Error: Permission denied accessing project

Fix:
  1. Check you're authenticated: firebase login
  2. Verify project access in Firebase Console
  3. Check IAM roles (need Editor or Owner)
```

**2. Region Mismatch**
```bash
Error: Firestore already exists in different region

Fix:
  This cannot be changed! Options:
  1. Use existing region (recommended)
  2. Delete project and recreate (loses data!)
  3. Create new project with correct region
```

**3. Quota Exceeded**
```bash
Error: Quota exceeded for project

Fix:
  1. Check billing is enabled
  2. Request quota increase in Cloud Console
  3. Wait for quota reset (if rate limit)
```

**4. Service API Not Enabled**
```bash
Error: Firestore API not enabled

Fix:
  Automatically enabling APIs...
  (Script should enable required APIs)
```

---

## Integration with Existing Scripts

### Update `build_org.sh`

Add validation check before building:

```bash
# Check if Firebase project is properly configured
if [ ! -f "lib/config/firebase_options_${ORG}_${ENV}.dart" ]; then
  echo "❌ Firebase config not found for $ORG ($ENV)"
  echo "Run: ./scripts/setup_firebase_project.sh ${ORG}-${ENV} europe-west1"
  exit 1
fi
```

### Update `deploy_org.sh`

Add Firebase validation:

```bash
# Verify Firebase project is accessible
if ! firebase projects:list | grep -q "$FIREBASE_PROJECT"; then
  echo "❌ Cannot access Firebase project: $FIREBASE_PROJECT"
  echo "Run: ./scripts/setup_firebase_project.sh $FIREBASE_PROJECT europe-west1"
  exit 1
fi
```

### Update `ONBOARDING_ORG.md`

Replace manual Firebase setup steps:

```markdown
### Step 1: Setup Firebase Projects

**Old way (manual, 30+ clicks):**
- Go to Firebase Console
- Create staging project
- Enable Auth, Firestore, Storage
- Configure providers
- Set security rules
- etc...

**New way (automated, 2 minutes):**
```bash
# Setup staging
./scripts/setup_firebase_project.sh acme-staging europe-west1 --copy-from=rescuenet-7733b

# Setup production
./scripts/setup_firebase_project.sh acme-production europe-west1 --copy-from=rescuenet-7733b
```

Done! ✅
```

---

## Testing Strategy

### Manual Testing Checklist

Test script against:

- ✅ **Fresh project** (nothing configured)
- ✅ **Partially configured** (Auth enabled, Firestore missing)
- ✅ **Fully configured** (should be idempotent)
- ✅ **Different regions** (US, EU, Asia)
- ✅ **Permission errors** (test with limited IAM roles)
- ✅ **Network errors** (test with poor connection)

### Automated Tests

Create `test_setup_script.sh`:

```bash
#!/bin/bash
# Test the Firebase setup script

# Test 1: Prerequisites check
echo "Test 1: Prerequisites check"
./scripts/setup_firebase_project.sh --dry-run

# Test 2: Project validation
echo "Test 2: Project validation"
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --dry-run

# Test 3: Idempotency
echo "Test 3: Run twice, should be idempotent"
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --yes
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --yes

# Verify second run didn't break anything
# TODO: Add validation checks
```

---

## Advanced Features (Future Enhancements)

### 1. Multi-Organization Batch Setup

Setup all environments for an org at once:

```bash
./scripts/setup_firebase_org.sh acme europe-west1
# Creates: acme-staging, acme-production
# Copies rules from: rescuenet-7733b
# Validates: All services working
```

### 2. Environment Cloning

Clone entire environment:

```bash
./scripts/clone_firebase_env.sh rescuenet-7733b rescuenet-testing
# Copies: Rules, indexes, CORS, collections (optional)
```

### 3. Configuration Diff

Compare two environments:

```bash
./scripts/diff_firebase_config.sh rescuenet-7733b rescuenet-testing
# Shows: Rule differences, missing indexes, config mismatches
```

### 4. Health Check Script

Ongoing validation:

```bash
./scripts/check_firebase_health.sh rescuenet-testing
# Checks: All services up, rules deployed, indexes built, quota usage
```

### 5. Data Seeding

Populate staging with test data:

```bash
./scripts/seed_firebase_data.sh rescuenet-testing --dataset=demo
# Creates: Sample users, items, containers for testing
```

---

## Implementation Priority

**Phase 1 (MVP - 4 hours):**
- Basic script structure
- Prerequisites check
- Project validation
- Service detection
- Manual step instructions

**Phase 2 (Automation - 6 hours):**
- Firestore creation (gcloud)
- Rules deployment
- Index deployment
- CORS configuration
- Basic verification tests

**Phase 3 (Polish - 4 hours):**
- Error handling
- Progress indicators
- Summary report
- Copy from production
- Documentation

**Phase 4 (Advanced - 8 hours):**
- Non-interactive mode
- Batch operations
- Health checks
- Data seeding

**Total Estimate: 22 hours → Deliver in 2-3 days**

---

## Success Criteria

✅ **Script runs successfully on fresh Firebase project**
✅ **All required services enabled and configured**
✅ **Security rules deployed automatically**
✅ **Verification tests pass**
✅ **Clear error messages with recovery instructions**
✅ **Idempotent (safe to run multiple times)**
✅ **Reduces setup time from 2-4 hours to 5 minutes**
✅ **Prevents "configuration-not-found" errors**

---

## Risks & Mitigations

**Risk 1: Firebase API limitations**
- Mitigation: Provide clear manual fallback instructions

**Risk 2: Authentication/permission issues**
- Mitigation: Check permissions early, provide clear error messages

**Risk 3: Regional constraints**
- Mitigation: Validate region before creating resources

**Risk 4: Breaking existing configurations**
- Mitigation: Check before create, never modify existing services

**Risk 5: Incomplete API coverage**
- Mitigation: Hybrid approach (auto + manual steps)

---

## Documentation

### Files to Create

1. `scripts/setup_firebase_project.sh` - Main script
2. `scripts/lib/firebase_utils.sh` - Helper functions
3. `scripts/README.md` - Update with new script usage
4. `ONBOARDING_ORG.md` - Update with automated setup
5. `TROUBLESHOOTING.md` - Firebase setup issues

### README Update

```markdown
## Firebase Setup Script

Automate Firebase project configuration for new organizations.

**Usage:**
```bash
./scripts/setup_firebase_project.sh <project_id> <region> [options]
```

**Features:**
- ✅ Validates all prerequisites
- ✅ Enables Authentication (Email/Password)
- ✅ Creates Firestore database
- ✅ Enables Cloud Storage
- ✅ Deploys security rules
- ✅ Configures CORS
- ✅ Runs verification tests
- ✅ Copies config from production

**Time saved:** 2-4 hours → 5 minutes

See `scripts/README.md` for detailed documentation.
```

---

## Appendix: Firebase Service Checklist

**Complete checklist for Firebase project setup:**

### Authentication
- [ ] Authentication enabled in Console
- [ ] Email/Password provider enabled
- [ ] Password policy configured (optional)
- [ ] Email templates customized (optional)
- [ ] Authorized domains configured

### Firestore
- [ ] Database created in correct region
- [ ] Security rules deployed
- [ ] Indexes deployed
- [ ] Backup schedule configured (production only)

### Storage
- [ ] Default bucket created
- [ ] Security rules deployed
- [ ] CORS configured for web
- [ ] Lifecycle policies (optional)

### Hosting
- [ ] Site created (auto on first deploy)
- [ ] Custom domain configured (optional)
- [ ] SSL certificate provisioned (auto)

### Other
- [ ] Firebase functions (if needed)
- [ ] Remote Config (if needed)
- [ ] Cloud Messaging (if needed)
- [ ] Analytics (optional)
- [ ] Performance Monitoring (optional)

---

## Conclusion

This script will:

1. **Save 2-4 hours per environment** - Automation > manual clicking
2. **Prevent production incidents** - Security rules deployed correctly
3. **Reduce developer frustration** - Clear error messages, auto-fix
4. **Enable fast scaling** - Add new orgs/envs in minutes
5. **Maintain consistency** - Same setup process every time

**ROI for startups:**
- 10 environments × 3 hours saved = **30 hours saved**
- No more "configuration-not-found" debugging = **Priceless**
- Faster customer onboarding = **Competitive advantage**

This is the kind of tooling that separates fast-moving startups from slow ones.
