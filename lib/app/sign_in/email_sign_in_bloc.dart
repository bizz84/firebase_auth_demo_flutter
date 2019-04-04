import 'dart:async';

import 'package:email_password_auth_flutter/app/sign_in/email_sign_in_model.dart';
import 'package:email_password_auth_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class EmailSignInBloc {
  EmailSignInBloc({@required this.auth});
  final AuthService auth;

  final StreamController<EmailSignInModel> _modelController =
      StreamController<EmailSignInModel>();
  Stream<EmailSignInModel> get modelStream => _modelController.stream;
  EmailSignInModel _model = EmailSignInModel();

  // Setters
  void updateEmail(String email) => _updateWith(email: email);

  void updatePassword(String password) => _updateWith(password: password);

  void toggleFormType() {
    final EmailSignInFormType formType =
        _model.formType == EmailSignInFormType.signIn ? EmailSignInFormType.register : EmailSignInFormType.signIn;
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
      if (_model.formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_model.email, _model.password);
      } else {
        await auth.createUserWithEmailAndPassword(_model.email, _model.password);
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
    EmailSignInFormType formType,
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
