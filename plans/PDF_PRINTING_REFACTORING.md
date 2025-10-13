# PDF Printing System Refactoring Plan

**Date:** 2025-10-12
**Objective:** Separate business logic from UI in PDF/label printing functionality
**Approach:** SRP, KISS, modularity - Pure functions where appropriate, minimal tests

---

## Executive Summary

The current printing system mixes UI, business logic, and PDF generation in a tightly coupled way. This plan refactors it into:
1. **Pure business logic** (mappers, generators)
2. **Service layer** (orchestration)
3. **UI layer** (separated from logic)

**Key Issues to Fix:**
- Missing username in all PDFs (shows "Unknown User")
- BuildContext required for PDF generation (can't test)
- Hardcoded organization info (doesn't use multi-tenant config)
- Mixed responsibilities in `export_service.dart`

---

## Phase 1: Foundation - Create Core Types & Context

**Goal:** Establish immutable DTOs and print context without breaking existing code.

### Task 1.1: Create Print Context Model
**File:** `lib/features/printing/domain/print_context.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'print_context.freezed.dart';

/// Immutable context containing user and organization info for PDF generation
@freezed
class PrintContext with _$PrintContext {
  const factory PrintContext({
    required String userName,
    required String organizationName,
    required String organizationEmail,
    required String organizationPhone,
    required String logoAssetPath,
    required DateTime printDate,
  }) = _PrintContext;

  const PrintContext._();

  /// Format the print date as string
  String get formattedDate {
    // Use intl package formatting
    return '${printDate.year}-${printDate.month.toString().padLeft(2, '0')}-${printDate.day.toString().padLeft(2, '0')} '
           '${printDate.hour.toString().padLeft(2, '0')}:${printDate.minute.toString().padLeft(2, '0')}';
  }
}
```

**Actions:**
- Create directory structure: `lib/features/printing/domain/`
- Create the file with Freezed model
- Run `dart run build_runner build` to generate code
- Verify it compiles

---

### Task 1.2: Create Print Context Provider
**File:** `lib/features/printing/domain/print_context_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/config/org_provider.dart';
import 'package:rescuenet_warehouse/repositories/auth_providers.dart';
import 'print_context.dart';

part 'print_context_provider.g.dart';

/// Provides the current print context from auth and org providers
@riverpod
PrintContext printContext(PrintContextRef ref) {
  final userName = ref.watch(currentUserNameProvider) ?? 'Unknown User';
  final org = ref.watch(currentOrgProvider);

  return PrintContext(
    userName: userName,
    organizationName: org.name,
    organizationEmail: org.contactEmail ?? 'backoffice@rescuenet.net',
    organizationPhone: org.contactPhone ?? '+31-6-14419988',
    logoAssetPath: org.logoAssetPath ?? 'rn_logo_big.png',
    printDate: DateTime.now(),
  );
}
```

**Actions:**
- Create the provider file
- Run `dart run build_runner build`
- Verify compilation

**Note:** Check if `OrgConfig` has `contactEmail` and `contactPhone` fields. If not, we'll use the hardcoded values for now.

---

### Task 1.3: Convert PDF DTOs to Freezed Models
**Goal:** Make existing DTOs immutable

**Files to Convert:**

1. **`lib/pdf/packing_list.dart`** → Add Freezed annotations
2. **`lib/pdf/packing_item.dart`** → Add Freezed annotations
3. **`lib/pdf/packing_dangerous_good.dart`** → Add Freezed annotations
4. **`lib/pdf/summary_pdf.dart`** → Add Freezed annotations
5. **`lib/pdf/summary_list.dart`** → Add Freezed annotations
6. **`lib/pdf/summary_container.dart`** → Add Freezed annotations

**Example for `packing_list.dart`:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';
import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';

part 'packing_list.freezed.dart';

@freezed
class PackingList with _$PackingList {
  const factory PackingList({
    required int containerNo,
    required String containerType,
    required String containerName,
    required String containerDescription,
    required double totalWeight,
    required String destination,
    required SequentialBuild sequentialBuild,
    required DateTime? expirationDate,
    required List<PackingDangerousGood> dangerousGoods,
    required List<PackingItem> items,
  }) = _PackingList;
}
```

**Actions for each file:**
- Add Freezed imports and annotations
- Convert constructor to factory with named params
- Add `required` keywords
- Update part directives
- Run `dart run build_runner build`
- Fix any compilation errors in mapper files (update to use named params)

---

## Phase 2: Move PDF Generation to Features

**Goal:** Create clean generator functions with PrintContext parameter.

### Task 2.1: Create Base PDF Utilities
**File:** `lib/features/printing/generators/common/pdf_base_widgets.dart`

Move pure widget functions from `lib/pdf/pdf_utils.dart`:
- Keep: `smallText`, `tableHeadline`, `tableCell`, `bigger`, `biggerAndFat`, `valueBox`
- Keep: `basicTheme`, `pageFormatLandscape`, `pageFormatLabels`
- Keep: `summaryTable`, `loadImage`, `dangerousGoodsLabels`, `dangerousGoodsPackingList`
- Remove: `saveAndPrint` (belongs in service layer)
- Remove: `footerFn` (will be recreated with context awareness)

**Actions:**
- Create directory: `lib/features/printing/generators/common/`
- Copy pure widget functions
- Update imports
- Keep original file for now (will be removed in Phase 4)

---

### Task 2.2: Create Header Builder with PrintContext
**File:** `lib/features/printing/generators/common/pdf_header_builder.dart`

Replace stateful `HeaderProvider` with pure functions:

```dart
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'pdf_base_widgets.dart';

/// Build header with organization info and user context
Future<pw.Widget> buildHeaderRow(
  pw.Widget leftCorner,
  pw.Widget? rightSide,
  PrintContext context,
) async {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: leftCorner, flex: 5),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: await _buildRightSide(rightSide, context),
          flex: 5,
        ),
      ],
    ),
  );
}

