import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:random_string/random_string.dart' as random;

class _UserData {
  _UserData({@required this.password, @required this.user});
  final String password;
  final User user;
}

/// Mock authentication service to be used for testing the UI
/// Keeps an in-memory store of registered accounts so that registration and sign in flows can be tested.
class MockAuthService implements AuthService {
  MockAuthService({
    this.startupTime = const Duration(milliseconds: 500),
    this.responseTime = const Duration(seconds: 2),
  }) {
    Future<void>.delayed(responseTime).then((_) {
      _add(null);
    });
  }
  final Duration startupTime;
  final Duration responseTime;

  final Map<String, _UserData> _usersStore = <String, _UserData>{};

  User _currentUser;

  final StreamController<User> _onAuthStateChangedController = StreamController<User>();
  @override
  Stream<User> get onAuthStateChanged => _onAuthStateChangedController.stream;

  @override
  Future<User> currentUser() async {
    await Future<void>.delayed(startupTime);
    return _currentUser;
  }

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    await Future<void>.delayed(responseTime);
    if (_usersStore.keys.contains(email)) {
      throw PlatformException(
        code: 'ERROR_EMAIL_ALREADY_IN_USE',
        message: 'The email address is already registered. Sign in instead?',
      );
    }
    final User user = User(uid: random.randomAlphaNumeric(32), email: email);
    _usersStore[email] = _UserData(password: password, user: user);
    _add(user);
    return user;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    await Future<void>.delayed(responseTime);
    if (!_usersStore.keys.contains(email)) {
      throw PlatformException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'The email address is not registered. Need an account?',
      );
    }
    final _UserData _userData = _usersStore[email];
    if (_userData.password != password) {
      throw PlatformException(
        code: 'ERROR_WRONG_PASSWORD',
        message: 'The password is incorrect. Please try again.',
      );
    }
    _add(_userData.user);
    return _userData.user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {

  }


  @override
  Future<void> signOut() async {
    _add(null);
  }

  void _add(User user) {
    _currentUser = user;
    _onAuthStateChangedController.add(user);
  }

  @override
  Future<User> signInAnonymously() async {
    await Future<void>.delayed(responseTime);
    final User user = User(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  Future<User> signInWithFacebook() async {
    await Future<void>.delayed(responseTime);
    final User user = User(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    await Future<void>.delayed(responseTime);
    final User user = User(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  void dispose() {
    _onAuthStateChangedController.close();
  }
}
