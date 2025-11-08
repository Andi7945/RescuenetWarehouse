/// PDF Generation Service
///
/// This service orchestrates the conversion of domain models (containers, items)
/// into PDF documents. It serves as the main entry point for PDF generation in
/// the application, coordinating between:
/// - Data mappers (DTO conversion)
/// - PDF generators (pure functions)
/// - Result packaging (PdfDocument objects)
///
/// All methods are static and pure - they have no side effects and don't
/// depend on UI state. This makes them:
/// - Easy to test without a Flutter environment
/// - Safe to call from anywhere (UI, background tasks, tests)
/// - Predictable and maintainable
///
/// The service requires a [PrintContext] to provide user and organization
/// information for proper PDF branding and attribution.
import 'dart:typed_data';
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/features/printing/domain/label_format.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/pdf/packing_list_mapper.dart';
import 'package:rescuenet_warehouse/pdf/summary_mapper.dart';
import '../generators/packing_list_generator.dart';
import '../generators/label_generator.dart';
import '../generators/summary_generator.dart';

/// Pure business logic for PDF generation.
///
/// Provides static methods for generating various types of PDFs from
/// container and item data. All methods are pure functions that:
/// - Take domain models and PrintContext as input
/// - Return PdfDocument objects with raw bytes
/// - Have no side effects (no file I/O, no UI interactions)
///
/// For actual printing or saving, use [PrintService] and [FileService].
class PdfGenerationService {
  /// Generate packing list PDFs for containers.
  ///
  /// Creates one PDF per container with:
  /// - Container identification and metadata
  /// - Complete item listing with quantities
  /// - Dangerous goods information
  /// - Organization branding and user attribution
  ///
  /// Parameters:
  /// - [containers]: Map of containers to their items with quantities
  /// - [context]: Print context for user/org info
  ///
  /// Returns a list of [PdfDocument] objects, one per container.
  static Future<List<PdfDocument>> generatePackingLists(
    Map<RescueContainer, Map<Item, int>> containers,
    PrintContext context,
  ) async {
    final packingLists = mapPackingList(containers);
    final results = <PdfDocument>[];

    for (final list in packingLists) {
      final doc = await generatePackingListPdf(list, context);
      final bytes = await doc.save();
      results.add(
        PdfDocument(
          fileName: 'packing_list_${list.containerNo}.pdf',
          bytes: bytes,
        ),
      );
    }

    return results;
  }

/// Generate label PDFs for containers in both formats.
  ///
  /// Creates container labels in both A6 (one per page) and A4 2x2 (two per page)
  /// formats. This allows users to choose their preferred format at print/save time
  /// without regenerating the PDFs.
  ///
  /// Labels include:
  /// - Container number and identification
  /// - Dangerous goods warning labels
  /// - Destination information
  /// - Organization branding and user attribution
  ///
  /// Parameters:
  /// - [containers]: Map of containers to their items with quantities
  /// - [context]: Print context for user/org info
  ///
  /// Returns a list of [DualFormatLabelDocument] objects, one per container,
  /// each containing both A6 and A4 versions.
  static Future<List<DualFormatLabelDocument>> generateLabels(
    Map<RescueContainer, Map<Item, int>> containers,
    PrintContext context,
  ) async {
    final packingLists = mapPackingList(containers);
    final results = <DualFormatLabelDocument>[];

    for (final list in packingLists) {
      // Generate A6 version
      final a6Doc = await generateLabelPdf(list, context, LabelFormat.a6);
      final a6Bytes = await a6Doc.save();

      // Generate A4 2x2 version
      final a4Doc = await generateLabelPdf(list, context, LabelFormat.a4TwoPerPage);
      final a4Bytes = await a4Doc.save();

      results.add(
        DualFormatLabelDocument(
          containerNo: '${list.containerNo}',
          a6Document: PdfDocument(
            fileName: 'label_${list.containerNo}_A6.pdf',
            bytes: a6Bytes,
          ),
          a4Document: PdfDocument(
            fileName: 'label_${list.containerNo}_A4.pdf',
            bytes: a4Bytes,
          ),
        ),
      );
    }

    return results;
  }

  /// Generate summary PDF.
  ///
  /// Creates a comprehensive summary document for deployment that includes:
  /// - Overview of all containers being deployed
  /// - Aggregated item counts across all containers
  /// - Summary statistics and metadata
  /// - Organization branding and user attribution
  ///
  /// This is typically used for final verification before deployment.
  ///
  /// Parameters:
  /// - [containers]: Map of containers to their items with quantities
  /// - [context]: Print context for user/org info
  ///
  /// Returns a single [PdfDocument] with the summary report.
  static Future<PdfDocument> generateSummary(
    Map<RescueContainer, Map<Item, int>> containers,
    PrintContext context,
  ) async {
    final summary = mapForPdf(containers);
    final doc = await generateSummaryPdf(summary, context);
    final bytes = await doc.save();

    return PdfDocument(fileName: 'summary.pdf', bytes: bytes);
  }
}

/// Data transfer object for label PDFs in both formats.
///
/// Contains both A6 and A4 2x2 versions of the same label,
/// allowing users to choose their preferred format at print/save time.
class DualFormatLabelDocument {
  final String containerNo;
  final PdfDocument a6Document;
  final PdfDocument a4Document;

  const DualFormatLabelDocument({
    required this.containerNo,
    required this.a6Document,
    required this.a4Document,
  });
}

/// Data transfer object for a generated PDF document.
///
/// Contains the raw PDF bytes and suggested filename. This simple DTO
/// allows the generation service to remain pure while providing enough
/// information for downstream services (PrintService, FileService) to
/// handle the document appropriately.
class PdfDocument {
  final String fileName;
  final Uint8List bytes;

  const PdfDocument({required this.fileName, required this.bytes});
}
