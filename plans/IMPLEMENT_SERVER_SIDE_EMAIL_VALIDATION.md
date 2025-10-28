# Server-Side Email Domain Validation Implementation Plan

## Overview
Implement Firebase Auth Blocking Functions to enforce email domain restrictions server-side, preventing unauthorized user registration bypass.

**Status:** Not Started
**Priority:** High (Security)
**Estimated Time:** 2 hours

---

## Context

### Current State
- Email domain validation only happens client-side in `lib/ui/auth_page/login_register_page.dart`
- Validation logic in `lib/utils/email_validator.dart` (pure Dart function)
- Organization config in `lib/config/org_registry.dart` with per-org domains

### Problem
Users can bypass client validation by:
- Calling Firebase Auth REST API directly
- Using Firebase SDK from non-Flutter clients
- Modifying client code

### Solution
Firebase Auth Blocking Functions (`beforeCreate`) run server-side and cannot be bypassed.

---

## Architecture

### Technology Stack
- Firebase Functions v2 (Identity Platform)
- Node.js 18
- JavaScript (no TypeScript - keeping it simple)

### Module Structure
```
functions/
├── src/
│   ├── auth/
│   │   ├── validation/
│   │   │   └── emailValidator.js      # Pure validation logic
│   │   ├── config/
│   │   │   └── orgConfig.js           # Config loader
│   │   └── handlers/
│   │       └── beforeCreate.js        # Blocking function handler
│   └── index.js                        # Firebase exports
├── package.json
├── .eslintrc.js
└── .gitignore
```

### Design Principles
- **SRP:** Each module has single responsibility
- **KISS:** Simple, straightforward implementation
- **Pure Functions:** Validation logic is pure (no side effects)
- **Modularity:** Config separate from validation separate from handler

---

## Implementation Steps

### Step 1: Initialize Firebase Functions Project

**Goal:** Set up proper Firebase Functions structure with dependencies

**Tasks:**
1. Create proper `functions/package.json` with:
   - `firebase-functions: ^6.3.2` (already installed)
   - `firebase-admin: ^13.2.0` (already installed)
   - Node 18 engine requirement
   - Proper scripts for linting and deployment

2. Create `functions/.gitignore`:
   ```
   node_modules/
   npm-debug.log
   firebase-debug.log
   .firebase/
   *.log
   ```

3. Create `functions/.eslintrc.js` for code quality:
   ```javascript
   module.exports = {
     parserOptions: {
       ecmaVersion: 2022,
     },
     extends: [
       "eslint:recommended",
     ],
     env: {
       es6: true,
       node: true,
     },
     rules: {
       "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
       "quotes": ["error", "single"],
       "semi": ["error", "always"],
     },
   };
   ```

**Verification:** Run `cd functions && npm install` successfully

---

### Step 2: Implement Pure Email Validator

**Goal:** Create reusable, testable validation logic

**File:** `functions/src/auth/validation/emailValidator.js`

**Requirements:**
- Pure function (no side effects)
- Same logic as `lib/utils/email_validator.dart`
- Validation rules (in order):
  1. If email in whitelist → PASS
  2. If allowedDomains empty → PASS (no restrictions)
  3. If email domain matches allowedDomains → PASS
  4. Otherwise → FAIL with clear error message

**Function Signature:**
```javascript
/**
 * Validates email against domain restrictions and whitelist.
 * Pure function - no side effects, fully testable.
 *
 * @param {string} email - Email to validate
 * @param {string[]} allowedDomains - Allowed domains (e.g., ['rescuenet.net'])
 * @param {string[]} whitelistedEmails - Emails that bypass domain check
 * @returns {{ valid: boolean, error: string | null }}
 */
function validateEmailDomain(email, allowedDomains, whitelistedEmails)
```

**Implementation Details:**
- Normalize email with `.toLowerCase().trim()`
- Whitelist check is case-insensitive
- Extract domain by splitting on '@'
- Validate email format (must have exactly one '@')
- Compare domain against normalized allowedDomains list
- Return object with `{ valid, error }` structure

