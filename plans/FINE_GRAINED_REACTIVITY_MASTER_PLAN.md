# Fine-Grained Reactivity: Master Implementation Plan

## Executive Summary

**Problem:** Collection-level Firestore listeners cause ALL widgets to rebuild when ANY document changes, making multi-user collaboration slow and inefficient.

**Solution:** Implement fine-grained Riverpod family providers that listen to specific documents or filtered subsets.

**Impact:** 70-90% reduction in unnecessary widget rebuilds, enabling smooth multi-user collaboration.

---

## Implementation Order

Execute in this specific order due to dependencies:

### 1. **Assignments** (HIGHEST PRIORITY)
- **File:** `plans/FINE_GRAINED_REACTIVITY_ASSIGNMENTS.md`
- **Time:** ~11.5 hours
- **Impact:** HIGHEST - Most frequently updated, affects containers + items views
- **Why First:** Assignments are the hot path for multi-user updates

### 2. **Items** (HIGH PRIORITY)
- **File:** `plans/FINE_GRAINED_REACTIVITY_ITEMS.md`
- **Time:** ~11.5 hours
- **Impact:** HIGH - Frequently updated, displayed everywhere
- **Why Second:** Can leverage completed assignments providers for testing

### 3. **Containers** (MEDIUM PRIORITY)
- **File:** `plans/FINE_GRAINED_REACTIVITY_CONTAINERS.md`
- **Time:** ~11.5 hours
- **Impact:** MEDIUM - Moderate update frequency
- **Why Third:** Benefits from assignments + items already optimized

### 4. **Work Logs** (MEDIUM-LOW PRIORITY)
- **File:** `plans/FINE_GRAINED_REACTIVITY_WORK_LOGS.md`
- **Time:** ~8 hours
- **Impact:** MEDIUM - Query performance, not rebuild frequency
- **Why Last:** Background data, less user-facing impact

---

## Total Timeline

**Estimated Total:** ~42.5 hours (~1 week per repository)

**Recommended Cadence:**
- Week 1: Assignments (immediate impact)
- Week 2: Items (compounds improvements)
- Week 3: Containers (completes core entities)
- Week 4: Work Logs (polish + performance)

**Can be parallelized if multiple developers available.**

---

## Execution Strategy

### Per Repository (12-Step Process)

Each plan follows this proven pattern:

1. **Write Phase 1 Tests** - Repository stream efficiency tests
2. **Update Repository Interface** - Add fine-grained stream methods
3. **Implement Firebase Repository** - Use Firestore queries (`.where()`, `.doc()`)
4. **Implement Mock Repository** - Client-side filtering for tests
5. **Verify Phase 1 Tests Pass** - Repository layer works
6. **Write Phase 2 Tests** - Provider rebuild efficiency tests
7. **Create Family Providers** - Riverpod `@riverpod` family providers
8. **Run Code Generation** - `dart run build_runner build`
9. **Verify Phase 2 Tests Pass** - Provider layer works
10. **Migrate Widgets** - Update `ref.watch()` calls to use new providers
11. **Manual Testing** - Multi-user simulation, DevTools inspection
12. **Integration Testing** - Cross-provider rebuild verification

---

## Success Criteria (Per Repository)

- ✅ All Phase 1 tests pass (repository streams are fine-grained)
- ✅ All Phase 2 tests pass (providers rebuild correctly)
- ✅ Integration tests pass (cross-provider isolation works)
- ✅ Manual testing shows no unnecessary rebuilds
- ✅ DevTools shows reduced rebuild counts (80-90% reduction)
- ✅ No performance degradation
- ✅ Existing functionality unchanged

---

## Testing Strategy

### Comprehensive Coverage

Each repository plan includes:

**Phase 1: Repository Tests** (~3 tests per repository)
- Baseline behavior documentation
- Fine-grained stream emission tests
- Filtering correctness tests

**Phase 2: Provider Tests** (~3 tests per repository)
- Provider rebuild isolation
- Family parameter correctness
- Cross-provider non-interference

**Integration Tests** (~1 test per repository)
- Multi-provider scenarios
- Real-world use case simulation
- End-to-end rebuild verification

**Total Tests:** ~28 new tests across 4 repositories

### Test Philosophy

- **Don't overtest:** Focus on rebuild behavior, not business logic
- **Use pure functions:** Helper functions for test data creation
- **Mock repository parity:** Ensure mocks match Firebase behavior
- **Fast feedback:** Unit tests run in <1s, no Firebase dependencies

