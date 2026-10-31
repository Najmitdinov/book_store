import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static final _money = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  static String money(num value) => _money.format(value);

  static String date(DateTime date, String lang) {
    try {
      return DateFormat.yMMMd(lang).format(date);
    } catch (_) {
      return DateFormat.yMMMd('en').format(date);
    }
  }

  static String dateTime(DateTime date, String lang) {
    try {
      return DateFormat('d MMM yyyy, HH:mm', lang).format(date);
    } catch (_) {
      return DateFormat('d MMM yyyy, HH:mm', 'en').format(date);
    }
  }

  static String rating(double value) => value.toStringAsFixed(1);

  /// Ism-familiyadan bosh harflar: "Umar Najmitdinov" → "UN".
  static String initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    String first(String s) => String.fromCharCode(s.runes.first);
    if (parts.length == 1) return first(parts[0]).toUpperCase();
    return (first(parts[0]) + first(parts[1])).toUpperCase();
  }
}
