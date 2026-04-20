# Work Log Feature Refactoring - Implementation Plan

**Objective:** Refactor work log feature into `lib/features/worklog/` with clear separation of concerns following feature-based architecture.

**Status:** Ready for implementation
**Created:** 2025-12-16
**Estimated Duration:** 2-3 hours
**Risk Level:** Low (well-isolated feature, comprehensive testing available)

---

## Architecture Overview

### Target Structure

```
lib/features/worklog/
├── worklog.dart                              # Barrel file (public API)
├── repository/
│   ├── work_log_repository.dart              # Abstract interface
│   ├── firebase_work_log_repository.dart     # Production implementation
│   └── mock_work_log_repository.dart         # Test implementation
├── business_logic/
│   ├── aggregation.dart                      # Pure functions (sumDailyChanges, etc.)
│   └── notifiers/
│       ├── all_work_logs_notifier.dart
│       ├── work_log_notifier.dart
│       ├── work_log_since_notifier.dart
│       ├── work_log_date_filter_notifier.dart
│       ├── work_logs_by_date_range_notifier.dart
│       ├── work_logs_by_user_notifier.dart
│       ├── work_logs_by_item_notifier.dart
│       └── work_logs_by_container_notifier.dart
├── providers/
│   └── work_log_providers.dart               # Riverpod DI configuration
└── ui/
    ├── work_log_page.dart
    └── components/
        ├── work_log_page_body_all.dart
        ├── work_log_page_body_from_date.dart
        ├── work_log_page_all_single_date.dart
        ├── work_log_page_entry.dart
        └── work_log_ui_helpers.dart          # UI helper functions

test/features/worklog/
├── repository/
│   └── work_log_repository_rebuild_test.dart
└── business_logic/
    └── work_log_provider_rebuild_test.dart
```

### Design Principles

- **SRP:** Each file has single, clear responsibility
- **KISS:** No premature abstractions, straightforward structure
- **Modularity:** Feature is self-contained and testable in isolation
- **Pure Functions:** Business logic extracted as pure functions for reusability
- **Encapsulation:** Repository owns data access implementation details

---

## Phase 1: Pre-Migration Validation

### Step 1.1: Verify Current State

**Objective:** Ensure clean starting point

```bash
# Check git status
git status

# Verify no uncommitted changes in work log files
git diff lib/repositories/work_log_repository.dart
git diff lib/state/all_work_logs_notifier.dart
git diff lib/ui/work_log_page/
```

**Success Criteria:**
- No pending changes in work log related files OR changes are committed
- All tests passing: `flutter test test/repositories/work_log_repository_rebuild_test.dart test/state/work_log_provider_rebuild_test.dart`

---

## Phase 2: Create Directory Structure

### Step 2.1: Create Feature Directories

```bash
mkdir -p lib/features/worklog/repository
mkdir -p lib/features/worklog/business_logic/notifiers
mkdir -p lib/features/worklog/providers
mkdir -p lib/features/worklog/ui/components
mkdir -p test/features/worklog/repository
mkdir -p test/features/worklog/business_logic
```

**Success Criteria:**
- All directories exist
- Use `ls -R lib/features/worklog/` to verify structure

---

## Phase 3: Move Repository Layer

### Step 3.1: Move Repository Files

**Use `git mv` to preserve history:**

```bash
# Move abstract interface
git mv lib/repositories/work_log_repository.dart \
       lib/features/worklog/repository/work_log_repository.dart

# Move Firebase implementation
git mv lib/repositories/impl/firebase/firebase_work_log_repository.dart \
       lib/features/worklog/repository/firebase_work_log_repository.dart

# Move Mock implementation
git mv lib/repositories/impl/mock/mock_work_log_repository.dart \
       lib/features/worklog/repository/mock_work_log_repository.dart
```

**Success Criteria:**
- Git shows renames (not deletes + adds)
- Verify: `git status` should show `renamed:` entries

### Step 3.2: Update Repository Imports

