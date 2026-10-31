import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/app_exception.dart';
import '../data/local/local_storage.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/store_repositories.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository authRepository,
    required LocalStorage storage,
  })  : _authRepo = authRepository,
        _storage = storage;

  final AuthRepository _authRepo;
  final LocalStorage _storage;

  /// ApiClient yaratilgandan keyin ulanadi (aylanma bog'liqlikni oldini olish).
  ProfileRepository? profileRepository;

  AuthStatus _status = AuthStatus.unknown;
  AuthSession? _session;
  UserProfile? _profile;
  Future<AuthSession>? _refreshing;

  AuthStatus get status => _status;
  bool get isAuth => _status == AuthStatus.authenticated;
  String? get uid => _session?.uid;
  String get email => _session?.email ?? '';
  UserProfile? get profile => _profile;
  bool get isAdmin => _profile?.isAdmin ?? false;
  String get displayName =>
      _profile?.displayName ?? email.split('@').first;

  /// Ilova ishga tushganda saqlangan sessiyani tiklaydi.
  Future<void> restore() async {
    final saved = AuthSession.fromJson(_storage.readSession());
    if (saved == null) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }
    _session = saved;
    try {
      if (saved.needsRefresh) await validToken();
      _setStatus(AuthStatus.authenticated);
      unawaited(loadProfile());
    } on AppException catch (e) {
      if (e.code == 'err_network' || e.code == 'err_timeout') {
        // Oflayn: sessiyani saqlab qolamiz, internet qaytganda yangilanadi.
        _setStatus(AuthStatus.authenticated);
      } else {
        await logout();
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    final session = await _authRepo.signIn(email, password);
    await _startSession(session);
    await loadProfile();
  }

  Future<void> signUp(String name, String email, String password) async {
    final session = await _authRepo.signUp(email, password);
    await _startSession(session);
    final profile = UserProfile(
      uid: session.uid,
      email: session.email,
      name: name.trim(),
      avatarColor: DateTime.now().millisecond % 6,
    );
    _profile = profile;
    notifyListeners();
    try {
      await profileRepository?.save(profile);
    } catch (_) {
      // Profilni keyinroq saqlash mumkin — ro'yxatdan o'tish to'xtamaydi.
    }
  }

  Future<void> sendPasswordReset([String? email]) =>
      _authRepo.sendPasswordReset(email ?? this.email);

  Future<void> loadProfile() async {
    final s = _session;
    final repo = profileRepository;
    if (s == null || repo == null) return;
    try {
      _profile = await repo.fetch(s.uid, s.email);
      notifyListeners();
    } catch (_) {
      _profile ??= UserProfile(uid: s.uid, email: s.email, name: '');
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, int? avatarColor}) async {
    final current = _profile;
    if (current == null) return;
    final updated = current.copyWith(name: name, avatarColor: avatarColor);
    _profile = updated;
    notifyListeners();
    try {
      await profileRepository?.save(updated);
    } catch (e) {
      _profile = current;
      notifyListeners();
      rethrow;
    }
  }

  /// Har bir API so'rovi uchun amaldagi token. Muddati tugayotgan bo'lsa,
  /// bir martalik (single-flight) yangilash bajariladi.
  Future<String?> validToken() async {
    final s = _session;
    if (s == null) return null;
    if (!s.needsRefresh) return s.idToken;

    _refreshing ??= _authRepo.refresh(s).then((fresh) async {
      _session = fresh;
      await _storage.writeSession(fresh.toJson());
      return fresh;
    }).whenComplete(() => _refreshing = null);

    try {
      return (await _refreshing!).idToken;
    } on AppException catch (e) {
      if (e.code == 'err_session_expired') {
        await logout();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    _session = null;
    _profile = null;
    await _storage.clearSession();
    _setStatus(AuthStatus.unauthenticated);
  }

  Future<void> _startSession(AuthSession session) async {
    _session = session;
    await _storage.writeSession(session.toJson());
    _setStatus(AuthStatus.authenticated);
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}
