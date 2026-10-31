/// Ilovadagi barcha kutilgan xatolar uchun yagona tur.
///
/// [code] — tarjima kaliti (masalan `err_network`), UI uni foydalanuvchi
/// tilida ko'rsatadi.
class AppException implements Exception {
  final String code;
  final String? details;

  const AppException(this.code, [this.details]);

  factory AppException.fromFirebaseAuth(String message) {
    // Firebase "EMAIL_EXISTS : ..." ko'rinishida qaytarishi mumkin.
    final key = message.split(' ').first.trim();
    switch (key) {
      case 'EMAIL_EXISTS':
        return const AppException('err_email_exists');
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AppException('err_invalid_credentials');
      case 'USER_DISABLED':
        return const AppException('err_user_disabled');
      case 'WEAK_PASSWORD':
        return const AppException('err_weak_password');
      case 'INVALID_EMAIL':
        return const AppException('err_invalid_email');
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return const AppException('err_too_many');
      case 'TOKEN_EXPIRED':
      case 'INVALID_ID_TOKEN':
      case 'INVALID_REFRESH_TOKEN':
        return const AppException('err_session_expired');
      default:
        return AppException('err_unknown', message);
    }
  }

  @override
  String toString() => 'AppException($code${details != null ? ', $details' : ''})';
}