**Files to update:**
- `lib/features/worklog/repository/firebase_work_log_repository.dart`
- `lib/features/worklog/repository/mock_work_log_repository.dart`

**Changes needed:**

1. **Update interface import in implementations:**
   ```dart
   // OLD
   import 'package:rescuenetwarehouse/repositories/work_log_repository.dart';

   // NEW
   import 'package:rescuenetwarehouse/features/worklog/repository/work_log_repository.dart';
   ```

2. **Verify model imports remain unchanged** (staying in `lib/models/`):
   ```dart
   import 'package:rescuenetwarehouse/models/log_entry.dart'; // No change
   ```

**Success Criteria:**
- No import errors when running: `dart analyze lib/features/worklog/repository/`

### Step 3.3: Move Firestore Collection Definition

**Objective:** Encapsulate data access details in repository layer

**Source file:** `lib/db/firebase.dart`

**Action:**

1. **Open `lib/db/firebase.dart`** and locate:
   ```dart
   final workLogCollection = FirebaseFirestore.instance
       .collection("work_log")
       .withConverter<LogEntry>(
         fromFirestore: (snapshot, _) => LogEntry.fromJson(snapshot.data()!),
         toFirestore: (LogEntry type, _) => type.toJson(),
       );
   ```

2. **Add private constant to `firebase_work_log_repository.dart`:**
   ```dart
   class FirebaseWorkLogRepository implements WorkLogRepository {
     // Add at top of class (after imports, before methods)
     static final _workLogCollection = FirebaseFirestore.instance
         .collection("work_log")
         .withConverter<LogEntry>(
           fromFirestore: (snapshot, _) => LogEntry.fromJson(snapshot.data()!),
           toFirestore: (LogEntry type, _) => type.toJson(),
         );

     // Update all references in the class
     // OLD: workLogCollection.snapshots()
     // NEW: _workLogCollection.snapshots()
   ```

3. **Use find/replace in `firebase_work_log_repository.dart`:**
   - Find: `workLogCollection`
   - Replace: `_workLogCollection`
   - Verify: Should find 15-20 occurrences (all method implementations)

4. **Remove from `lib/db/firebase.dart`:**
   - Delete the `workLogCollection` definition and its export

5. **Search for external usage:**
   ```bash
   grep -r "workLogCollection" lib/ --exclude-dir=features
   ```
   - Should return no results (only used by repository)

**Success Criteria:**
- `firebase_work_log_repository.dart` compiles without errors
- No references to global `workLogCollection` remain outside repository
- `dart analyze lib/features/worklog/repository/firebase_work_log_repository.dart` passes

---

## Phase 4: Move State Management Layer

### Step 4.1: Move Notifier Files

```bash
# Move all notifiers to new location
git mv lib/state/all_work_logs_notifier.dart \
       lib/features/worklog/business_logic/notifiers/all_work_logs_notifier.dart

git mv lib/state/work_log_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_log_notifier.dart

git mv lib/state/work_log_since_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_log_since_notifier.dart

git mv lib/state/work_log_date_filter_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_log_date_filter_notifier.dart

git mv lib/state/work_logs_by_date_range_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_logs_by_date_range_notifier.dart

git mv lib/state/work_logs_by_user_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_logs_by_user_notifier.dart

git mv lib/state/work_logs_by_item_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_logs_by_item_notifier.dart

git mv lib/state/work_logs_by_container_notifier.dart \
       lib/features/worklog/business_logic/notifiers/work_logs_by_container_notifier.dart
```

**Success Criteria:**
- 8 notifier files moved with git history preserved
- Verify: `git status` shows renames

### Step 4.2: Extract Business Logic to Pure Functions

**Objective:** Extract `sumDailyChanges` and helpers from UI helper file into reusable pure functions

**Source:** `lib/ui/work_log_page/work_log_helper.dart`

**Action:**

1. **Create new file:** `lib/features/worklog/business_logic/aggregation.dart`

