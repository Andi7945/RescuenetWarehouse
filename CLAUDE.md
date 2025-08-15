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
Uses `pdf` package for:
- Packing lists
- Container labels  
- Summary reports
Located in `lib/pdf/`

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