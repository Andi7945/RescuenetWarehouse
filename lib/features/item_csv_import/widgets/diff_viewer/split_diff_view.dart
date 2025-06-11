import 'package:flutter/material.dart';
import '../../services/diff_service.dart';
import 'row_diff_viewer.dart';

/// A widget that splits imported objects into two lists:
/// 1. Objects with changes (new or modified)
/// 2. Objects without changes (unchanged)
class SplitDiffView<T> extends StatefulWidget {
  /// List of imported objects
  final List<T> importedObjects;

  /// Function to find an existing object for comparison
  final T? Function(T importedObj) findExistingObject;

  /// Optional function to extract a display name for the object
  final String Function(T obj)? displayNameExtractor;

  /// Optional function to get the ID of an object for matching
  final String Function(T obj)? idExtractor;

  /// List of field names to always show, regardless of changes
  final List<String> alwaysShowFields;

  /// Optional list of field names to exclude from comparison and display
  final List<String> excludeFields;

  /// Callback when user applies changes
  final void Function(List<T> objectsToUpdateOrInsert)? onApplyChanges;

  /// Labels for the UI
  final String changedSectionTitle;
  final String unchangedSectionTitle;
  final String applyButtonLabel;
  final String emptySectionMessage;

  const SplitDiffView({
    Key? key,
    required this.importedObjects,
    required this.findExistingObject,
    this.displayNameExtractor,
    this.idExtractor,
    this.alwaysShowFields = const ['id', 'name'],
    this.excludeFields = const [],
    this.onApplyChanges,
    this.changedSectionTitle = 'Changes to Review',
    this.unchangedSectionTitle = 'No Changes',
    this.applyButtonLabel = 'Apply All Changes',
    this.emptySectionMessage = 'No items to display',
  }) : super(key: key);

  @override
  _SplitDiffViewState<T> createState() => _SplitDiffViewState<T>();
}

class _SplitDiffViewState<T> extends State<SplitDiffView<T>> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<T> _changedObjects = [];
  List<T> _unchangedObjects = [];
  Map<T, T?> _objectMap = {};
  Map<T, bool> _hasChanges = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _processObjects();
  }

  @override
  void didUpdateWidget(SplitDiffView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.importedObjects != widget.importedObjects) {
      _processObjects();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Process the imported objects and split them into changed/unchanged
  void _processObjects() {
    _changedObjects = [];
    _unchangedObjects = [];
    _objectMap = {};
    _hasChanges = {};

    for (final importedObj in widget.importedObjects) {
      final existingObj = widget.findExistingObject(importedObj);
      _objectMap[importedObj] = existingObj;

      // Determine if this object has changes
      bool hasChanges = false;

      if (existingObj == null) {
        // New object - always has changes
        hasChanges = true;
      } else {
        // Check for differences between imported and existing object
        final differences = DiffService.getDifferences(
            importedObj,
            existingObj,
            excludeFields: widget.excludeFields
        );
        hasChanges = differences.isNotEmpty;
      }

      _hasChanges[importedObj] = hasChanges;

      if (hasChanges) {
        _changedObjects.add(importedObj);
      } else {
        _unchangedObjects.add(importedObj);
      }
    }

    // If there are changes, start on the changes tab
    if (_changedObjects.isNotEmpty && _tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top controls
        if (widget.onApplyChanges != null && _changedObjects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApplyChanges?.call(_changedObjects),
                    child: Text(widget.applyButtonLabel),
                  ),
                ),
              ],
            ),
          ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: '${widget.changedSectionTitle} (${_changedObjects.length})',
            ),
            Tab(
              text: '${widget.unchangedSectionTitle} (${_unchangedObjects.length})',
            ),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Changes tab
              _changedObjects.isEmpty
                  ? Center(child: Text(widget.emptySectionMessage))
                  : _buildObjectsList(_changedObjects),

              // Unchanged tab
              _unchangedObjects.isEmpty
                  ? Center(child: Text(widget.emptySectionMessage))
                  : _buildObjectsList(_unchangedObjects),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a list view of the objects
  Widget _buildObjectsList(List<T> objects) {
    return ListView.builder(
      itemCount: objects.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final importedObj = objects[index];
        return RowDiffViewer<T>(
          importedObject: importedObj,
          existingObject: _objectMap[importedObj],
          displayNameExtractor: widget.displayNameExtractor,
          idExtractor: widget.idExtractor,
          alwaysShowFields: widget.alwaysShowFields,
          excludeFields: widget.excludeFields,
        );
      },
    );
  }
}
