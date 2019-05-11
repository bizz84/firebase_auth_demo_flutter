import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_model.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class EmailPasswordSignInManager {
  EmailPasswordSignInManager({@required this.auth});
  final AuthService auth;

  // logic
  Future<bool> submit(EmailPasswordSignInModel model) async {
    try {
      model.updateWith(submitted: true);
      if (!model.canSubmit) {
        return false;
      }
      model.updateWith(isLoading: true);
      switch (model.formType) {
        case EmailPasswordSignInFormType.signIn:
          await auth.signInWithEmailAndPassword(model.email, model.password);
          break;
        case EmailPasswordSignInFormType.register:
          await auth.createUserWithEmailAndPassword(model.email, model.password);
          break;
        case EmailPasswordSignInFormType.forgotPassword:
          await auth.sendPasswordResetEmail(model.email);
          break;
      }
      return true;
    } catch (e) {
      rethrow;
    } finally {
      model.updateWith(isLoading: false);
    }
  }
}
