/// Export Actions - UI Layer for PDF Operations
///
/// This class provides the UI-facing API for PDF export operations. It serves
/// as the glue between the UI widgets and the pure business logic in the
/// printing feature.
///
/// **Responsibilities:**
/// - Obtain PrintContext from Riverpod providers
/// - Call PDF generation services with proper context
/// - Show user-facing modals for print/save options
/// - Handle async operations with proper context checks
///
/// **Architecture Pattern:**
/// This follows a clean separation of concerns:
/// 1. UI calls ExportActions methods
/// 2. ExportActions reads PrintContext from providers
/// 3. ExportActions calls PdfGenerationService (pure logic)
/// 4. ExportActions shows modal and wires up PrintService/FileService
///
/// **Usage Example:**
/// ```dart
/// // In a ConsumerWidget
/// ElevatedButton(
///   onPressed: () {
///     await ExportActions.handlePackingLists(context, ref, containers);
///   },
///   child: Text('Print Packing Lists'),
/// )
/// ```
///
/// All methods require:
/// - [BuildContext] for showing modals and checking mounted state
/// - [WidgetRef] for accessing Riverpod providers
/// - Container/item data for PDF generation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/printing/domain/print_context_provider.dart';
import 'package:rescuenet_warehouse/features/printing/services/pdf_generation_service.dart';
import 'package:rescuenet_warehouse/features/printing/services/print_service.dart';
import 'package:rescuenet_warehouse/features/printing/services/file_service.dart';
import 'package:rescuenet_warehouse/features/printing/services/safety_datasheet_service.dart';
import 'package:rescuenet_warehouse/features/printing/generators/common/pdf_base_widgets.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'export_options_modal.dart';

/// Handles export actions for printing and saving PDFs.
///
/// This is the main UI entry point for PDF operations. All methods are
/// async and handle context mounting checks properly to avoid using
/// BuildContext after widget disposal.
class ExportActions {
  /// Handle packing list export for selected containers.
  ///
  /// Generates packing list PDFs for the given containers and shows a modal
  /// allowing the user to either print or save the documents.
  ///
  /// A packing list includes:
  /// - Full itemization of container contents
  /// - Quantities and metadata
  /// - Dangerous goods information
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing modals
  /// - [ref]: WidgetRef for accessing PrintContext provider
  /// - [containers]: Map of containers to their items with quantities
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

  /// Handle label export for selected containers.
  ///
  /// Generates container label PDFs for the given containers and shows a modal
  /// allowing the user to either print or save the labels.
  ///
  /// Labels include:
  /// - Container identification number
  /// - Dangerous goods warning symbols
  /// - Destination information
  ///
  /// Labels are formatted for printing on physical label sheets that can be
  /// attached to containers.
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing modals
  /// - [ref]: WidgetRef for accessing PrintContext provider
  /// - [containers]: Map of containers to their items with quantities
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

  /// Handle summary export for deployment.
  ///
  /// Generates a comprehensive summary PDF for all containers being deployed
  /// and shows a modal allowing the user to either print or save the document.
  ///
  /// The summary includes:
  /// - Overview of all containers
  /// - Aggregated item counts
  /// - Deployment metadata and statistics
  ///
  /// This is typically used for final verification and record-keeping before
  /// containers are deployed to their destination.
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing modals
  /// - [ref]: WidgetRef for accessing PrintContext provider
  /// - [containers]: Map of containers to their items with quantities
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

  /// Show print dialogs for all safety datasheets in selected containers
  static Future<void> handleSafetyDatasheets(
    BuildContext context,
    WidgetRef ref,
    Map<RescueContainer, Map<Item, int>> containers,
  ) async {
    try {
      await SafetyDatasheetService.printSafetyDatasheets(containers);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safety datasheets sent to printer')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error printing safety datasheets: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
