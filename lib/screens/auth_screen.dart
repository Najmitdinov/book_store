import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';

enum AuthMode {
  login,
  registration,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth-screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool passwordObscureText = true;
  bool confirmPasswordObscureText = true;
  final GlobalKey<FormState> _globalKey = GlobalKey();
  final _password = TextEditingController();
  final Map<String, String> _authData = {
    'userName': '',
    'password': '',
  };

  AuthMode _authMode = AuthMode.login;
  bool isLoading = false;

  Future<void> submit() async {
    if (_globalKey.currentState!.validate()) {
      _globalKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      try {
        if (_authMode == AuthMode.login) {
          await Provider.of<Auth>(context, listen: false).signIn(
            _authData['userName']!,
            _authData['password']!,
          );
        } else {
          await Provider.of<Auth>(context, listen: false).signUp(
            _authData['userName']!,
            _authData['password']!,
          );
        }
      } on HttpException catch (error) {
        var errorMessage = 'Xatilok sodir bo\'ldi';
        if (error.message.contains('EMAIL_EXISTS')) {
          errorMessage = 'Bu foydalanuvchi oldin ro\'yxatdan o\'tgan';
        } else if (error.message.contains('INVALID_LOGIN_CREDENTIALS')) {
          errorMessage = 'Bunday foydalanuvchi topilmadi!';
        }
        _showDialog(errorMessage);
      } catch (error) {
        var errorMessage = 'Kechirasiz, xatolik sodir bo\'ldi!';
        _showDialog(errorMessage);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void swithMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.registration;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _globalKey,
              child: Column(
                children: [
                  const Text(
                    'Book Store',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Iltimos, login kiriting!';
                              } else if (!value.contains('@')) {
                                return 'Yaroqli login kiriting!';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (newValue) {
                              setState(() {
                                _authData['userName'] = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: Stack(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                controller: _password,
                                obscureText: passwordObscureText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Iltimos, parol kiriting!';
                                  } else if (value.length < 8) {
                                    return 'Parol uzunligi 8 dan uzun bo\'lishi lozim!';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  setState(() {
                                    _authData['password'] = newValue!;
                                  });
                                },
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordObscureText =
                                          !passwordObscureText;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: passwordObscureText
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_authMode == AuthMode.registration)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confirm password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Stack(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  obscureText: confirmPasswordObscureText,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Iltimos, tasdiqlash parolini kiriting';
                                    } else if (_password.text != value) {
                                      return 'Parollar bir xil bo\'lishi lozim!';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    setState(() {
                                      _authData['password'] = newValue!;
                                    });
                                  },
                                ),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        confirmPasswordObscureText =
                                            !confirmPasswordObscureText;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: confirmPasswordObscureText
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black,
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeAlign: -1,
                              ),
                            )
                          : Text(
                              _authMode == AuthMode.login
                                  ? 'KIRISH'
                                  : 'RO\'YXATDAN O\'TISH',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(
                        color: Colors.black,
                        height: 1,
                      ),
                      Text('OR'),
                      Divider(
                        color: Colors.black,
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _authMode == AuthMode.login
                            ? 'Akkauntim yo\'q'
                            : 'Allaqachon akkauntim bor',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: swithMode,
                        child: Text(
                          _authMode == AuthMode.registration
                              ? 'KIRISH'
                              : 'RO\'YXATDAN O\'TISH',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
