import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/utils/email_validator.dart';

void main() {
  group('EmailDomainValidator', () {
    test('whitelisted email bypasses domain restrictions', () {
      expect(
        EmailDomainValidator.validate(
          'admin@gmail.com',
          allowedDomains: ['rescuenet.net'],
          whitelistedEmails: ['admin@gmail.com'],
        ),
        null,
      );
    });

    test('empty allowedDomains allows any email', () {
      expect(
        EmailDomainValidator.validate(
          'anyone@anywhere.com',
          allowedDomains: [],
          whitelistedEmails: [],
        ),
        null,
      );
    });

    test('valid domain passes validation', () {
      expect(
        EmailDomainValidator.validate(
          'user@rescuenet.net',
          allowedDomains: ['rescuenet.net'],
          whitelistedEmails: [],
        ),
        null,
      );
    });

    test('invalid domain fails validation', () {
      final result = EmailDomainValidator.validate(
        'user@invalid.com',
        allowedDomains: ['rescuenet.net'],
        whitelistedEmails: [],
      );
      expect(result, isNotNull);
      expect(result, contains('rescuenet.net'));
    });

    test('case insensitive matching', () {
      expect(
        EmailDomainValidator.validate(
          'User@RescueNet.NET',
          allowedDomains: ['rescuenet.net'],
          whitelistedEmails: [],
        ),
        null,
      );
    });
  });
}
