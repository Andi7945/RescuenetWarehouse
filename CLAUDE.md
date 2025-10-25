# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RescuenetWarehouse is a Flutter web application for managing warehouse inventory and deployments for the NGO Rescue Net. The app manages items stored in containers for deployment logistics.

**Technology Stack:**
- Flutter 3.32.4+ with Dart 3.8.1+
- Firebase (Auth, Firestore, Storage, Hosting)
- Riverpod for state management
- Custom lint with riverpod_lint

## Development Commands

### Code Generation
```bash
dart run build_runner build
dart run build_runner watch
```
*Required after modifying JSON serializable models or Riverpod providers*

### Firebase
```bash
# Deploy to Firebase
firebase deploy

# Import data
firebase firestore:import --collection-name "items" --project "RescueNet" --csv "path/to/file.csv" --field-separator ";"
```

## Architecture

### State Management
Uses **Riverpod** with code generation. All state notifiers are in `lib/state/` and use `@riverpod` annotations.

Key patterns:
- Data providers in `lib/db/` handle Firebase collections  
- State notifiers manage UI state and derived data
- Eager initialization in `main.dart` ensures providers stay alive

### Data Models
Located in `lib/models/` using:
- **Freezed** for immutable data classes
- **json_serializable** for JSON serialization
- Generated files have `.g.dart` and `.freezed.dart` extensions

### UI Structure
- **Features**: Domain-specific functionality in `lib/features/`
- **UI Pages**: Reusable page components in `lib/ui/`
- **Widgets**: Shared components in `lib/widgets/`

### Firebase Integration
- Firestore collections: items, containers, assignments, work_logs, container_types, current_locations, module_destinations
- Authentication with role-based access (Packer, Back Office, Logistics, On Deployment)
- Storage for item images and documents

### PDF Generation

Located in `lib/features/printing/` with clean separation of concerns.