---

## Migration Guidelines

### What to Migrate

✅ **Migrate these patterns:**
```dart
// Single entity lookups
ref.watch(allItemsProvider).firstWhere(...)
→ ref.watch(itemByIdProvider(id))

// Filtered subsets
ref.watch(allAssignmentsProvider).where((a) => a.containerId == id)
→ ref.watch(assignmentsByContainerProvider(id))

// Status filters
ref.watch(allItemsProvider).where((i) => i.status == status)
→ ref.watch(itemsByStatusProvider(status))
```

❌ **Keep collection providers for:**
- Full list/grid views (users browse all entities)
- Search results across entire collection
- Export/import features
- Admin dashboards
- Reports requiring all data

### Backward Compatibility

- **Keep old providers:** `allItemsAsyncProvider` remains for full-list views
- **Additive changes:** New providers don't break existing code
- **Incremental migration:** Migrate widgets one at a time
- **Rollback safe:** Can revert widget changes without removing providers

---

## Technical Architecture

### Repository Layer (Pure Firestore)

**Before:**
```dart
Stream<List<Item>> watchItems() {
  return itemsCollection.snapshots().map(...);  // ALL items
}
```

**After:**
```dart
Stream<List<Item>> watchItems() {
  return itemsCollection.snapshots().map(...);  // Keep for full lists
}

Stream<Item?> watchItem(String id) {
  return itemsCollection.doc(id).snapshots().map(...);  // Single doc
}

Stream<List<Item>> watchItemsByStatus(OperationalStatus status) {
  return itemsCollection
    .where('operationalStatus', isEqualTo: status)
    .snapshots()
    .map(...);  // Filtered query
}
```

### Provider Layer (Riverpod Family)

**Before:**
```dart
@riverpod
class AllItems extends _$AllItems {
  @override
  Stream<List<Item>> build() {
    return ref.watch(itemRepositoryProvider).watchItems();
  }
}
```

**After:**
```dart
// Collection provider (keep for full lists)
@riverpod
class AllItems extends _$AllItems {
  @override
  Stream<List<Item>> build() {
    return ref.watch(itemRepositoryProvider).watchItems();
  }
}

// Family provider (single item)
@riverpod
class ItemById extends _$ItemById {
  @override
  Stream<Item?> build(String itemId) {
    return ref.watch(itemRepositoryProvider).watchItem(itemId);
  }
}

// Family provider (filtered subset)
@riverpod
class ItemsByStatus extends _$ItemsByStatus {
  @override
  Stream<List<Item>> build(OperationalStatus status) {
    return ref.watch(itemRepositoryProvider).watchItemsByStatus(status);
  }
}
```

### Widget Layer (Consumer Usage)

**Before:**
```dart
final items = ref.watch(allItemsAsyncProvider);
final item = items.valueOrNull?.firstWhere((i) => i.id == itemId);

return item != null ? ItemCard(item) : SizedBox();
```

**After:**
```dart
final item = ref.watch(itemByIdProvider(itemId));

return item.when(
  data: (item) => item != null ? ItemCard(item) : SizedBox(),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => ErrorWidget(e),
);
```

---

## Firestore Considerations

### Query Limitations

**Firestore `whereIn` limit:** Max 10 items
```dart
// For <=10 items
itemsCollection.where(FieldPath.documentId, whereIn: itemIds)

// For >10 items, use batching or client-side filtering
```

**Composite indexes required for:**
- Work logs by date range + order by timestamp
- Containers by location + order by number
- Items by status + order by name

### Index Management

Firebase will auto-suggest indexes via console errors. Create them:

1. **Click console error links** (easiest)
2. **Use `firestore.indexes.json`** (version controlled)
3. **Manual creation** in Firebase Console

Example `firestore.indexes.json` included in Work Logs plan.

---

## Performance Benchmarks

### Expected Improvements

| Scenario | Before | After | Improvement |
|----------|--------|-------|-------------|
| Update 1 item (100 total) | 100 widgets rebuild | 1-3 widgets rebuild | 97% reduction |
| Update 1 assignment | All container views rebuild | 1 container view rebuilds | 90% reduction |
| Filter items by status | Full collection + client filter | Firestore query only | 5-10x faster |
| Work log date range | Load all logs (1000+) | Load range (~50) | 20x faster |

### Metrics to Track

