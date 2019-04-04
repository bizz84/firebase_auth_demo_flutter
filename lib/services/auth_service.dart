import 'dart:async';

import 'package:meta/meta.dart';

@immutable
class User {
  const User({
    @required this.uid,
    @required this.email,
  });

  final String uid;
  final String email;
}

abstract class AuthService {
  Future<User> currentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<User> get onAuthStateChanged;
}
