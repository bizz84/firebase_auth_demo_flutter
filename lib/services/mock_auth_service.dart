import 'dart:async';

import 'package:meta/meta.dart';
import 'package:random_string/random_string.dart' as random;
import 'package:email_password_auth_flutter/services/auth_service.dart';

enum AuthServiceExceptionType {
  emailAlreadyRegistered,
  emailNotFound,
  incorrectPassword,
}

class AuthServiceException implements Exception {
  AuthServiceException(this.authServiceExceptionType);
  final AuthServiceExceptionType authServiceExceptionType;

  @override
  String toString() {
    return messages[authServiceExceptionType];
  }

  static Map<AuthServiceExceptionType, String> messages = <AuthServiceExceptionType, String>{
    AuthServiceExceptionType.emailAlreadyRegistered: 'This email was already registered',
    AuthServiceExceptionType.emailNotFound: 'An account does not exist for this email',
    AuthServiceExceptionType.incorrectPassword: 'This password is incorrect',
  };
}

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
    await Future<void>.delayed(responseTime);
    return _currentUser;
  }

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    await Future<void>.delayed(responseTime);
    if (_usersStore.keys.contains(email)) {
      throw AuthServiceException(AuthServiceExceptionType.emailAlreadyRegistered);
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
      throw AuthServiceException(AuthServiceExceptionType.emailNotFound);
    }
    final _UserData _userData = _usersStore[email];
    if (_userData.password != password) {
      throw AuthServiceException(AuthServiceExceptionType.incorrectPassword);
    }
    _add(_userData.user);
    return _userData.user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(responseTime);
    _add(null);
  }

  void _add(User user) {
    _currentUser = user;
    _onAuthStateChangedController.add(user);
  }
}