Future<pw.Widget> _buildRightSide(
  pw.Widget? rightSide,
  PrintContext context,
) async {
  return pw.Container(
    width: double.infinity,
    child: pw.Column(
      children: [
        await _buildOrgInfoBox(context),
        pw.SizedBox(height: 8),
        rightSide ?? pw.Container(),
      ],
    ),
  );
}

Future<pw.Widget> _buildOrgInfoBox(PrintContext context) async {
  final logo = await loadImage(context.logoAssetPath);

  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(right: 8.0),
          child: _buildInfoBox(context),
        ),
        flex: 2,
      ),
      pw.Expanded(child: logo, flex: 3),
    ],
  );
}

pw.Widget _buildInfoBox(PrintContext context) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4.0),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        smallText(context.organizationEmail),
        smallText(context.organizationPhone),
        pw.SizedBox(height: 10),
        smallText('Printed by: ${context.userName}'),
        smallText('Date: ${context.formattedDate}'),
      ],
    ),
  );
}

/// Build footer with page numbers
pw.Widget Function(int, int) buildFooter(String documentName) {
  return (int pageNum, int totalPages) => pw.Container(
    alignment: pw.Alignment.centerRight,
    child: pw.Text('$documentName - page $pageNum / $totalPages'),
  );
}
```

**Actions:**
- Create file with pure functions
- Use PrintContext for all user/org info
- No mutable state
- Test compilation

---

### Task 2.3: Create Packing List Generator
**File:** `lib/features/printing/generators/packing_list_generator.dart`

Refactor `pdf_creator_packing_list.dart` to use PrintContext:

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'common/pdf_base_widgets.dart';
import 'common/pdf_header_builder.dart';

/// Generate a packing list PDF document
Future<pw.Document> generatePackingListPdf(
  PackingList packingList,
  PrintContext context,
) async {
  final pdf = pw.Document();
  final page = await _buildPage(packingList, context);
  pdf.addPage(page);
  return pdf;
}

Future<pw.Page> _buildPage(
  PackingList list,
  PrintContext context,
) async {
  final header = await _buildHeader(list, context);
  final body = _buildBody(list);
  final footer = buildFooter('Packing list');

  return pw.MultiPage(
    theme: await basicTheme(),
    pageFormat: pageFormatLandscape,
    orientation: pw.PageOrientation.landscape,
    build: (pw.Context context) => [body],
    header: (ctxt) => header,
    footer: (ctxt) => footer(ctxt.pageNumber, ctxt.pagesCount),
  );
}

Future<pw.Widget> _buildHeader(
  PackingList list,
  PrintContext context,
) async {
  final leftColumn = _buildLeftColumn(list);
  final rightSide = (await dangerousGoodsPackingList(list.dangerousGoods)).first;
  return buildHeaderRow(leftColumn, rightSide, context);
}

pw.Widget _buildLeftColumn(PackingList list) {
  // Build summary table and info boxes
  // ... (similar to current implementation)
}

pw.Widget _buildBody(PackingList list) {
  // Build main table with items
  // ... (similar to current implementation)
}
```

