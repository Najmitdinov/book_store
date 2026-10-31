import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Forma validatorlari. Xabarlar foydalanuvchi tilida qaytadi.
class Validators {
  Validators(this.context);

  final BuildContext context;

  static final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? context.tr('v_required') : null;

  String? email(String? v) {
    if (required(v) != null) return required(v);
    return _emailRe.hasMatch(v!.trim()) ? null : context.tr('v_email');
  }

  String? password(String? v) {
    if (required(v) != null) return required(v);
    return v!.length < 6 ? context.tr('v_password_short') : null;
  }

  String? positiveNumber(String? v) {
    if (required(v) != null) return required(v);
    final n = num.tryParse(v!.replaceAll(',', '.'));
    return (n == null || n < 0) ? context.tr('v_number') : null;
  }

  String? discount(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null) return context.tr('v_number');
    return (n < 0 || n > 90) ? context.tr('v_discount_range') : null;
  }

  String? rating(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = double.tryParse(v.replaceAll(',', '.'));
    return (n == null || n < 0 || n > 5) ? context.tr('v_number') : null;
  }

  String? imageUrl(String? v) {
    if (required(v) != null) return required(v);
    final uri = Uri.tryParse(v!.trim());
    final ok = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? null : context.tr('v_url');
  }
}
