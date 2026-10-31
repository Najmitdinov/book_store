import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/env.dart';
import '../../core/network/app_exception.dart';
import '../models/json_utils.dart';

/// Kirgan foydalanuvchi sessiyasi.
class AuthSession {
  final String idToken;
  final String refreshToken;
  final String uid;
  final String email;
  final DateTime expiresAt;

  const AuthSession({
    required this.idToken,
    required this.refreshToken,
    required this.uid,
    required this.email,
    required this.expiresAt,
  });

  /// Token tugashiga 1 daqiqadan kam qolgan bo'lsa — yangilash kerak.
  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 1)));

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        'refreshToken': refreshToken,
        'uid': uid,
        'email': email,
        'expiresAt': expiresAt.toIso8601String(),
      };

  static AuthSession? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final refresh = asString(json['refreshToken']);
    final uid = asString(json['uid']);
    if (refresh.isEmpty || uid.isEmpty) return null;
    return AuthSession(
      idToken: asString(json['idToken']),
      refreshToken: refresh,
      uid: uid,
      email: asString(json['email']),
      expiresAt: asDate(json['expiresAt'], DateTime(2000)),
    );
  }
}

/// Firebase Authentication REST API.
class AuthRepository {
  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthSession> signIn(String email, String password) =>
      _authenticate('signInWithPassword', email, password);

  Future<AuthSession> signUp(String email, String password) =>
      _authenticate('signUp', email, password);

  Future<void> sendPasswordReset(String email) async {
    await _post(
      Uri.parse(
        '${Env.authBaseUrl}/accounts:sendOobCode?key=${Env.firebaseApiKey}',
      ),
      jsonEncode({'requestType': 'PASSWORD_RESET', 'email': email.trim()}),
    );
  }

  /// Refresh-token orqali yangi idToken oladi — foydalanuvchi har soatda
  /// qayta kirishi shart emas.
  Future<AuthSession> refresh(AuthSession session) async {
    final data = await _post(
      Uri.parse('${Env.tokenBaseUrl}/token?key=${Env.firebaseApiKey}'),
      'grant_type=refresh_token&refresh_token=${Uri.encodeQueryComponent(session.refreshToken)}',
      form: true,
    );
    return AuthSession(
      idToken: asString(data['id_token']),
      refreshToken: asString(data['refresh_token'], session.refreshToken),
      uid: asString(data['user_id'], session.uid),
      email: session.email,
      expiresAt: DateTime.now()
          .add(Duration(seconds: asInt(data['expires_in'], 3600))),
    );
  }

  Future<AuthSession> _authenticate(
    String segment,
    String email,
    String password,
  ) async {
    final data = await _post(
      Uri.parse('${Env.authBaseUrl}/accounts:$segment?key=${Env.firebaseApiKey}'),
      jsonEncode({
        'email': email.trim(),
        'password': password,
        'returnSecureToken': true,
      }),
    );
    return AuthSession(
      idToken: asString(data['idToken']),
      refreshToken: asString(data['refreshToken']),
      uid: asString(data['localId']),
      email: asString(data['email'], email.trim()),
      expiresAt: DateTime.now()
          .add(Duration(seconds: asInt(data['expiresIn'], 3600))),
    );
  }

  Future<Map<String, dynamic>> _post(
    Uri url,
    String body, {
    bool form = false,
  }) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: {
              'Content-Type': form
                  ? 'application/x-www-form-urlencoded'
                  : 'application/json',
            },
            body: body,
          )
          .timeout(Env.requestTimeout);
    } on SocketException {
      throw const AppException('err_network');
    } on TimeoutException {
      throw const AppException('err_timeout');
    } on http.ClientException {
      throw const AppException('err_network');
    }

    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : asMap(jsonDecode(response.body));
    final error = data['error'];
    if (error != null) {
      final message = error is Map ? asString(error['message']) : '$error';
      throw AppException.fromFirebaseAuth(message);
    }
    return data;
  }
}