**Actions:**
- Create generator file
- Accept PrintContext parameter
- Use header builder from common
- Keep business logic pure
- Update to work with Freezed models

---

### Task 2.4: Create Label Generator
**File:** `lib/features/printing/generators/label_generator.dart`

Refactor `pdf_creator_label.dart` to use PrintContext properly:

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'common/pdf_base_widgets.dart';
import 'common/pdf_header_builder.dart';

/// Generate container label PDF document
Future<pw.Document> generateLabelPdf(
  PackingList packingList,
  PrintContext context,
) async {
  final pdf = pw.Document();

  final goods = await dangerousGoodsLabels(packingList.dangerousGoods);
  final totalPages = (goods.length / 2).floor() + 1;

  // Build all label pages
  final pages = await _buildAllPages(packingList, goods, totalPages, context);

  for (final page in pages) {
    pdf.addPage(page);
  }

  return pdf;
}

Future<List<pw.Page>> _buildAllPages(
  PackingList list,
  List<pw.Widget> goods,
  int totalPages,
  PrintContext context,
) async {
  // ... build label pages with context
}
```

**Actions:**
- Create generator file
- Remove optional userName parameter, use PrintContext instead
- All pages get proper username

---

### Task 2.5: Create Summary Generator
**File:** `lib/features/printing/generators/summary_generator.dart`

Refactor `pdf_creator_summary.dart`:

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';
import 'common/pdf_base_widgets.dart';
import 'common/pdf_header_builder.dart';

/// Generate summary PDF document
Future<pw.Document> generateSummaryPdf(
  SummaryPdf summary,
  PrintContext context,
) async {
  final pdf = pw.Document();
  final page = await _buildPage(summary, context);
  pdf.addPage(page);
  return pdf;
}

Future<pw.Page> _buildPage(
  SummaryPdf summary,
  PrintContext context,
) async {
  final header = await _buildHeader(summary, context);
  final body = _buildBody(summary);
  final footer = buildFooter('Summary');

  return pw.MultiPage(
    theme: await basicTheme(),
    pageFormat: pageFormatLandscape,
    orientation: pw.PageOrientation.landscape,
    build: (pw.Context context) => [body],
    header: (ctxt) => header,
    footer: (ctxt) => footer(ctxt.pageNumber, ctxt.pagesCount),
  );
}
```

**Actions:**
- Create generator file
- Add PrintContext parameter
- Use header builder

---

## Phase 3: Create Service Layer

**Goal:** Orchestrate PDF generation without UI dependencies.

### Task 3.1: Create PDF Service (Pure Logic)
**File:** `lib/features/printing/services/pdf_generation_service.dart`

```dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/pdf/packing_list_mapper.dart';
import 'package:rescuenet_warehouse/pdf/summary_mapper.dart';
import '../generators/packing_list_generator.dart';
import '../generators/label_generator.dart';
import '../generators/summary_generator.dart';

/// Pure business logic for PDF generation
/// All functions return Future<Uint8List> (raw PDF bytes)
class PdfGenerationService {
  /// Generate packing list PDFs for containers
  static Future<List<PdfDocument>> generatePackingLists(
    Map<RescueContainer, Map<Item, int>> containers,
    PrintContext context,
  ) async {
    final packingLists = mapPackingList(containers);
    final results = <PdfDocument>[];

    for (final list in packingLists) {
      final doc = await generatePackingListPdf(list, context);
      final bytes = await doc.save();
      results.add(PdfDocument(
        fileName: 'packing_list_${list.containerNo}.pdf',
        bytes: bytes,
      ));
    }

    return results;
  }

  /// Generate label PDFs for containers
  static Future<List<PdfDocument>> generateLabels(
    Map<RescueContainer, Map<Item, int>> containers,
    PrintContext context,
  ) async {
    final packingLists = mapPackingList(containers);
    final results = <PdfDocument>[];

    for (final list in packingLists) {
      final doc = await generateLabelPdf(list, context);
      final bytes = await doc.save();
      results.add(PdfDocument(
        fileName: 'label_${list.containerNo}.pdf',
        bytes: bytes,
      ));
    }

    return results;
  }

  /// Generate summary PDF
  static Future<PdfDocument> generateSummary(
    Map<RescueContainer, Map<Item, int>> containers,
    PrintContext context,
  ) async {
    final summary = mapForPdf(containers);
    final doc = await generateSummaryPdf(summary, context);
    final bytes = await doc.save();

    return PdfDocument(
      fileName: 'summary.pdf',
      bytes: bytes,
    );
  }
}

/// Simple DTO for a generated PDF
class PdfDocument {
  final String fileName;
  final Uint8List bytes;

  const PdfDocument({
    required this.fileName,
    required this.bytes,
  });
}
```

**Actions:**
- Create service with static pure functions
- No BuildContext dependency
- Returns raw PDF bytes
- Simple, testable

---

### Task 3.2: Create File Service
**File:** `lib/features/printing/services/file_service.dart`

