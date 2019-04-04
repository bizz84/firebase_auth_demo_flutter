
import 'package:firebase_auth_demo_flutter/app/sign_in/validator.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';

enum EmailPasswordSignInFormType { signIn, register }

class EmailPasswordSignInModel with EmailAndPasswordValidators {
  EmailPasswordSignInModel({
    this.email = '',
    this.password = '',
    this.formType = EmailPasswordSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });

  final String email;
  final String password;
  final EmailPasswordSignInFormType formType;
  final bool isLoading;
  final bool submitted;

  EmailPasswordSignInModel copyWith({
    String email,
    String password,
    EmailPasswordSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    return EmailPasswordSignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      formType: formType ?? this.formType,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted,
    );
  }

  // Getters
  String get primaryButtonText {
    return formType == EmailPasswordSignInFormType.signIn
        ? Strings.signIn
        : Strings.createAnAccount;
  }

  String get secondaryButtonText {
    return formType == EmailPasswordSignInFormType.signIn
        ? Strings.needAnAccount
        : Strings.haveAnAccount;
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email);
  }

  bool get canSubmitPassword {
    return passwordSubmitValidator.isValid(password);
  }

  bool get canSubmit {
    return canSubmitEmail && canSubmitPassword && !isLoading;
  }

  String get emailErrorText {
    final bool showErrorText = submitted && !canSubmitEmail;
    return showErrorText ? Strings.invalidEmailErrorText : null;
  }

  String get passwordErrorText {
    final bool showErrorText = submitted && !canSubmitPassword;
    return showErrorText ? Strings.invalidPasswordErrorText : null;
  }

  @override
  String toString() {
    return 'email: $email, password: $password, formType: $formType, isLoading: $isLoading, submitted: $submitted';
  }
}