2. **Extract pure logic:**
   ```dart
   import 'package:rescuenetwarehouse/models/log_entry.dart';
   import 'package:rescuenetwarehouse/models/log_entry_summed.dart';

   /// Aggregates multiple log entries for the same item/container/day into single summed entries.
   ///
   /// Groups by (itemId, containerId) and sums the count values.
   /// User is taken from the first entry in each group.
   ///
   /// This is a pure function - no side effects, deterministic output.
   List<LogEntrySummed> sumDailyChanges(List<LogEntry> entries) {
     final Map<_ItemAndContainer, _CountAndUser> map = {};

     for (final entry in entries) {
       final key = _ItemAndContainer(entry.itemId, entry.containerId);
       if (map.containsKey(key)) {
         map[key]!.count += entry.count;
       } else {
         map[key] = _CountAndUser(entry.count, entry.user);
       }
     }

     return map.entries.map((entry) {
       return LogEntrySummed(
         itemId: entry.key.itemId,
         containerId: entry.key.containerId,
         count: entry.value.count,
         user: entry.value.user,
       );
     }).toList();
   }

   /// Private helper class for aggregation grouping
   class _ItemAndContainer {
     final String itemId;
     final String containerId;

     _ItemAndContainer(this.itemId, this.containerId);

     @override
     bool operator ==(Object other) =>
         identical(this, other) ||
         other is _ItemAndContainer &&
             runtimeType == other.runtimeType &&
             itemId == other.itemId &&
             containerId == other.containerId;

     @override
     int get hashCode => itemId.hashCode ^ containerId.hashCode;
   }

   /// Private helper class for count and user tracking
   class _CountAndUser {
     int count;
     final String user;

     _CountAndUser(this.count, this.user);
   }
   ```

3. **Update notifiers to import aggregation logic:**

   In `work_log_notifier.dart` and `work_log_since_notifier.dart`:
   ```dart
   // ADD import
   import 'package:rescuenetwarehouse/features/worklog/business_logic/aggregation.dart';

   // Use the pure function
   final summed = sumDailyChanges(entriesForDate);
   ```

**Success Criteria:**
- `aggregation.dart` contains only pure functions (no UI, no state, no side effects)
- Can be tested in isolation without Flutter Test environment
- Notifiers successfully use imported `sumDailyChanges`

### Step 4.3: Update Notifier Imports

**Files to update:** All 8 notifier files

**Import changes needed:**

1. **Update repository imports:**
   ```dart
   // OLD
   import 'package:rescuenetwarehouse/repositories/work_log_repository.dart';
   import 'package:rescuenetwarehouse/repositories/repository_providers.dart';

   // NEW
   import 'package:rescuenetwarehouse/features/worklog/repository/work_log_repository.dart';
   import 'package:rescuenetwarehouse/features/worklog/providers/work_log_providers.dart';
   ```

2. **Add aggregation import (where needed):**
   ```dart
   import 'package:rescuenetwarehouse/features/worklog/business_logic/aggregation.dart';
   ```

3. **Update cross-notifier imports:**
   ```dart
   // OLD
   import 'package:rescuenetwarehouse/state/all_work_logs_notifier.dart';

   // NEW
   import 'package:rescuenetwarehouse/features/worklog/business_logic/notifiers/all_work_logs_notifier.dart';
   ```

4. **Model imports remain unchanged:**
   ```dart
   import 'package:rescuenetwarehouse/models/log_entry.dart'; // No change
   ```

**Success Criteria:**
- All notifier files compile: `dart analyze lib/features/worklog/business_logic/notifiers/`
- Riverpod part files will regenerate in next phase

---

## Phase 5: Create Provider Configuration

### Step 5.1: Create Unified Provider File

