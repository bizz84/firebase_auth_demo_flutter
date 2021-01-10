import 'dart:async';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:random_string/random_string.dart' as random;

/// Mock authentication service to be used for testing the UI
/// Keeps an in-memory store of registered accounts so that registration and sign in flows can be tested.
class MockAuthService implements AuthService {
  MockAuthService({
    this.startupTime = const Duration(milliseconds: 250),
    this.responseTime = const Duration(seconds: 2),
  }) {
    Future<void>.delayed(responseTime).then((_) {
      _add(null);
    });
  }
  final Duration startupTime;
  final Duration responseTime;

  final Map<String, _UserData> _usersStore = <String, _UserData>{};

  MyAppUser _currentUser;

  final StreamController<MyAppUser> _onAuthStateChangedController =
      StreamController<MyAppUser>();
  @override
  Stream<MyAppUser> get onAuthStateChanged =>
      _onAuthStateChangedController.stream;

  @override
  Future<MyAppUser> currentUser() async {
    await Future<void>.delayed(startupTime);
    return _currentUser;
  }

  @override
  Future<MyAppUser> createUserWithEmailAndPassword(
      String email, String password) async {
    await Future<void>.delayed(responseTime);
    if (_usersStore.keys.contains(email)) {
      throw PlatformException(
        code: 'ERROR_EMAIL_ALREADY_IN_USE',
        message: 'The email address is already registered. Sign in instead?',
      );
    }
    final MyAppUser user =
        MyAppUser(uid: random.randomAlphaNumeric(32), email: email);
    _usersStore[email] = _UserData(password: password, user: user);
    _add(user);
    return user;
  }

  @override
  Future<MyAppUser> signInWithEmailAndPassword(
      String email, String password) async {
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
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<MyAppUser> signInWithEmailAndLink({String email, String link}) async {
    await Future<void>.delayed(responseTime);
    final MyAppUser user = MyAppUser(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  bool isSignInWithEmailLink(String link) => true;

  @override
  Future<void> sendSignInWithEmailLink({
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String iOSBundleId,
    @required String androidPackageName,
    @required bool androidInstallApp,
    @required String androidMinimumVersion,
  }) async {}

  @override
  Future<void> signOut() async {
    _add(null);
  }

  void _add(MyAppUser user) {
    _currentUser = user;
    _onAuthStateChangedController.add(user);
  }

  @override
  Future<MyAppUser> signInAnonymously() async {
    await Future<void>.delayed(responseTime);
    final MyAppUser user = MyAppUser(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  Future<MyAppUser> signInWithFacebook() async {
    await Future<void>.delayed(responseTime);
    final MyAppUser user = MyAppUser(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  Future<MyAppUser> signInWithGoogle() async {
    await Future<void>.delayed(responseTime);
    final MyAppUser user = MyAppUser(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  Future<MyAppUser> signInWithApple({List<Scope> scopes}) async {
    await Future<void>.delayed(responseTime);
    final MyAppUser user = MyAppUser(uid: random.randomAlphaNumeric(32));
    _add(user);
    return user;
  }

  @override
  void dispose() {
    _onAuthStateChangedController.close();
  }
}

class _UserData {
  _UserData({@required this.password, @required this.user});
  final String password;
  final MyAppUser user;
}
