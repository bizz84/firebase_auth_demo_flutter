import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_model.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class EmailPasswordSignInBloc {
  EmailPasswordSignInBloc({@required this.auth});
  final AuthService auth;

  final StreamController<EmailPasswordSignInModel> _modelController =
      StreamController<EmailPasswordSignInModel>();
  Stream<EmailPasswordSignInModel> get modelStream => _modelController.stream;
  EmailPasswordSignInModel _model = EmailPasswordSignInModel();

  // Setters
  void updateEmail(String email) => _updateWith(email: email);

  void updatePassword(String password) => _updateWith(password: password);

  void updateFormType(EmailPasswordSignInFormType formType) {
    _updateWith(
      email: '',
      password: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  // logic
  Future<bool> submit() async {
    try {
      _updateWith(submitted: true);
      if (!_model.canSubmit) {
        return false;
      }
      _updateWith(isLoading: true);
      switch (_model.formType) {
        case EmailPasswordSignInFormType.signIn:
          await auth.signInWithEmailAndPassword(_model.email, _model.password);
          break;
        case EmailPasswordSignInFormType.register:
          await auth.createUserWithEmailAndPassword(_model.email, _model.password);
          break;
        case EmailPasswordSignInFormType.forgotPassword:
          await auth.sendPasswordResetEmail(_model.email);
          break;
      }
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _updateWith(isLoading: false);
    }
  }

  // updates
  void _updateWith({
    String email,
    String password,
    EmailPasswordSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    _model = _model.copyWith(
      email: email,
      password: password,
      formType: formType,
      isLoading: isLoading,
      submitted: submitted,
    );
    _modelController.add(_model);
  }

  void dispose() {
    _modelController.close();
  }
}
