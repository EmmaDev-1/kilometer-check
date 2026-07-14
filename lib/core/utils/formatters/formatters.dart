/// Formateadores ligeros de presentación (sin dependencias externas).
final class NumberFormatter {
  const NumberFormatter._();

  /// Agrega separador de miles: `539343` → `539,343`.
  static String thousands(int value, {String separator = ','}) {
    final String digits = value.abs().toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(separator);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }
}

final class TimeFormatter {
  const TimeFormatter._();

  /// Hora local en formato `HH:mm:ss`.
  static String hms(DateTime time) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}';
  }
}
