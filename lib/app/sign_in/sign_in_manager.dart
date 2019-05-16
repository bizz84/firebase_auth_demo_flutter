import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class SignInManager {
  SignInManager({@required this.auth});
  final AuthService auth;

  Future<User> _signIn(ValueNotifier<bool> isLoading, Future<User> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<User> signInAnonymously(ValueNotifier<bool> isLoading) async {
    return await _signIn(isLoading, auth.signInAnonymously);
  }

  Future<void> signInWithGoogle(ValueNotifier<bool> isLoading) async {
    return await _signIn(isLoading, auth.signInWithGoogle);
  }

  Future<void> signInWithFacebook(ValueNotifier<bool> isLoading) async {
    return await _signIn(isLoading, auth.signInWithFacebook);
  }
}