**Create:** `lib/features/worklog/providers/work_log_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenetwarehouse/features/worklog/repository/work_log_repository.dart';
import 'package:rescuenetwarehouse/features/worklog/repository/firebase_work_log_repository.dart';
import 'package:rescuenetwarehouse/features/worklog/repository/mock_work_log_repository.dart';

part 'work_log_providers.g.dart';

// Repository DI Configuration
@riverpod
WorkLogRepository workLogRepository(WorkLogRepositoryRef ref) {
  // Check if we should use mock (for testing)
  const shouldUseMock = bool.fromEnvironment('USE_MOCK_REPOSITORIES', defaultValue: false);

  if (shouldUseMock) {
    return MockWorkLogRepository();
  } else {
    return FirebaseWorkLogRepository();
  }
}
```

**Success Criteria:**
- File created with correct structure
- Ready for build_runner code generation

### Step 5.2: Update Repository Provider Usage

**Remove from:** `lib/repositories/repository_providers.dart`

Delete the `workLogRepositoryProvider` definition (moving to new location).

**Update external consumers:**

1. **Assignment Service** (`lib/services/assignment/assignment_service.dart`):
   ```dart
   // OLD
   import 'package:rescuenetwarehouse/repositories/repository_providers.dart';

   // NEW
   import 'package:rescuenetwarehouse/features/worklog/providers/work_log_providers.dart';
   ```

2. **Find all usages:**
   ```bash
   grep -r "workLogRepositoryProvider" lib/ --exclude-dir=features
   ```
   Update any remaining references.

**Success Criteria:**
- No duplicate provider definitions
- External consumers updated

---

## Phase 6: Move UI Layer

### Step 6.1: Move UI Files

```bash
# Move main page
git mv lib/ui/work_log_page/work_log_page.dart \
       lib/features/worklog/ui/work_log_page.dart

# Move components
git mv lib/ui/work_log_page/work_log_page_body_all.dart \
       lib/features/worklog/ui/components/work_log_page_body_all.dart

git mv lib/ui/work_log_page/work_log_page_body_from_date.dart \
       lib/features/worklog/ui/components/work_log_page_body_from_date.dart

git mv lib/ui/work_log_page/work_log_page_all_single_date.dart \
       lib/features/worklog/ui/components/work_log_page_all_single_date.dart

git mv lib/ui/work_log_page/work_log_page_entry.dart \
       lib/features/worklog/ui/components/work_log_page_entry.dart

git mv lib/ui/work_log_page/work_log_helper.dart \
       lib/features/worklog/ui/components/work_log_ui_helpers.dart
```

**Success Criteria:**
- 6 UI files moved
- Old directory can be removed: `rmdir lib/ui/work_log_page`

### Step 6.2: Update UI Imports

**Files to update:** All 6 UI files

**Import patterns:**

1. **Update state/notifier imports:**
   ```dart
   // OLD
   import 'package:rescuenetwarehouse/state/work_log_notifier.dart';
   import 'package:rescuenetwarehouse/state/work_log_date_filter_notifier.dart';

   // NEW
   import 'package:rescuenetwarehouse/features/worklog/business_logic/notifiers/work_log_notifier.dart';
   import 'package:rescuenetwarehouse/features/worklog/business_logic/notifiers/work_log_date_filter_notifier.dart';
   ```

2. **Update component imports:**
   ```dart
   // OLD
   import 'work_log_page_body_all.dart';

   // NEW
   import 'package:rescuenetwarehouse/features/worklog/ui/components/work_log_page_body_all.dart';
   ```

3. **Update helper imports in `work_log_ui_helpers.dart`:**
   ```dart
   // Remove or comment out the now-extracted business logic
   // sumDailyChanges and helper classes moved to aggregation.dart

   // Keep only UI helper functions: header(), item()
   ```

4. **Add aggregation import where needed:**
   ```dart
   // In files that were using sumDailyChanges from helpers
   import 'package:rescuenetwarehouse/features/worklog/business_logic/aggregation.dart';
   ```

**Success Criteria:**
- All UI files compile
- No dangling references to old helper functions

### Step 6.3: Update Main App Entry Point

**File:** `lib/main.dart`