**Error Messages:**
- Single domain: `"Registration requires an email from <domain>"`
- Multiple domains: `"Registration requires an email from one of: <domain1>, <domain2>, ..."`
- Invalid format: `"Invalid email format"`

**Export:** `module.exports = { validateEmailDomain };`

---

### Step 3: Implement Config Loader

**Goal:** Load organization configuration from environment variables

**File:** `functions/src/auth/config/orgConfig.js`

**Requirements:**
- Simple function to read environment variables
- Defaults to no restrictions (fail open if misconfigured)
- Parse comma-separated values
- Trim whitespace

**Function Signature:**
```javascript
/**
 * Loads organization configuration from environment variables.
 * Defaults to no restrictions if not configured.
 *
 * Environment variables:
 * - ALLOWED_DOMAINS: Comma-separated list (e.g., "rescuenet.net,other.org")
 * - WHITELISTED_EMAILS: Comma-separated list (e.g., "dev@gmail.com,admin@test.com")
 *
 * @returns {{ allowedDomains: string[], whitelistedEmails: string[] }}
 */
function getOrgConfig()
```

**Implementation Details:**
- Read `process.env.ALLOWED_DOMAINS`
- Read `process.env.WHITELISTED_EMAILS`
- Split by comma, trim each item
- Handle undefined/empty values gracefully
- Return empty arrays if not configured

**Export:** `module.exports = { getOrgConfig };`

---

### Step 4: Implement Blocking Function Handler

**Goal:** Create beforeCreate handler that orchestrates validation

**File:** `functions/src/auth/handlers/beforeCreate.js`

**Requirements:**
- Use Firebase Functions v2 Identity triggers
- Thin orchestration layer (no business logic)
- Call config loader
- Call validator
- Throw appropriate error if validation fails

**Implementation:**
```javascript
const { beforeUserCreated } = require('firebase-functions/v2/identity');
const { HttpsError } = require('firebase-functions/v2/https');
const { validateEmailDomain } = require('../validation/emailValidator');
const { getOrgConfig } = require('../config/orgConfig');

const beforeCreate = beforeUserCreated((event) => {
  const email = event.data.email;

  if (!email) {
    throw new HttpsError('invalid-argument', 'Email is required');
  }

  // Load config for this Firebase project
  const config = getOrgConfig();

  // Validate using pure function
  const result = validateEmailDomain(
    email,
    config.allowedDomains,
    config.whitelistedEmails
  );

  // Reject if invalid
  if (!result.valid) {
    throw new HttpsError('invalid-argument', result.error);
  }

  // Allow registration
  return;
});

module.exports = { beforeCreate };
```

**Error Handling:**
- Missing email → throw error
- Validation fails → throw HttpsError with message from validator
- Validation passes → return (allow registration)

**Export:** `module.exports = { beforeCreate };`

---

### Step 5: Create Main Export File

**Goal:** Export all functions for Firebase

**File:** `functions/src/index.js`

**Implementation:**
```javascript
const { beforeCreate } = require('./auth/handlers/beforeCreate');

// Export all Firebase Functions
module.exports = {
  beforeCreate,
};
```

**Note:** Firebase looks for `functions/index.js` by default, but we can configure source directory in firebase.json

---

### Step 6: Update Firebase Configuration

**Goal:** Configure Firebase to use src/ directory and proper runtime

**File:** `firebase.json` (root of project)

**Update the `functions` section:**
```json
{
  "functions": {
    "runtime": "nodejs18",
    "source": "functions",
    "codebase": "default"
  }
}
```

**Verify:** Existing `functions` config in firebase.json already has `"source": "functions"`

---

### Step 7: Manual Testing - Staging Environment

**Goal:** Test implementation in rescuenet-testing (staging)

**Tasks:**

1. **Switch to staging project:**
   ```bash
   cd /Users/michandtke/dev/andi/RescuenetWarehouse
   firebase use rescuenet-testing
   ```

