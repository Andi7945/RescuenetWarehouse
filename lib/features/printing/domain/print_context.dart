/// Print Context Domain Model
///
/// This file defines the immutable context object that carries all necessary
/// user and organization information for PDF generation. This eliminates the
/// need to pass BuildContext or access global state during PDF generation,
/// making the PDF generators pure functions that are easy to test and maintain.
///
/// The PrintContext is typically obtained from [printContextProvider] which
/// assembles the context from auth and organization providers.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'print_context.freezed.dart';

/// Immutable context containing user and organization info for PDF generation.
///
/// This object encapsulates all the information needed to generate PDFs with
/// proper branding and attribution. It includes:
/// - User identification (who is printing)
/// - Organization details (branding, contact info)
/// - Print timestamp
///
/// By passing this context to PDF generators instead of BuildContext, we
/// achieve pure functions that can be tested without a Flutter environment.
@freezed
abstract class PrintContext with _$PrintContext {
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
