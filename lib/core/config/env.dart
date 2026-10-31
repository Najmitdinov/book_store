/// Ilova konfiguratsiyasi.
///
/// Qiymatlarni build paytida almashtirish mumkin:
/// `flutter run --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_DB_URL=...`
///
/// Standart qiymatlar mavjud Firebase loyihasiga (book-store-14cd2) ulanadi.
class Env {
  Env._();

  static const firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyC9dDo8rAZgmz3XiENOcqnKf0sbQOappbo',
  );

  static const firebaseDbUrl = String.fromEnvironment(
    'FIREBASE_DB_URL',
    defaultValue: 'https://book-store-14cd2-default-rtdb.firebaseio.com',
  );

  /// Google Books uchun bepul API kalit (ixtiyoriy). Kalitsiz ham ishlaydi,
  /// lekin kunlik limit juda kichik:
  /// `--dart-define=GOOGLE_BOOKS_API_KEY=...`
  static const googleBooksApiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

  static const authBaseUrl = 'https://identitytoolkit.googleapis.com/v1';
  static const tokenBaseUrl = 'https://securetoken.googleapis.com/v1';

  static const appName = 'Kitobxon';

  static const requestTimeout = Duration(seconds: 20);
}
