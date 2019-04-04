import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:meta/meta.dart';

class SignInBloc {
  SignInBloc({@required this.auth});

  final AuthService auth;

  final StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  void _setIsLoading(bool isLoading) => _isLoadingController.add(isLoading);

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      _setIsLoading(true);
      //await Future<void>.delayed(Duration(seconds: 3));
      return await signInMethod();
    } catch (e) {
      rethrow;
    } finally {
      _setIsLoading(false);
    }
  }

  Future<User> signInAnonymously() async {
    return await _signIn(auth.signInAnonymously);
  }

  Future<void> signInWithGoogle() async {
    return await _signIn(auth.signInWithGoogle);
  }

  Future<void> signInWithFacebook() async {
    return await _signIn(auth.signInWithFacebook);
  }

  void dispose() {
    _isLoadingController.close();
  }
}