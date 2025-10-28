# Add Environment Indicator to AppBar

## Overview
Add a small visual indicator to the AppBar showing whether the app is running in staging or production environment. This prevents accidental changes in the wrong environment.

**Visual Design:**
- **Staging**: Small red chip with white text "STAGING"
- **Production**: Small green chip with white text "PROD"
- Positioned next to the title in the AppBar
- Compact size (~24px height) to minimize space usage

## Architecture Principles
- **SRP**: Separate environment config from UI presentation
- **KISS**: Simple pure functions for config, minimal widget logic
- **Modularity**: Reusable components, easy to remove if needed
- **Pure functions**: Environment config logic has no side effects

## File Structure

```
lib/
├── config/
│   └── environment_config.dart   (NEW - enum + pure config function)
├── widgets/
│   └── rescue_app_bar.dart       (NEW - custom AppBar with env indicator)
└── [all page files]              (MODIFY - replace AppBar with RescueAppBar)
```

## Implementation Steps

### Step 1: Create Environment Configuration
**File**: `lib/config/environment_config.dart`

**Purpose**: Define environment types and chip styling configuration using pure functions.

**Implementation**:
```dart
import 'package:flutter/material.dart';

/// Environment types for the application.
enum Environment {
  staging,
  production,
}

/// Configuration for environment indicator chip.
class EnvironmentChipConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const EnvironmentChipConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

/// Pure function: Returns environment chip configuration based on environment string.
///
/// Defaults to staging for safety (shows warning if unknown environment).
EnvironmentChipConfig getEnvironmentChipConfig(String environment) {
  switch (environment.toLowerCase()) {
    case 'production':
      return const EnvironmentChipConfig(
        label: 'PROD',
        backgroundColor: Color(0xFF2E7D32), // Material green 800
        textColor: Colors.white,
      );
    case 'staging':
    default:
      return const EnvironmentChipConfig(
        label: 'STAGING',
        backgroundColor: Color(0xFFC62828), // Material red 800
        textColor: Colors.white,
      );
  }
}
```

**Key Points**:
- Pure function with no side effects
- Defaults to staging (safer to show warning than not)
- Uses Material color palette for consistency
- Simple data class for configuration

---

### Step 2: Create Custom AppBar Widget
**File**: `lib/widgets/rescue_app_bar.dart`

**Purpose**: Drop-in replacement for AppBar that includes environment indicator.

**Implementation**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment_config.dart';
import '../config/org_provider.dart';

/// Custom AppBar that displays an environment indicator chip.
///
/// Drop-in replacement for Flutter's AppBar. Automatically adds a small
/// colored chip next to the title showing the current environment (STAGING/PROD).
///
/// Usage:
/// ```dart
/// RescueAppBar(
///   title: 'My Page',
///   actions: [MyAction()],
/// )
/// ```
class RescueAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const RescueAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(currentEnvironmentProvider);
    final config = getEnvironmentChipConfig(environment);

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          const SizedBox(width: 12),
          _EnvironmentChip(config: config),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Small chip displaying the environment name.
class _EnvironmentChip extends StatelessWidget {
  final EnvironmentChipConfig config;

