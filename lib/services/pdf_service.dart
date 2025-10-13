// DEPRECATED: Use lib/features/printing/services/printing_service.dart instead. This file will be removed in a future version.
// The new PrintingService provides the same functionality with better architecture.

/// Service for PDF-related operations that need authentication context.
/// Since PDF generation functions can't directly use Riverpod providers,
/// this service provides a way to pass authentication information to PDF generators.
@Deprecated('Use PrintingService from lib/features/printing/services/printing_service.dart')
class PdfService {
  final String? currentUserName;

  const PdfService({required this.currentUserName});

  /// Get the current user name for PDF headers.
  /// Returns 'Unknown User' if no user is authenticated.
  String get userNameForPdf => currentUserName ?? 'Unknown User';
}