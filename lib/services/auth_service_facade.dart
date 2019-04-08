import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/mock_auth_service.dart';

enum AuthServiceType { firebase, mock }

class AuthServiceFacade implements AuthService {
  AuthServiceFacade() {
    setup();
  }
  AuthServiceType authServiceType = AuthServiceType.firebase;

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final MockAuthService _mockAuthService = MockAuthService();
  AuthService get authService => authServiceType == AuthServiceType.firebase ? _firebaseAuthService : _mockAuthService;

  StreamSubscription<User> _firebaseAuthSubscription;
  StreamSubscription<User> _mockAuthSubscription;

  void setup() {
    // Observable<User>.merge was considered here, but we need more fine grained control to ensure
    // that only events from the currently active service are processed
    _firebaseAuthSubscription = _firebaseAuthService.onAuthStateChanged.listen((User user) {
      if (authServiceType == AuthServiceType.firebase) {
        print('firebase user: $user');
        _onAuthStateChangedController.add(user);
      }
    }, onError: (dynamic error) {
      if (authServiceType == AuthServiceType.firebase) {
        _onAuthStateChangedController.addError(error);
      }
    });
    _mockAuthSubscription = _mockAuthService.onAuthStateChanged.listen((User user) {
      if (authServiceType == AuthServiceType.mock) {
        print('mock user: $user');
        _onAuthStateChangedController.add(user);
      }
    }, onError: (dynamic error) {
      if (authServiceType == AuthServiceType.mock) {
        _onAuthStateChangedController.addError(error);
      }
    });
  }

  void dispose() {
    _firebaseAuthSubscription?.cancel();
    _mockAuthSubscription?.cancel();
    _onAuthStateChangedController?.close();
  }

  final StreamController<User> _onAuthStateChangedController = StreamController<User>();
  @override
  Stream<User> get onAuthStateChanged => _onAuthStateChangedController.stream;

  @override
  Future<User> currentUser() => authService.currentUser();

  @override
  Future<User> signInAnonymously() => authService.signInAnonymously();

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) =>
      authService.createUserWithEmailAndPassword(email, password);

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) =>
      authService.signInWithEmailAndPassword(email, password);

  @override
  Future<User> signInWithFacebook() => authService.signInWithFacebook();

  @override
  Future<User> signInWithGoogle() => authService.signInWithGoogle();

  @override
  Future<void> signOut() => authService.signOut();
}