  const _EnvironmentChip({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
```

**Key Points**:
- Implements `PreferredSizeWidget` (required for AppBar replacement)
- Uses Riverpod to read environment
- Pure separation: config logic vs presentation
- Private `_EnvironmentChip` widget (SRP)
- Compact design with small font and padding

---

### Step 3: Find All AppBar Usages
**Command**: Use Grep to find all files using AppBar

```bash
grep -r "AppBar(" lib/ui/ lib/features/ --files-with-matches
```

**Expected files** (~15-20 files based on earlier glob):
- All page files in `lib/ui/`
- All feature pages in `lib/features/`

---

### Step 4: Replace AppBar with RescueAppBar
**For each file found in Step 3:**

1. Add import at top of file:
   ```dart
   import 'package:rescuenet_warehouse/widgets/rescue_app_bar.dart';
   ```

2. Replace AppBar constructor:
   - **Find**: `AppBar(`
   - **Replace**: `RescueAppBar(`

3. Simplify title parameter:
   - **Old**: `title: const Text("My Page")`
   - **New**: `title: 'My Page'`

   (RescueAppBar takes String, not Widget)

**Example transformation**:
```dart
// BEFORE
AppBar(
  title: const Text("Container with content"),
  actions: [ContainerChooserAction()],
)

// AFTER
RescueAppBar(
  title: "Container with content",
  actions: [ContainerChooserAction()],
)
```

**Migration Strategy**:
- Start with main pages (ContainerWithContentPage, ItemOverviewPage)
- Then migrate remaining pages
- No need to migrate all at once (backwards compatible)

---

### Step 5: Handle Edge Cases

**Files that may need special attention:**

1. **Login/Auth pages**: May want to skip environment indicator
   - Decision: Show it everywhere for consistency (even on login)
   - Reasoning: Useful to know which environment you're logging into

2. **Pages with custom AppBar styling**:
   - Check if any pages customize AppBar properties
   - May need to extend RescueAppBar with additional properties (backgroundColor, elevation, etc.)
   - Look for: `AppBar(backgroundColor: ...)`, `AppBar(elevation: ...)`

3. **Pages without AppBar**:
   - Some pages may not have AppBar
   - No action needed for these

**If RescueAppBar needs more properties**, add them as optional parameters:
```dart
class RescueAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;  // ADD if needed
  final double? elevation;        // ADD if needed
  // ... etc
```

---

### Step 6: Testing

**Manual testing**:
```bash
# Test staging
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging
```
- ✅ Red "STAGING" chip appears in AppBar
- ✅ Chip is compact and doesn't overflow
- ✅ All pages show the indicator

```bash
# Test production
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=production
```
- ✅ Green "PROD" chip appears in AppBar
- ✅ Navigation between pages works
- ✅ AppBar actions still function

**Visual checks**:
- Chip doesn't overlap with title text
- Chip doesn't cause AppBar to overflow on mobile
- Colors are clearly distinguishable (red vs green)

**No unit tests needed**:
- This is primarily UI presentation
- Pure functions are trivial (enum switch)
- Manual testing is sufficient for startup pace
- Can add tests later if bugs emerge

---

### Step 7: Verification

**Final checklist**:
- [ ] `lib/config/environment_config.dart` created with pure function
- [ ] `lib/widgets/rescue_app_bar.dart` created
- [ ] All AppBar usages replaced with RescueAppBar
- [ ] Staging build shows red "STAGING" chip
- [ ] Production build shows green "PROD" chip
- [ ] No console errors or warnings
- [ ] All page navigation works correctly

---

## Rollback Plan

If issues arise:
1. Revert changes to page files (git checkout)
2. Delete new files: `environment_config.dart` and `rescue_app_bar.dart`
3. All pages will use standard AppBar again

---

## Future Enhancements (Optional)

If needed later:
- Add tooltip on hover: "You are in staging environment"
- Add environment-specific behaviors (e.g., disable certain actions in staging)
- Extend RescueAppBar to support all AppBar properties
- Add environment indicator to drawer header

---

## Estimated Effort
- Step 1-2: 10 minutes (create new files)
- Step 3-4: 15-20 minutes (find and replace ~20 files)
- Step 5: 5 minutes (edge case review)
- Step 6: 10 minutes (manual testing)

**Total: ~45 minutes**

---

## Notes for Subagent Execution

**File search**:
- Use `Grep` tool with pattern `AppBar\(` to find all usages
- Search in `lib/ui/` and `lib/features/` directories

**File editing**:
- Use `Read` to read each file before editing
- Use `Edit` tool for precise replacements
- Check for `const Text(...)` pattern in title parameter

**Testing**:
- Use `Bash` tool to run flutter commands
- Verify no build errors
- Document any files that couldn't be migrated automatically

**Edge cases to watch**:
- Files with multiple AppBar instances
- Files with heavily customized AppBar
- Files where title is not a Text widget