2. **Set environment configuration:**
   ```bash
   firebase functions:config:set \
     allowed_domains="rescuenet.net" \
     whitelisted_emails="Michael.Wandtke@hey.com"
   ```

3. **Verify configuration:**
   ```bash
   firebase functions:config:get
   ```

4. **Deploy blocking function:**
   ```bash
   firebase deploy --only functions:beforeCreate
   ```

5. **Manual testing:**
   - Test valid email (rescuenet.net): Should succeed
   - Test whitelisted email: Should succeed
   - Test invalid email (gmail.com): Should fail with clear error
   - Check Firebase Console > Functions > Logs for execution logs

6. **Verify in Firebase Console:**
   - Navigate to Authentication > Settings > Blocking functions
   - Confirm `beforeCreate` is listed and active

**Expected Results:**
- Valid domain registration succeeds
- Invalid domain registration blocked with error message
- Whitelisted emails bypass restrictions
- Function logs show validation attempts

---

### Step 8: Deploy to All Production Projects

**Goal:** Roll out to all Firebase projects

**For each project:**

#### rescuenet-7733b (RescueNet Production)
```bash
firebase use rescuenet-7733b
firebase functions:config:set \
  allowed_domains="rescuenet.net" \
  whitelisted_emails="Michael.Wandtke@hey.com"
firebase deploy --only functions:beforeCreate
```

#### humedica-e767c (Humedica Production)
```bash
firebase use humedica-e767c
firebase functions:config:set \
  allowed_domains="humedica.org,rescuenet.net" \
  whitelisted_emails="Michael.Wandtke@hey.com"
firebase deploy --only functions:beforeCreate
```

**Verification:**
- Check Firebase Console for each project
- Verify blocking function is active
- Monitor logs for 24-48 hours

---

### Step 9: Update Deployment Scripts

**Goal:** Automate function config and deployment in org deploy scripts

**Files to update:**
- `scripts/build_org.sh` - No changes needed
- `scripts/deploy_org.sh` - Add function deployment
- `scripts/release_org.sh` - Inherits from deploy_org.sh

**Changes to `scripts/deploy_org.sh`:**

1. Add function configuration step before deployment
2. Set config based on org ID from `lib/config/org_registry.dart`
3. Deploy functions along with hosting

**Implementation approach:**

Add after Firebase project selection (around line 40-50):

```bash
# Set Firebase Functions environment config based on organization
echo "Configuring Firebase Functions for ${ORG_ID}..."

case "${ORG_ID}" in
  "rescuenet")
    firebase functions:config:set \
      allowed_domains="rescuenet.net" \
      whitelisted_emails="Michael.Wandtke@hey.com"
    ;;
  "humedica")
    firebase functions:config:set \
      allowed_domains="humedica.org,rescuenet.net" \
      whitelisted_emails="Michael.Wandtke@hey.com"
    ;;
  *)
    echo "Warning: No function config defined for ${ORG_ID}"
    ;;
esac
```

Add to deployment command (update from `firebase deploy --only hosting` to):
```bash
firebase deploy --only hosting,functions
```

**Note:** Keep whitelist synced with `lib/config/org_registry.dart`

---

### Step 10: Documentation and Monitoring

**Goal:** Document implementation and set up monitoring

**Tasks:**

1. **Update CLAUDE.md** with blocking function info:
   - Add section under "Firebase Integration"
   - Document that email validation is enforced server-side
   - Reference this plan for implementation details

2. **Update ONBOARDING_ORG.md** for new orgs:
   - Add step to configure function environment variables
   - Add step to deploy blocking functions
   - Include in Firebase project setup checklist

3. **Set up monitoring (recommended):**
   - Firebase Console > Functions > Logs
   - Set up error alerts (optional but recommended)
   - Monitor blocked registration attempts