**Architecture:**
- **domain/** - PrintContext model and providers for user/org info
- **generators/** - Pure functions that convert DTOs to PDF Documents
- **services/** - Orchestration (PdfGenerationService, SafetyDatasheetService, FileService, PrintService)
- **ui/** - UI components and action handlers (ExportActions)

**Key Principles:**
- Generators are pure functions taking DTOs + PrintContext
- No UI (BuildContext) dependencies in business logic
- Username and organization info provided via Riverpod providers
- All DTOs are Freezed immutable models

**Features:**
- Packing lists: `ExportActions.handlePackingLists(context, ref, containers)`
- Labels: `ExportActions.handleLabels(context, ref, containers)`
- Summary: `ExportActions.handleSummary(context, ref, containers)`
- Safety datasheets: `ExportActions.handleSafetyDatasheets(context, ref, containers)`

**Legacy:**
- `lib/pdf/` folder contains DTO models and mappers (still used)
- Old PDF generation files have been removed (fully migrated to `lib/features/printing/`)

## Domain Model

**Core Entities:**
- **Items**: Equipment/supplies with metadata (expiry dates, dangerous goods signs)
- **Containers**: Physical storage units with capacity constraints
- **Assignments**: Links between items and containers with quantities
- **Work Logs**: Audit trail of operations

**User Roles:**
- **Packer**: Verify container contents, print sheets
- **Back Office**: Manage items and containers
- **Logistics**: Combined packer + back office privileges  
- **On Deployment**: Mark items as used post-deployment

## Build Configuration

- `build.yaml`: Configures json_serializable with `explicit_to_json: true`
- `analysis_options.yaml`: Uses flutter_lints + custom_lint with riverpod_lint
- Firebase hosting configured for europe-west1 region

## Multi-Tenant Configuration

The app supports multiple organizations with separate Firebase projects per environment.

### Architecture
- **Build-time selection** via `--dart-define=ORG=<org_id> --dart-define=ENV=<environment>`
- **Pure function config** in `lib/config/org_registry.dart`
- **Per-org staging and production** Firebase projects
- **Zero runtime overhead** - all configuration resolved at build time
- **Freezed immutable models** for organization configuration
- **Complete isolation** - each org has separate Firebase projects and data

### Available Organizations
- `rescuenet` (default)

### Build Commands

```bash
# Build for staging (default)
flutter build web --dart-define=ORG=rescuenet --dart-define=ENV=staging

# Build for production
flutter build web --dart-define=ORG=rescuenet --dart-define=ENV=production

# Run locally with specific org and environment
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging
```

### Deployment Scripts

```bash
# Build only
./scripts/build_org.sh rescuenet staging

# Deploy only (requires prior build)
./scripts/deploy_org.sh rescuenet staging

# Build + Deploy (combined)
./scripts/release_org.sh rescuenet staging
```

**Important:** Production deployments require manual confirmation. Scripts default to staging to prevent accidents.

### Deployment Workflows

**Two GitHub Actions workflows exist:**

1. **Multi-Tenant Workflow** (`.github/workflows/deploy-multi-tenant.yml`)
   - **Status:** Inactive (no matching branches)
   - **Purpose:** Automated deployments for develop→staging, main→production
   - **Usage:** Manual dispatch or push to configured branches
   - **Features:** Supports multiple orgs, environment-specific builds

2. **Legacy Workflow** (`.github/workflows/firebase-hosting-merge.yml`)
   - **Status:** Active (triggers on micha-1 branch)
   - **Purpose:** Quick production deployments during development
   - **Target:** rescuenet-7733b (production)
   - **Environment:** Production builds with proper configuration

**Current Deployment Method:**
- Production: Push to `micha-1` branch (legacy workflow)
- Staging: Manual deployment via scripts

**To Activate Multi-Tenant Workflow:**
Update branch triggers in `deploy-multi-tenant.yml` to match your branch strategy.

### Adding New Organization

See `ONBOARDING_ORG.md` for comprehensive step-by-step guide.

**Quick overview:**
1. Create Firebase projects: `<org_id>-staging` and `<org_id>-production`
2. Generate Firebase options:
   ```bash
   flutterfire configure --project=<org_id>-staging --out=lib/config/firebase_options_<org_id>_staging.dart
   flutterfire configure --project=<org_id>-production --out=lib/config/firebase_options_<org_id>_production.dart
   ```
3. Update class names in generated files to avoid conflicts (e.g., `<OrgId>StagingFirebaseOptions`)
4. Add to `lib/config/org_registry.dart` with imports and config entry
5. Create `.firebaserc_<org_id>_staging` and `.firebaserc_<org_id>_production`
6. Update CI/CD matrix in `.github/workflows/deploy-multi-tenant.yml`
7. Test thoroughly in staging before production deployment

### Configuration Files

- **Organization configs**: `lib/config/org_config.dart` (Freezed model)
- **Organization registry**: `lib/config/org_registry.dart` (pure functions)
- **Firebase options**: `lib/config/firebase_options_<org>_<env>.dart` (generated by FlutterFire CLI)
- **Firebase RC files**: `.firebaserc_<org>_<env>` (Firebase project mappings)
- **Organization provider**: `lib/config/org_provider.dart` (Riverpod provider for UI branding)

### Branding Support

Organizations can have custom:
- Display name
- Small and large logo variants (both required)
- Primary brand color
- Feature flags (for org-specific functionality)

Access in UI via Riverpod:
```dart
final org = ref.watch(currentOrgProvider);
Text('Welcome to ${org.name}');
```

### Logo Configuration

Each organization MUST provide two logo variants:
- **smallLogoAssetPath**: Compact logo for navigation drawer, headers (recommended: 80px height)
- **largeLogoAssetPath**: Full logo for login screens, PDFs, prominent display

Both fields are required (non-nullable) in `OrgConfig`. No fallbacks exist - missing assets will cause immediate failures in development.

**Usage in UI:**
```dart
// Small logo (navigation, headers)
const OrgLogo.small()

// Large logo (login, splash, prominent display)
const OrgLogo.large()
```

**Logo widget automatically:**
- Reads current org from `currentOrgProvider`
- Selects appropriate size variant
- No fallback logic - fails fast if misconfigured

### Email Domain Restrictions

Each organization can restrict user registration by email domain.

**Configuration in `lib/config/org_registry.dart`:**
```dart
OrgConfig(
  id: 'rescuenet',
  name: 'RescueNet',
  allowedEmailDomains: ['rescuenet.net'],  // Restrict to these domains
  whitelistedEmails: ['dev@gmail.com'],     // Individual exceptions
  // ...
)
```

**Behavior:**
- Empty `allowedEmailDomains` = no restrictions
- `whitelistedEmails` bypass domain restrictions
- Case-insensitive matching
- Validation happens client-side during registration

**Implementation:**
- Validator: `lib/utils/email_validator.dart` (pure function)
- UI integration: `lib/ui/auth_page/login_register_page.dart`
- Config model: `lib/config/org_config.dart`