import 'package:flutter_test/flutter_test.dart';
import 'package:kilometer_check/core/utils/formatters/formatters.dart';

void main() {
  group('NumberFormatter.thousands', () {
    test('agrega separadores de miles', () {
      expect(NumberFormatter.thousands(0), '0');
      expect(NumberFormatter.thousands(999), '999');
      expect(NumberFormatter.thousands(1000), '1,000');
      expect(NumberFormatter.thousands(539343), '539,343');
      expect(NumberFormatter.thousands(1234567), '1,234,567');
    });

    test('soporta negativos y separador custom', () {
      expect(NumberFormatter.thousands(-1234567), '-1,234,567');
      expect(NumberFormatter.thousands(539343, separator: ' '), '539 343');
    });
  });

  group('TimeFormatter.hms', () {
    test('formatea con dos dígitos', () {
      expect(TimeFormatter.hms(DateTime(2026, 7, 13, 9, 5, 3)), '09:05:03');
      expect(TimeFormatter.hms(DateTime(2026, 7, 13, 23, 59, 59)), '23:59:59');
    });
  });
}