```dart
// OLD
import 'package:rescuenetwarehouse/ui/work_log_page/work_log_page.dart';
import 'package:rescuenetwarehouse/state/all_work_logs_notifier.dart';

// NEW
import 'package:rescuenetwarehouse/features/worklog/ui/work_log_page.dart';
import 'package:rescuenetwarehouse/features/worklog/business_logic/notifiers/all_work_logs_notifier.dart';
```

**Success Criteria:**
- App compiles
- Route still works

---

## Phase 7: Create Barrel File (Public API)

### Step 7.1: Create Feature Barrel File

**Create:** `lib/features/worklog/worklog.dart`

```dart
/// Work Log Feature
///
/// Public API for work log functionality including repository access,
/// state providers, and UI components.

library worklog;

// Repository
export 'repository/work_log_repository.dart';

// Providers (DI configuration)
export 'providers/work_log_providers.dart' show workLogRepositoryProvider;

// Business Logic - Notifier Providers (for UI consumption)
export 'business_logic/notifiers/all_work_logs_notifier.dart' show
    allWorkLogsNotifierProvider,
    allWorkLogsAsyncProvider;

export 'business_logic/notifiers/work_log_notifier.dart' show
    workLogNotifierProvider;

export 'business_logic/notifiers/work_log_since_notifier.dart' show
    workLogSinceNotifierProvider;

export 'business_logic/notifiers/work_log_date_filter_notifier.dart' show
    workLogDateFilterNotifierProvider;

export 'business_logic/notifiers/work_logs_by_date_range_notifier.dart' show
    workLogsByDateRangeProvider;

export 'business_logic/notifiers/work_logs_by_user_notifier.dart' show
    workLogsByUserProvider;

export 'business_logic/notifiers/work_logs_by_item_notifier.dart' show
    workLogsByItemProvider;

export 'business_logic/notifiers/work_logs_by_container_notifier.dart' show
    workLogsByContainerProvider;

// Business Logic - Pure Functions
export 'business_logic/aggregation.dart' show sumDailyChanges;

// UI
export 'ui/work_log_page.dart';
```

**Rationale:**
- Single import point for external features
- Explicitly exports only public API (hides internal implementation)
- Documents what's available from the feature
- Optional: Can add this gradually, not required for functionality

**Success Criteria:**
- File compiles
- Test import: `import 'package:rescuenetwarehouse/features/worklog/worklog.dart';`

---

## Phase 8: Move and Update Tests

### Step 8.1: Move Test Files

```bash
# Move repository tests
git mv test/repositories/work_log_repository_rebuild_test.dart \
       test/features/worklog/repository/work_log_repository_rebuild_test.dart

# Move state tests
git mv test/state/work_log_provider_rebuild_test.dart \
       test/features/worklog/business_logic/work_log_provider_rebuild_test.dart
```

### Step 8.2: Update Test Imports

**Both test files need updated imports:**

```dart
// OLD
import 'package:rescuenetwarehouse/repositories/work_log_repository.dart';
import 'package:rescuenetwarehouse/repositories/impl/mock/mock_work_log_repository.dart';
import 'package:rescuenetwarehouse/state/all_work_logs_notifier.dart';

// NEW - Can use barrel file
import 'package:rescuenetwarehouse/features/worklog/worklog.dart';

// OR use explicit imports
import 'package:rescuenetwarehouse/features/worklog/repository/work_log_repository.dart';
import 'package:rescuenetwarehouse/features/worklog/repository/mock_work_log_repository.dart';
import 'package:rescuenetwarehouse/features/worklog/business_logic/notifiers/all_work_logs_notifier.dart';
```

**Success Criteria:**
- Tests compile
- Ready to run after build_runner phase

---

## Phase 9: Regenerate Riverpod Code

### Step 9.1: Clean Old Generated Files

```bash
# Remove all old .g.dart files for moved notifiers
find lib/features/worklog -name "*.g.dart" -delete

# Clean build cache
flutter clean
```

### Step 9.2: Run Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected output:**
- New `.g.dart` files created in `lib/features/worklog/`
- No conflicts or errors
- All Riverpod providers regenerated with correct imports