4. **Create runbook** (inline in CLAUDE.md):
   ```markdown
   ### Updating Email Domain Restrictions

   To update allowed domains or whitelist for an organization:

   1. Update `lib/config/org_registry.dart` (client-side validation)
   2. Set Firebase Function config:
      ```bash
      firebase use <project-id>
      firebase functions:config:set \
        allowed_domains="domain1.com,domain2.com" \
        whitelisted_emails="email1@test.com,email2@test.com"
      firebase deploy --only functions:beforeCreate
      ```
   3. Redeploy Flutter app (for client-side validation UX)
   ```

---

## Configuration Reference

### Per-Organization Settings

| Organization | Firebase Project(s) | Allowed Domains | Whitelisted Emails |
|--------------|-------------------|-----------------|-------------------|
| rescuenet    | rescuenet-testing<br>rescuenet-7733b | rescuenet.net | Michael.Wandtke@hey.com |
| humedica     | humedica-e767c | humedica.org<br>rescuenet.net | Michael.Wandtke@hey.com |

### Firebase Function Environment Variables

```bash
# RescueNet projects
allowed_domains="rescuenet.net"
whitelisted_emails="Michael.Wandtke@hey.com"

# Humedica project
allowed_domains="humedica.org,rescuenet.net"
whitelisted_emails="Michael.Wandtke@hey.com"
```

---

## Testing Checklist

### Manual Integration Testing (Per Project)

- [ ] Valid email registration succeeds
- [ ] Invalid email registration blocked
- [ ] Whitelisted email bypasses restrictions
- [ ] Error message is clear and user-friendly
- [ ] Client-side validation still works (immediate feedback)
- [ ] Server-side validation enforces (cannot bypass)
- [ ] Function logs show validation attempts
- [ ] Blocking function visible in Firebase Console

### Regression Testing

- [ ] Existing users can still sign in
- [ ] Password reset works
- [ ] Email verification works
- [ ] OAuth providers unaffected (if any)

---

## Rollback Plan

If blocking function causes issues:

1. **Quick rollback:**
   ```bash
   firebase use <project-id>
   firebase functions:delete beforeCreate
   ```

2. **Re-enable if needed:**
   ```bash
   firebase deploy --only functions:beforeCreate
   ```

3. **Debugging:**
   - Check Firebase Console > Functions > Logs
   - Look for function errors or exceptions
   - Verify environment config is set correctly

---

## Security Benefits

After implementation:
- ✅ Cannot bypass via direct API calls
- ✅ Cannot bypass via modified client
- ✅ Cannot bypass via third-party SDK
- ✅ Audit trail in Firebase Functions logs
- ✅ Fail secure (if function errors, registration blocked)

---

## Future Enhancements (Out of Scope)

- Add `beforeSignIn` trigger for additional validation
- Centralize config in Firestore (if managing 10+ orgs)
- Add rate limiting for registration attempts
- Enhanced logging/monitoring with Cloud Logging
- TypeScript migration (if functions grow complex)

---

## Execution Notes for Subagents

This plan is designed to be executed step-by-step:

1. Steps 1-6: Implementation (can be parallelized by file)
2. Step 7: Must be done sequentially (testing)
3. Step 8: Can be parallelized per project
4. Steps 9-10: Documentation updates

**Key files to reference:**
- `lib/utils/email_validator.dart` - Source of truth for validation logic
- `lib/config/org_registry.dart` - Configuration values to port
- `scripts/deploy_org.sh` - Script to enhance

**Testing strategy:**
- No unit tests (keeping it simple)
- Manual integration testing in staging
- Monitor production logs after deployment

---

## Completion Criteria

- [ ] All files created with proper structure
- [ ] Blocking function deployed to rescuenet-testing
- [ ] Manual testing passed in staging
- [ ] Blocking function deployed to all production projects
- [ ] Deployment scripts updated
- [ ] Documentation updated (CLAUDE.md, ONBOARDING_ORG.md)
- [ ] Monitoring in place
- [ ] 48-hour observation period completed

**Definition of Done:** Invalid email registrations are blocked server-side in all Firebase projects, and deployment scripts automate function configuration.
