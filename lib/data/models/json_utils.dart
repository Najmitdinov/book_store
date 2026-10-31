/// Firebase JSON'idan xavfsiz o'qish yordamchilari.
///
/// Firebase `12.0` ni ba'zan `12` (int) qilib qaytaradi, eski yozuvlarda
/// maydonlar umuman bo'lmasligi mumkin — shuning uchun hamma narsa himoyalangan.
double asDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

int asInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

String asString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  return v.toString();
}

DateTime asDate(dynamic v, [DateTime? fallback]) {
  if (v is String) {
    final d = DateTime.tryParse(v);
    if (d != null) return d;
  }
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  return fallback ?? DateTime.now();
}

List<String> asStringList(dynamic v) {
  if (v is List) {
    return v.where((e) => e != null).map((e) => e.toString()).toList();
  }
  if (v is Map) {
    return v.values.where((e) => e != null).map((e) => e.toString()).toList();
  }
  if (v is String && v.isNotEmpty) {
    return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return const [];
}

Map<String, dynamic> asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return const {};
}