Extract file operations from `export_service.dart`:

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Handles file system operations for PDFs
class FileService {
  /// Save PDF bytes to local file system
  /// Returns the full file path
  static Future<String> saveToLocalFile(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Save multiple PDFs
  static Future<List<String>> saveMultipleToLocalFiles(
    List<(String fileName, Uint8List bytes)> pdfs,
  ) async {
    final paths = <String>[];
    for (final (fileName, bytes) in pdfs) {
      final path = await saveToLocalFile(bytes, fileName);
      paths.add(path);
    }
    return paths;
  }
}
```

**Actions:**
- Create file service
- Pure file system operations
- No UI dependencies

---

### Task 3.3: Create Print Service (UI Integration)
**File:** `lib/features/printing/services/print_service.dart`

Handles printing dialog (requires UI context):

```dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Handles print dialog interactions
class PrintService {
  /// Show native print dialog for a single PDF
  static Future<void> showPrintDialog(
    Uint8List pdfBytes, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    await Printing.layoutPdf(
      format: format,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Show print dialog for multiple PDFs (prints one by one)
  static Future<void> showPrintDialogForMultiple(
    List<Uint8List> pdfBytesList, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    for (final bytes in pdfBytesList) {
      await showPrintDialog(bytes, format: format);
    }
  }
}
```

**Actions:**
- Create print service
- Minimal responsibility: just show print dialog
- No business logic

---

## Phase 4: Update UI Layer

**Goal:** Separate UI from business logic, use new services.

### Task 4.1: Create Action Handlers
**File:** `lib/features/printing/ui/export_actions.dart`

Replace methods in `export_page_body.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/printing/domain/print_context_provider.dart';
import 'package:rescuenet_warehouse/features/printing/services/pdf_generation_service.dart';
import 'package:rescuenet_warehouse/features/printing/services/print_service.dart';
import 'package:rescuenet_warehouse/features/printing/services/file_service.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:pdf/pdf.dart';
import 'export_options_modal.dart';

/// Handles export actions for printing/saving PDFs
class ExportActions {
  /// Show options modal for packing lists
  static Future<void> handlePackingLists(
    BuildContext context,
    WidgetRef ref,
    Map<RescueContainer, Map<Item, int>> containers,
  ) async {
    final printContext = ref.read(printContextProvider);
    final documents = await PdfGenerationService.generatePackingLists(
      containers,
      printContext,
    );

    if (!context.mounted) return;

    await showExportOptionsModal(
      context: context,
      onPrint: () async {
        for (final doc in documents) {
          await PrintService.showPrintDialog(
            doc.bytes,
            format: pageFormatLandscape,
          );
        }
      },
      onSave: () async {
        for (final doc in documents) {
          await FileService.saveToLocalFile(doc.bytes, doc.fileName);
        }
      },
      documentName: 'Packing Lists',
    );
  }

  /// Show options modal for labels
  static Future<void> handleLabels(
    BuildContext context,
    WidgetRef ref,
    Map<RescueContainer, Map<Item, int>> containers,
  ) async {
    final printContext = ref.read(printContextProvider);
    final documents = await PdfGenerationService.generateLabels(
      containers,
      printContext,
    );

    if (!context.mounted) return;

    await showExportOptionsModal(
      context: context,
      onPrint: () async {
        for (final doc in documents) {
          await PrintService.showPrintDialog(doc.bytes);
        }
      },
      onSave: () async {
        for (final doc in documents) {
          await FileService.saveToLocalFile(doc.bytes, doc.fileName);
        }
      },
      documentName: 'Labels',
    );
  }

  /// Show options modal for summary
  static Future<void> handleSummary(
    BuildContext context,
    WidgetRef ref,
    Map<RescueContainer, Map<Item, int>> containers,
  ) async {
    final printContext = ref.read(printContextProvider);
    final document = await PdfGenerationService.generateSummary(
      containers,
      printContext,
    );

    if (!context.mounted) return;

    await showExportOptionsModal(
      context: context,
      onPrint: () async {
        await PrintService.showPrintDialog(
          document.bytes,
          format: pageFormatLandscape,
        );
      },
      onSave: () async {
        await FileService.saveToLocalFile(document.bytes, document.fileName);
      },
      documentName: 'Summary',
    );
  }
}
```

**Actions:**
- Create action handlers
- Use Riverpod ref to get PrintContext
- Call new services
- Handle async properly with context.mounted checks

---

### Task 4.2: Create Export Options Modal
**File:** `lib/features/printing/ui/export_options_modal.dart`

Extract modal UI from `export_service.dart`:

```dart
import 'package:flutter/material.dart';

/// Shows modal with Print / Save / Cancel options
Future<void> showExportOptionsModal({
  required BuildContext context,
  required Future<void> Function() onPrint,
  required Future<void> Function() onSave,
  required String documentName,
}) async {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onPrint();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Printed $documentName')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error printing: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save on disc'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onSave();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved $documentName')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_presentation),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
```

**Actions:**
- Create modal widget
- Accept callbacks for actions
- Handle errors gracefully
- Show user feedback

---

### Task 4.3: Update Export Page Body
**File:** `lib/ui/export_page/export_page_body.dart`

Replace existing methods with new action handlers:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/printing/ui/export_actions.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'export_page_table.dart';

class ExportPageBody extends ConsumerStatefulWidget {
  final Map<RescueContainer, Map<Item, int>> containerWithItems;

  const ExportPageBody(this.containerWithItems, {super.key});

  @override
  ConsumerState<ExportPageBody> createState() => _ExportPageBodyState();
}

class _ExportPageBodyState extends ConsumerState<ExportPageBody> {
  final List<ContainerPrintingOptions> options = [];

  @override
  void initState() {
    super.initState();
    options.addAll(widget.containerWithItems.keys
        .where((element) => element.isReady)
        .map((e) => ContainerPrintingOptions(e))
        .toList());
    options.sort((a, b) => a.container.number.compareTo(b.container.number));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: ExportPageTable(
        options,
        _adjustOption,
        _sharePackingListPdf,
        _shareLabelPdf,
        _shareSafetyDatasheets,
      ),
    );
  }

  void _adjustOption(ContainerPrintingOptions option) {
    final toAdjust = options.firstWhere(
      (element) => element.container == option.container,
    );
    setState(() {
      toAdjust.printPackingList = option.printPackingList;
      toAdjust.printSafetyDatasheet = option.printSafetyDatasheet;
      toAdjust.printLabel = option.printLabel;
    });
  }

  Future<void> _sharePackingListPdf() async {
    final toPrint = options
        .where((ele) => ele.printPackingList)
        .map((e) => e.container)
        .toList();
    final withItems = Map.fromEntries(
      widget.containerWithItems.entries
          .where((ele) => toPrint.contains(ele.key)),
    );

    await ExportActions.handlePackingLists(context, ref, withItems);
  }

  Future<void> _shareLabelPdf() async {
    final toPrint = options
        .where((ele) => ele.printLabel)
        .map((e) => e.container)
        .toList();
    final withItems = Map.fromEntries(
      widget.containerWithItems.entries
          .where((ele) => toPrint.contains(ele.key)),
    );

    await ExportActions.handleLabels(context, ref, withItems);
  }

  Future<void> _shareSafetyDatasheets() async {
    // Keep existing implementation for now
    // This is out of scope for this refactoring
  }
}
```

**Actions:**
- Convert to ConsumerStatefulWidget to access ref
- Replace method bodies with ExportActions calls
- Remove direct dependencies on old export_service.dart
- Keep safety datasheets as-is (different concern)

---

### Task 4.4: Update Export Page
**File:** `lib/ui/export_page/export_page.dart`

Update summary button to use new actions:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/printing/ui/export_actions.dart';
import 'package:rescuenet_warehouse/state/container_with_items_notifier.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import '../rescue_text.dart';
import '../rescue_navigation_drawer.dart';
import 'export_page_body.dart';

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  @override
  Widget build(BuildContext context) {
    final allContainersWithItems = ref.watch(containerWithItemsNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready containers'),
        actions: [_summaryButton(allContainersWithItems)],
      ),
      drawer: RescueNavigationDrawer(),
      body: ExportPageBody(allContainersWithItems),
    );
  }

  Widget _summaryButton(
    Map<RescueContainer, Map<Item, int>> allContainersWithItems,
  ) {
    return ActionChip(
      onPressed: () async {
        await _shareSummaryPdf(allContainersWithItems);
      },
      label: RescueText.slim('Print final summary'),
    );
  }

  Future<void> _shareSummaryPdf(
    Map<RescueContainer, Map<Item, int>> withItems,
  ) async {
    final forContainers = Map.fromEntries(
      withItems.entries.where((ele) => ele.key.isReady && ele.key.toDeploy),
    );

    await ExportActions.handleSummary(context, ref, forContainers);
  }
}
```

**Actions:**
- Update to use ExportActions.handleSummary
- Remove old import of export_service.dart

---

## Phase 5: Cleanup & Testing

**Goal:** Remove old code, verify everything works.

### Task 5.1: Mark Old Files as Deprecated
Add deprecation comments to old files:

- `lib/services/export_service.dart` - Add `@deprecated` comment at top
- `lib/pdf/pdf_creator_*.dart` - Add `@deprecated` comment
- `lib/pdf/header_provider.dart` - Add `@deprecated` comment
- `lib/services/pdf_service.dart` - Add `@deprecated` comment

**Actions:**
- Don't delete yet, just mark as deprecated
- Add comment: "// DEPRECATED: Use lib/features/printing/ instead"

---

### Task 5.2: Verify Compilation
**Actions:**
- Run `dart run build_runner build --delete-conflicting-outputs`
- Run `flutter analyze`
- Fix any errors

---

### Task 5.3: Manual Testing Checklist
Test each feature in the app:

1. **Packing List:**
   - [ ] Navigate to Export page
   - [ ] Select a container
   - [ ] Click print icon for packing list
   - [ ] Verify modal appears
   - [ ] Click "Print" - verify username appears correctly
   - [ ] Click "Save" - verify file saves
   - [ ] Verify organization logo/email/phone appear

2. **Labels:**
   - [ ] Select a container with dangerous goods
   - [ ] Click print icon for labels
   - [ ] Verify username on all label pages
   - [ ] Verify organization info correct

3. **Summary:**
   - [ ] Mark containers as "Deploy"
   - [ ] Click "Print final summary" button
   - [ ] Verify username appears
   - [ ] Verify all containers listed

4. **Multi-tenant:**
   - [ ] If multiple orgs configured, test with different org
   - [ ] Verify correct logo appears
   - [ ] Verify correct contact info

---

### Task 5.4: Remove Old Files (Optional)
Once everything works:

**Files to Delete:**
- `lib/services/export_service.dart`
- `lib/services/pdf_service.dart`
- `lib/pdf/pdf_creator_packing_list.dart`
- `lib/pdf/pdf_creator_label.dart`
- `lib/pdf/pdf_creator_summary.dart`
- `lib/pdf/header_provider.dart`
- `lib/pdf/pdf_header_row.dart`
- `lib/pdf/pdf_utils.dart` (functionality moved)

**Keep:**
- `lib/pdf/packing_list_mapper.dart` (still used)
- `lib/pdf/summary_mapper.dart` (still used)
- All DTO files in `lib/pdf/` (now Freezed models)

**Actions:**
- Only delete after thorough testing
- Commit before deletion for easy rollback
- Run `flutter clean && flutter pub get` after deletion

---

## Phase 6: Documentation

### Task 6.1: Update CLAUDE.md
Add section about printing architecture:

```markdown
### PDF Generation

Located in `lib/features/printing/`

**Architecture:**
- **domain/** - PrintContext and providers
- **generators/** - Pure functions: DTO → PDF Document
- **services/** - Orchestration and file operations
- **ui/** - UI components and action handlers

**Key Principles:**
- Generators are pure functions taking DTOs + PrintContext
- No UI dependencies in business logic
- Username and org info from Riverpod providers
- All DTOs are Freezed immutable models

**Usage:**
```dart
// Get print context from provider
final context = ref.read(printContextProvider);

// Generate PDF
final doc = await PdfGenerationService.generateSummary(containers, context);

// Print or save
await PrintService.showPrintDialog(doc.bytes);
await FileService.saveToLocalFile(doc.bytes, doc.fileName);
```
```

---

### Task 6.2: Add Code Comments
Add doc comments to key files:

- `print_context.dart` - Explain purpose
- `print_context_provider.dart` - Explain how it builds context
- `pdf_generation_service.dart` - Document each method
- `export_actions.dart` - Explain responsibility

---

## Success Criteria

✅ Username appears on all PDFs
✅ Organization info (logo, email, phone) appears correctly
✅ Multi-tenant support works (different orgs show different branding)
✅ No BuildContext required for PDF generation logic
✅ All DTOs are immutable (Freezed)
✅ Business logic testable without UI
✅ Clean separation: UI → Actions → Services → Generators
✅ Old code marked deprecated or removed
✅ No compilation errors
✅ Manual testing passed

---

## Implementation Notes for Subagents

**Execution Order:**
1. Run phases sequentially (1 → 2 → 3 → 4 → 5 → 6)
2. Run `dart run build_runner build` after any Freezed changes
3. Fix compilation errors before moving to next phase
4. Test incrementally - don't wait until end

**If Issues Arise:**
- Check `OrgConfig` model for email/phone fields
- If missing, add them or use fallback values
- Ensure `currentOrgProvider` exists and works
- Check import paths carefully
- Use `flutter analyze` frequently

**Parallel Work:**
- Task 1.3 (convert DTOs) can be done in parallel
- Task 2.3, 2.4, 2.5 (generators) can be done in parallel after 2.1, 2.2 complete
- Phase 5 testing can start while Phase 4 completes

**Keep it Simple:**
- Don't add error handling beyond what exists
- Don't add logging unless critical
- Don't over-engineer - pure functions are enough
- No unit tests required (startup philosophy)
- Focus on separation of concerns

---

## Estimated Effort

- **Phase 1:** 2-3 hours (foundation)
- **Phase 2:** 3-4 hours (generators)
- **Phase 3:** 2 hours (services)
- **Phase 4:** 2-3 hours (UI updates)
- **Phase 5:** 1-2 hours (cleanup/testing)
- **Phase 6:** 1 hour (docs)

**Total:** ~11-15 hours for single developer
**With subagents:** Could parallelize to ~6-8 hours wall-clock time
