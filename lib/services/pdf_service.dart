/// Service for PDF-related operations that need authentication context.
/// Since PDF generation functions can't directly use Riverpod providers,
/// this service provides a way to pass authentication information to PDF generators.
class PdfService {
  final String? currentUserName;

  const PdfService({required this.currentUserName});

  /// Get the current user name for PDF headers.
  /// Returns 'Unknown User' if no user is authenticated.
  String get userNameForPdf => currentUserName ?? 'Unknown User';
}