**Common issues:**

1. **Part directive errors:**
   - Verify each notifier has: `part 'filename.g.dart';`
   - Verify filename matches exactly (case-sensitive)

2. **Import cycle errors:**
   - Check for circular dependencies between notifiers
   - Ensure clean dependency hierarchy

**Success Criteria:**
- Build completes without errors
- All `.g.dart` files generated in correct locations
- No warnings about missing parts

---

## Phase 10: Verification & Testing

### Step 10.1: Static Analysis

```bash
# Analyze entire feature
dart analyze lib/features/worklog/

# Should report no errors or warnings
```

### Step 10.2: Run Unit Tests

```bash
# Run work log specific tests
flutter test test/features/worklog/

# Expected: All tests pass
```

**If tests fail:**
- Check import paths in test files
- Verify mock repository still works
- Ensure Riverpod providers regenerated correctly

### Step 10.3: Run Full Test Suite

```bash
# Ensure no regressions in other features
flutter test
```

**Success Criteria:**
- All tests pass
- No new failures introduced

### Step 10.4: Manual UI Testing

**Start app:**
```bash
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging
```

**Test scenarios:**

1. **Navigate to Work Log page**
   - From main menu → "Work Log"
   - Page loads without errors

2. **View all logs**
   - Click "all" button
   - Logs displayed grouped by date
   - Container names shown correctly

3. **Filter by date**
   - Click date picker
   - Select past date
   - Only logs since date shown

4. **Create new work log** (indirect via assignment)
   - Go to container detail page
   - Modify item quantity
   - Return to work log page
   - Verify new log appears

5. **Verify aggregation logic**
   - Multiple changes to same item/container on same day
   - Should show single summed entry

**Success Criteria:**
- All features work identically to before refactoring
- No console errors
- No UI glitches

---

## Phase 11: Cleanup & Documentation

### Step 11.1: Remove Old Directories

```bash
# Verify directories are empty
ls lib/ui/work_log_page/      # Should not exist or be empty
ls lib/state/ | grep work_log  # Should return nothing

# Remove if empty (git will handle)
git status  # Verify no untracked files left behind
```

### Step 11.2: Update CLAUDE.md

**Add to Architecture section:**

```markdown
### Work Log Feature

Located in `lib/features/worklog/` following feature-based architecture.

**Structure:**
- **repository/** - Data access layer (abstract + Firebase + mock implementations)
- **business_logic/** - Pure functions (`aggregation.dart`) and Riverpod notifiers
- **providers/** - Dependency injection configuration
- **ui/** - Work log page and components

**Public API:** Import via `package:rescuenetwarehouse/features/worklog/worklog.dart`

**Key patterns:**
- Pure functions for business logic (e.g., `sumDailyChanges`)
- Repository pattern with interface abstraction
- Fine-grained Riverpod streams for optimized reactivity
- Append-only audit trail (work logs are side effects of assignments)
```

### Step 11.3: Verify Build Configuration

**Check:** `build.yaml`, `analysis_options.yaml`
- Should not need changes (feature-agnostic configuration)

---

## Phase 12: Final Validation & Commit

### Step 12.1: Pre-Commit Checklist

- [ ] All files moved with `git mv` (history preserved)
- [ ] All imports updated and verified
- [ ] Build runner completed successfully
- [ ] Static analysis passes (`dart analyze`)
- [ ] All unit tests pass (`flutter test`)
- [ ] Manual UI testing completed successfully
- [ ] No console errors or warnings
- [ ] Documentation updated (CLAUDE.md)
- [ ] No leftover files in old locations

### Step 12.2: Review Changes

```bash
# See full diff
git diff --staged

# Check file moves
git status

# Verify test coverage maintained
flutter test --coverage
```

### Step 12.3: Commit

