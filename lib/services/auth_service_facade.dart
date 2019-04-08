import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/mock_auth_service.dart';
import 'package:rxdart/rxdart.dart';

enum AuthServiceType { firebase, mock }

class AuthServiceFacade implements AuthService {
  AuthServiceType authServiceType = AuthServiceType.firebase;

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final MockAuthService _mockAuthService = MockAuthService();
  AuthService get authService => authServiceType == AuthServiceType.firebase ? _firebaseAuthService : _mockAuthService;

  // overrides
  @override
  Stream<User> get onAuthStateChanged => Observable<User>.merge(<Stream<User>>[
        _firebaseAuthService.onAuthStateChanged,
        _mockAuthService.onAuthStateChanged,
      ]);

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
