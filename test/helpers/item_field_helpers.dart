import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';

/// Field interaction helpers for item testing
///
/// Provides composable functions to interact with item form fields
/// following SRP and KISS principles.

/// Fill basic item fields (name, description)
Future<void> fillBasicFields(
  WidgetTester tester, {
  String? name,
  String? description,
}) async {
  if (name != null) {
    await _fillTextField(tester, label: 'Name:', value: name);
  }
  if (description != null) {
    await _fillTextField(tester, label: 'Description', value: description);
  }
}

/// Fill additional item fields
Future<void> fillAdditionalFields(
  WidgetTester tester, {
  String? manufacturer,
  String? brand,
  String? type,
  String? supplier,
  String? website,
  String? remarks,
  String? sku,
  int? value,
  double? weight,
}) async {
  if (manufacturer != null) {
    await _fillTextField(tester, label: 'Manufacturer', value: manufacturer);
  }
  if (brand != null) {
    await _fillTextField(tester, label: 'Brand', value: brand);
  }
  if (type != null) {
    await _fillTextField(tester, label: 'Type', value: type);
  }
  if (supplier != null) {
    await _fillTextField(tester, label: 'Supplier', value: supplier);
  }
  if (website != null) {
    await _fillTextField(tester, label: 'Website', value: website);
  }
  if (remarks != null) {
    await _fillTextField(tester, label: 'Remarks', value: remarks);
  }
  if (sku != null) {
    await _fillTextField(tester, label: 'SKU', value: sku);
  }
  if (value != null) {
    await _fillTextField(tester, label: 'Value in €:', value: value.toString());
  }
  if (weight != null) {
    await _fillTextField(
      tester,
      label: 'Weight in kg:',
      value: weight.toString(),
    );
  }
}

/// Fill notes field
Future<void> fillNotes(WidgetTester tester, String notes) async {
  final notesField = find
      .widgetWithText(TextFormField, notes)
      .or(
        find.ancestor(
          of: find.text(notes),
          matching: find.byType(TextFormField),
        ),
      );

  if (notesField.evaluate().isNotEmpty) {
    await tester.enterText(notesField.first, notes);
    await tester.pumpAndSettle();
  }
}

/// Set operational status dropdown
Future<void> setOperationalStatus(
  WidgetTester tester,
  OperationalStatus status,
) async {
  final dropdown = find.byType(DropdownMenu<String>);
  expect(dropdown, findsOneWidget);

  await tester.tap(dropdown);
  await tester.pumpAndSettle();

  final statusOption = find.text(status.displayName).last;
  await tester.tap(statusOption);
  await tester.pumpAndSettle();
}

/// Set cold chain checkbox
Future<void> setColdChain(WidgetTester tester, bool value) async {
  final checkbox = find.widgetWithText(CheckboxListTile, 'Cold chain');
  expect(checkbox, findsOneWidget);

  final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
  if (checkboxWidget.value != value) {
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
  }
}

/// Verify item fields match expected values
void verifyItemFields(
  Item item, {
  String? name,
  String? description,
  double? weight,
  String? manufacturer,
  String? brand,
  String? type,
  String? supplier,
  String? website,
  String? remarks,
  String? sku,
  int? value,
  String? notes,
  OperationalStatus? operationalStatus,
  bool? isColdChain,
}) {
  if (name != null) expect(item.name, name);
  if (description != null) expect(item.description, description);
  if (weight != null) expect(item.weight, weight);
  if (manufacturer != null) expect(item.manufacturer, manufacturer);
  if (brand != null) expect(item.brand, brand);
  if (type != null) expect(item.type, type);
  if (supplier != null) expect(item.supplier, supplier);
  if (website != null) expect(item.website, website);
  if (remarks != null) expect(item.remarks, remarks);
  if (sku != null) expect(item.sku, sku);
  if (value != null) expect(item.value, value);
  if (notes != null) expect(item.notes, notes);
  if (operationalStatus != null)
    expect(item.operationalStatus, operationalStatus);
  if (isColdChain != null) expect(item.isColdChain, isColdChain);
}

/// Private helper to fill a text field by label
Future<void> _fillTextField(
  WidgetTester tester, {
  required String label,
  required String value,
}) async {
  final field = find
      .widgetWithText(TextFormField, label)
      .or(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(TextFormField),
        ),
      );

  if (field.evaluate().isEmpty) {
    // Try finding by label text in decoration
    final labelFinder = find.byWidgetPredicate((widget) {
      if (widget is TextFormField) {
        final decoration = widget.decoration as InputDecoration?;
        return decoration?.labelText == label;
      }
      return false;
    });

    if (labelFinder.evaluate().isNotEmpty) {
      await tester.enterText(labelFinder.first, value);
      await tester.pumpAndSettle();

      // Trigger focus loss to save changes
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      return;
    }
  }

  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();

  // Trigger focus loss to save changes
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