```bash
git add -A

git commit -m "$(cat <<'EOF'
refactor: migrate work log feature to feature-based architecture

Reorganize work log functionality into `lib/features/worklog/` with clear
separation of concerns:

- **repository/**: Data access layer with Firebase and mock implementations
  - Moved Firestore collection definition into repository (encapsulation)
- **business_logic/**: Pure functions and Riverpod notifiers
  - Extracted `sumDailyChanges` to `aggregation.dart` for reusability
  - All 8 notifiers organized in `notifiers/` subdirectory
- **providers/**: Centralized DI configuration
- **ui/**: Work log page and components

Benefits:
- Improved modularity and testability
- Clear separation of concerns (SRP)
- Pure business logic can be reused outside UI context
- Self-contained feature with explicit public API (barrel file)
- Pattern can be replicated for other features

Breaking changes:
- Import paths updated across codebase
- Riverpod providers regenerated with new paths
- External consumers (assignment service, main.dart) updated

Testing:
- All existing tests passing
- Manual UI verification completed
- No regressions in other features

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

**Success Criteria:**
- Clean commit with descriptive message
- All changes included
- Ready for PR

---

## Rollback Plan

If critical issues are discovered post-implementation:

```bash
# Option 1: Revert commit (if not pushed)
git reset --hard HEAD~1

# Option 2: Create revert commit (if pushed)
git revert HEAD

# Option 3: Cherry-pick specific fixes
git checkout HEAD~1 -- lib/path/to/problem/file.dart
```

**Prevention:**
- Follow phases sequentially
- Test after each major phase
- Keep commit atomic (all changes in one commit)

---

## Post-Implementation Tasks

### Optional Enhancements (Future Work)

1. **Extract more features:**
   - Follow same pattern for `items`, `containers`, `assignments`
   - Use work log as reference implementation

2. **Add integration tests:**
   - Test full work log creation flow
   - Playwright E2E for UI interactions

3. **Performance monitoring:**
   - Verify fine-grained reactivity benefits
   - Add performance benchmarks

4. **Move models to feature:**
   - Consider `lib/features/worklog/domain/models/`
   - Evaluate if models are truly feature-specific vs shared

### Documentation Updates

- Update onboarding docs for new developers
- Add architecture decision record (ADR) explaining feature structure
- Update code review guidelines to enforce feature pattern

---

## Success Metrics

**Code Quality:**
- ✅ All files follow SRP (single responsibility)
- ✅ Business logic is pure functions (no side effects)
- ✅ Clear layering (repository → business logic → UI)
- ✅ No circular dependencies

**Maintainability:**
- ✅ Feature is self-contained (one folder)
- ✅ Public API documented (barrel file)
- ✅ Easy to understand scope and boundaries
- ✅ Tests co-located with implementation

**Performance:**
- ✅ No regressions (same build size, same runtime performance)
- ✅ Fine-grained reactivity preserved

**Developer Experience:**
- ✅ Clear where to add new work log features
- ✅ Easy to mock for testing other features
- ✅ Follows established Flutter/Riverpod patterns

---

## Execution Notes for Claude Code

**Recommended Approach:**

1. **Phase 1-2:** Execute directly (simple file operations)
2. **Phase 3-4:** Use general-purpose agent for file moves + import updates
3. **Phase 5:** Direct execution (simple file creation)
4. **Phase 6:** Use general-purpose agent (complex import rewrites)
5. **Phase 7:** Direct execution (barrel file creation)
6. **Phase 8:** Direct execution (test moves)
7. **Phase 9:** Direct execution (build runner)
8. **Phase 10-12:** Manual verification + commit

**Key Considerations:**

- Preserve git history with `git mv` (not copy + delete)
- Update imports systematically (search & replace)
- Run build_runner only after all moves complete
- Test incrementally after each phase
- Keep changes in single atomic commit

**Estimated Timeline:**
- Phases 1-5: 45 minutes
- Phase 6-8: 45 minutes
- Phase 9-10: 30 minutes
- Phase 11-12: 20 minutes
- **Total:** 2-3 hours including testing

---

**Plan ready for execution. Begin with Phase 1.**
