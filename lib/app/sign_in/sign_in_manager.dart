import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class SignInModel with ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  set loading(bool newValue) {
    _loading = newValue;
    notifyListeners();
  }
}

class SignInManager {
  SignInManager({@required this.auth});
  final AuthService auth;

  Future<User> _signIn(SignInModel model, Future<User> Function() signInMethod) async {
    try {
      model.loading = true;
      return await signInMethod();
    } catch (e) {
      rethrow;
    } finally {
      model.loading = false;
    }
  }

  Future<User> signInAnonymously(SignInModel model) async {
    return await _signIn(model, auth.signInAnonymously);
  }

  Future<void> signInWithGoogle(SignInModel model) async {
    return await _signIn(model, auth.signInWithGoogle);
  }

  Future<void> signInWithFacebook(SignInModel model) async {
    return await _signIn(model, auth.signInWithFacebook);
  }
}