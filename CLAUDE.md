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
Uses **Riverpod** with code generation. State notifiers use `@riverpod` annotations.

**Architecture Patterns:**
- **Feature-based structure**: Domain features organized in `lib/features/` with repository, business logic, providers, and UI
- **Legacy structure**: Some notifiers remain in `lib/state/` (being gradually migrated to feature folders)
- **Data providers**: Firebase collection access in repository layer
- **Business logic separation**: Pure functions separated from state management
- **Fine-grained reactivity**: Specialized stream providers for targeted rebuilds

Key patterns:
- Repository pattern with abstract interfaces for data access
- Dependency injection via Riverpod providers
- Pure business logic functions separated from UI
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

### Work Log Feature

Located in `lib/features/worklog/` with feature-based architecture following clean separation of concerns.

**Architecture:**
- **repository/** - Repository pattern with abstract interface and implementations (Firebase, Mock)
- **business_logic/notifiers/** - Riverpod state notifiers for different use cases
- **business_logic/aggregation.dart** - Pure functions for data aggregation
- **providers/** - Dependency injection configuration
- **ui/** - UI pages and components
- **worklog.dart** - Public API barrel file

**Key Principles:**
- Repository pattern abstracts data source (Firebase/Mock)
- Fine-grained reactivity: Specialized providers rebuild only when relevant data changes
- Pure business logic separated from state management
- Clear separation between data layer, business logic, and UI

**Fine-Grained State Notifiers:**
- `AllWorkLogsNotifier`: All work log entries (full collection)
- `WorkLogsByDateRangeNotifier`: Logs within specific date range
- `WorkLogsByUserNotifier`: Logs for specific user
- `WorkLogsByItemNotifier`: Logs for specific item (audit trail)
- `WorkLogsByContainerNotifier`: Logs for specific container (audit trail)
- `WorkLogSinceNotifier`: Logs since a specific date (filtered view)
- `WorkLogDateFilterNotifier`: Date filter state for UI

**Repository Interface:**
```dart
abstract class WorkLogRepository {
  Stream<List<LogEntry>> watchWorkLogs();
  Stream<List<LogEntry>> watchWorkLogsByDateRange(DateTime start, DateTime end);
  Stream<List<LogEntry>> watchWorkLogsByUser(String userId);
  Stream<List<LogEntry>> watchWorkLogsByItem(String itemId);
  Stream<List<LogEntry>> watchWorkLogsByContainer(String containerId);
  // ... create, update, delete methods
}
```

**Usage:**
```dart
// Import the barrel file
import 'package:rescuenet_warehouse/features/worklog/worklog.dart';

// Watch work logs for specific container (fine-grained - only rebuilds when this container's logs change)
final containerLogs = ref.watch(workLogsByContainerProvider(containerId));

// Watch work logs for date range (fine-grained - only rebuilds when logs in this range change)
final todayLogs = ref.watch(workLogsByDateRangeProvider(startDate, endDate));

// Aggregate daily changes using pure function
final summary = sumDailyChanges(logEntries);
```

**Benefits:**
- Fine-grained reactivity prevents unnecessary rebuilds
- Repository pattern enables easy testing with mock data
- Pure business logic functions are reusable and testable
- Clear API surface via barrel file
- Complete audit trail with specialized query capabilities

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

### Deployment Safety Features

All deployment scripts include automatic verification:
- ✅ **Single-config builds**: Each build contains only its target Firebase config
- ✅ Compiled bundle verified for correct project ID
- ✅ Build manifest tracks org, env, timestamp, git commit
- ✅ Deployment blocked if manifest doesn't match
- ✅ Stale builds (>48h) generate warnings
- ✅ Production deploys require typing exact project ID
- ✅ All deployments logged to `deployments.log`

**Security Model:**
1. Build-time code generation creates `org_registry.dart` with only target Firebase config
2. Flutter tree-shaking removes unused Firebase configs
3. Each build physically cannot connect to wrong Firebase projects
4. Verification confirms ONLY expected config exists in bundle
5. Wrong deployments are impossible, not just caught

**Verification Process:**
1. Build script generates single-config `org_registry.dart` from template
2. Flutter builds with only target Firebase config included
3. Verifies compiled JavaScript contains ONLY correct project ID
4. Creates `.build-manifest.json` with metadata
5. Deploy script re-verifies manifest and bundle before deployment
6. Logs deployment to audit trail

**If verification fails:**
- Build will abort with clear error message
- Shows expected vs actual project ID(s)
- If multiple configs found, explains security risk
- Build directory will not be created
- Deployment will be blocked

**Audit Log:**
All deployments are logged to `deployments.log` (tracked in git) with:
- Timestamp, user, org, environment, project ID, git commit

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

### Build System Changes (2025-10-28)

The app now uses single-config builds for security:
- `org_registry.dart` is generated at build time (don't edit directly)
- Edit `org_registry.dart.template` to modify org configurations
- Each build contains only its target Firebase config
- See `org_registry.dart.backup` for original multi-config version

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
4. Add to `lib/config/org_registry.dart.template` with imports and config entry
5. Create `.firebaserc_<org_id>_staging` and `.firebaserc_<org_id>_production`
6. Update CI/CD matrix in `.github/workflows/deploy-multi-tenant.yml`
7. Test thoroughly in staging before production deployment

### Configuration Files

- **Organization configs**: `lib/config/org_config.dart` (Freezed model)
- **Organization registry**: `lib/config/org_registry.dart` (generated at build time from template)
- **Organization registry template**: `lib/config/org_registry.dart.template` (edit this for org changes)
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

**Configuration in `lib/config/org_registry.dart.template`:**
```dart
OrgConfig(
  id: 'rescuenet',
  name: 'RescueNet',
  allowedEmailDomains: ['rescuenet.net'],  // Restrict to these domains
  whitelistedEmails: ['dev@gmail.com'],     // Individual exceptions
  // ...
)
```

**Note:** Remember to edit the template file, not the generated `org_registry.dart`.

**Behavior:**
- Empty `allowedEmailDomains` = no restrictions
- `whitelistedEmails` bypass domain restrictions
- Case-insensitive matching
- Validation happens client-side during registration

**Implementation:**
- Validator: `lib/utils/email_validator.dart` (pure function)
- UI integration: `lib/ui/auth_page/login_register_page.dart`
- Config model: `lib/config/org_config.dart`