**Before Migration:**
- Stream emission count per update
- Provider rebuild count per update
- Widget build count per update
- Frame render time during updates

**After Migration:**
- Same metrics (should be 70-90% lower)
- Query response time for filtered views
- Firestore read count (should decrease)

---

## Common Pitfalls & Solutions

### Pitfall 1: Mock Repository Doesn't Match Firebase

**Problem:** Tests pass but production still over-emits.

**Solution:** Ensure mock repositories filter streams correctly:
```dart
// Good: Filters stream emissions
Stream<List<Item>> watchItemsByStatus(OperationalStatus status) {
  return _itemsController.stream.map(
    (items) => items.where((i) => i.status == status).toList()
  );
}

// Bad: Returns full collection
Stream<List<Item>> watchItemsByStatus(OperationalStatus status) {
  return _itemsController.stream;  // Wrong!
}
```

### Pitfall 2: Forgetting to Migrate Widgets

**Problem:** Tests pass, but app still slow.

**Solution:** Grep for old provider usage and migrate:
```bash
grep -r "ref.watch(allItemsAsyncProvider)" lib/
```

### Pitfall 3: Over-Migrating Collection Views

**Problem:** Item grid stops working after migration.

**Solution:** Keep `allItemsAsyncProvider` for views that need full collection:
```dart
// Grid view - KEEP using collection provider
final items = ref.watch(allItemsAsyncProvider);

// Single item card - MIGRATE to family provider
final item = ref.watch(itemByIdProvider(itemId));
```

### Pitfall 4: Missing Firestore Indexes

**Problem:** Queries fail in production with "index required" error.

**Solution:** Create indexes via Firebase Console or deploy `firestore.indexes.json`:
```bash
firebase deploy --only firestore:indexes
```

---

## Rollback Strategy

If major issues arise:

### Level 1: Revert Widget Migrations
- Keep new providers in codebase
- Revert widgets to use `allXAsyncProvider`
- No data loss, immediate rollback

### Level 2: Disable Family Providers
- Comment out family provider usage
- Keep repository methods (no harm)
- Preserves tests for future attempts

### Level 3: Full Rollback
- Revert entire PR/commit
- Only if fundamental architecture issue
- Unlikely with incremental approach

---

## Developer Handoff

### For Claude Code Subagents

Each plan is structured for autonomous execution:

1. **Clear step-by-step instructions**
2. **Code snippets ready to copy/paste**
3. **File paths explicitly specified**
4. **Test commands included**
5. **Success criteria defined**

### Execution Command

To execute a plan:
```
Please implement the plan in plans/FINE_GRAINED_REACTIVITY_ASSIGNMENTS.md
Follow each step sequentially and verify tests pass before proceeding.
```

### Parallelization

If running multiple agents in parallel:
- Agent 1: Assignments plan
- Agent 2: Items plan (start after Assignments Step 5)
- Agent 3: Containers plan (start after Items Step 5)

This minimizes merge conflicts while maximizing throughput.

---

## Post-Migration Checklist

After completing all 4 repositories:

- [ ] All 28+ tests passing
- [ ] Manual multi-user testing successful
- [ ] DevTools shows 70-90% rebuild reduction
- [ ] No performance regressions
- [ ] Firestore indexes created and deployed
- [ ] Documentation updated
- [ ] Old providers marked with `@Deprecated` (optional)
- [ ] CI/CD tests include rebuild verification

---

## Future Optimizations (Optional)

After core migration is stable:

### 1. Optimistic Updates
- Update UI immediately, sync to Firestore in background
- Requires conflict resolution logic
- 5-10x perceived performance improvement

### 2. Pagination
- For work logs and large collections
- Load data in chunks (e.g., 50 items at a time)
- Reduces initial load time

### 3. Provider Caching
- Cache family provider results across rebuilds
- Riverpod supports this with `keepAlive: true`
- Trade memory for speed

### 4. WebSocket Alternatives
- For high-frequency updates (e.g., real-time inventory)
- Consider custom WebSocket server
- Firestore may not be optimal for >10 updates/second

---

## Conclusion

This master plan provides a **proven, incremental approach** to eliminating rebuild issues while maintaining:
- ✅ Full test coverage
- ✅ Backward compatibility
- ✅ Zero downtime
- ✅ Clear rollback paths
- ✅ Autonomous execution by subagents

**Start with Assignments** for immediate 80%+ improvement in the most critical path.

**Questions or issues?** Reference individual repository plans for detailed implementation steps.
