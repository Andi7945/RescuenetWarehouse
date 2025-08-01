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

### Building & Testing
```bash
# Build for web
flutter build web

# Run Playwright tests
cd test/puppeteer
npm test

# Run specific browser tests
cd test/puppeteer  
npx playwright test --project=chromium

# View test results
cd test/puppeteer
npx playwright show-report

# Analyze code
flutter analyze
```

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
Uses `pdf` package for:
- Packing lists
- Container labels  
- Summary reports
Located in `lib/pdf/`

## Testing

### Current Testing Strategy
The project uses a comprehensive testing approach to prevent regressions and ensure quality:

**Documentation:**
- `USE_CASES.md` - Defines all user workflows and business scenarios
- `TEST_SPECIFICATIONS.md` - Detailed test cases for each use case
- `TESTING_PROGRESS.md` - Implementation status and learnings

### Playwright E2E Tests
- Located in `test/puppeteer/`
- Tests use coordinate-based interaction (Flutter Canvas rendering)
- Mock Firebase backend loaded during testing
- Existing test files (legacy bug fixes):
  - `authentication.spec.js` - User registration/login
  - `container-persistence.spec.js` - Container data persistence
  - `item-quantity.spec.js` - Item assignment workflows
  - `container-types.spec.js` - Container types management
  - `integration.spec.js` - Cross-feature workflows

### Test Categories
1. **Use Case Tests** - Complete user workflows (UC01-UC09)
2. **Regression Tests** - Validate specific bug fixes remain resolved
3. **Integration Tests** - Cross-feature functionality
4. **Performance Tests** - Large dataset and concurrent user scenarios

### Test Implementation Notes
- Tests require coordinate-based clicking due to Flutter Canvas rendering
- Mock Firebase automatically loads when Playwright user agent detected
- Screenshots captured at key points for debugging
- Test data should be predictable and reproducible

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