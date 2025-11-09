/// Print Context Provider
///
/// This provider assembles a [PrintContext] from various application state:
/// - Current user information from auth providers
/// - Organization configuration from org providers
/// - Current timestamp
///
/// This is the bridge between the application's Riverpod state management
/// and the pure PDF generation functions. By reading this provider, UI code
/// can obtain all necessary context for PDF generation without coupling the
/// PDF generators to Firebase Auth or organization config directly.
///
/// Example usage:
/// ```dart
/// final printContext = ref.read(printContextProvider);
/// final pdf = await PdfGenerationService.generateSummary(containers, printContext);
/// ```
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/config/org_provider.dart';
import 'package:rescuenet_warehouse/repositories/auth_providers.dart';
import 'print_context.dart';

part 'print_context_provider.g.dart';

/// Provides the current print context assembled from auth and org providers.
///
/// This provider watches:
/// - [currentUserNameProvider] for the logged-in user's name
/// - [currentOrgProvider] for organization branding and contact info
///
/// Returns a [PrintContext] with current values and timestamp.
@riverpod
PrintContext printContext(PrintContextRef ref) {
  final userName = ref.watch(currentUserNameProvider) ?? 'Unknown User';
  final org = ref.watch(currentOrgProvider);

  return PrintContext(
    userName: userName,
    organizationName: org.name,
    organizationEmail: org.contactEmail,
    organizationPhone: org.contactPhone,
    logoAssetPath: org.largeLogoAssetPath,
    printDate: DateTime.now(),
  );
}
