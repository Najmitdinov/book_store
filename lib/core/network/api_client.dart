import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'app_exception.dart';

/// Har so'rov oldidan amaldagi (kerak bo'lsa yangilangan) tokenni qaytaradi.
typedef TokenProvider = Future<String?> Function();

/// Firebase Realtime Database REST API uchun yupqa qobiq.
///
/// * Har bir so'rovga `auth` tokenini qo'shadi.
/// * Timeout, tarmoq va HTTP xatolarini [AppException] ga aylantiradi.
class ApiClient {
  ApiClient({http.Client? client, required TokenProvider tokenProvider})
      : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider;

  final http.Client _client;
  final TokenProvider _tokenProvider;

  Future<Uri> _uri(String path, [Map<String, String>? query]) async {
    final token = await _tokenProvider();
    final params = <String, String>{
      if (token != null) 'auth': token,
      ...?query,
    };
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('${Env.firebaseDbUrl}/$clean.json')
        .replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    return _send(() async => _client.get(await _uri(path, query)));
  }

  /// Yangi yozuv yaratadi va Firebase bergan kalitni qaytaradi.
  Future<String> post(String path, Map<String, dynamic> body) async {
    final data = await _send(
      () async => _client.post(await _uri(path), body: jsonEncode(body)),
    );
    return (data as Map<String, dynamic>)['name'] as String;
  }

  Future<dynamic> put(String path, Object? body) async {
    return _send(
      () async => _client.put(await _uri(path), body: jsonEncode(body)),
    );
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    return _send(
      () async => _client.patch(await _uri(path), body: jsonEncode(body)),
    );
  }

  Future<void> delete(String path) async {
    await _send(() async => _client.delete(await _uri(path)));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(Env.requestTimeout);
    } on SocketException {
      throw const AppException('err_network');
    } on TimeoutException {
      throw const AppException('err_timeout');
    } on http.ClientException {
      throw const AppException('err_network');
    }

    final body = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode == 401) {
      throw const AppException('err_permission');
    }
    if (response.statusCode >= 400) {
      final message =
          body is Map && body['error'] != null ? body['error'].toString() : null;
      if (message != null && message.toLowerCase().contains('permission')) {
        throw AppException('err_permission', message);
      }
      throw AppException('err_server', message ?? '${response.statusCode}');
    }
    return body;
  }
}
