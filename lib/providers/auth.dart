import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiredDate;
  String? _userId;
  String? _email;
  Timer? _autoLogOut;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiredDate != null &&
        _expiredDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  String? get email {
    return _email;
  }

  final apiKey = 'AIzaSyC9dDo8rAZgmz3XiENOcqnKf0sbQOappbo';
  final signUpKey = 'signUp';
  final signInKey = 'signInWithPassword';

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final data = jsonDecode(response.body);
      if (data['error'] != null) {
        throw HttpException(data['error']['message']);
      }
      _token = data['idToken'];
      _expiredDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            data['expiresIn'],
          ),
        ),
      );
      _userId = data['localId'];
      _email = data['email'];
      autoLogOutFunction;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final sharedData = jsonEncode(
        {
          'token': _token,
          'expiredDate': _expiredDate!.toIso8601String(),
          'userId': _userId,
          'email': _email
        },
      );
      prefs.setString('sharedData', sharedData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, signUpKey);
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, signInKey);
  }

  Future<bool> autoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('sharedData')) {
      return false;
    }
    final data =
        jsonDecode(prefs.getString('sharedData')!) as Map<String, dynamic>;
    final expiredDate = DateTime.parse(data['expiredDate']);

    if (expiredDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = data['token'];
    _expiredDate = expiredDate;
    _userId = data['userId'];
    _email = data['email'];
    notifyListeners();
    autoLogOutFunction();
    return true;
  }

  void logOut() async {
    _token = null;
    _expiredDate = null;
    _userId = null;
    if (_autoLogOut != null) {
      _autoLogOut!.cancel();
      _autoLogOut = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogOutFunction() {
    if (_autoLogOut != null) {
      _autoLogOut!.cancel();
    }
    final time = _expiredDate!.difference(DateTime.now()).inSeconds;
    _autoLogOut = Timer(Duration(seconds: time), logOut);
  }
}
