
import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_model.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/validator.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:flutter/foundation.dart';

class EmailPasswordSignInModelMutable with EmailAndPasswordValidators, ChangeNotifier {
  EmailPasswordSignInModelMutable({
    this.email = '',
    this.password = '',
    this.formType = EmailPasswordSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });

  String email;
  String password;
  EmailPasswordSignInFormType formType;
  bool isLoading;
  bool submitted;

  void updateWith({
    String email,
    String password,
    EmailPasswordSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    this.email ??= email;
    this.password ??= password;
    this.formType ??= formType;
    this.isLoading ??= isLoading;
    this.submitted ??= submitted;
    notifyListeners();
  }

  // Getters
  String get primaryButtonText {
    return <EmailPasswordSignInFormType,String>{
      EmailPasswordSignInFormType.register: Strings.createAnAccount,
      EmailPasswordSignInFormType.signIn: Strings.signIn,
      EmailPasswordSignInFormType.forgotPassword: Strings.sendResetLink,
    }[formType];
  }

  String get secondaryButtonText {
    return <EmailPasswordSignInFormType,String>{
      EmailPasswordSignInFormType.register: Strings.haveAnAccount,
      EmailPasswordSignInFormType.signIn: Strings.needAnAccount,
      EmailPasswordSignInFormType.forgotPassword: Strings.backToSignIn,
    }[formType];
  }

  EmailPasswordSignInFormType get secondaryActionFormType {
    return <EmailPasswordSignInFormType,EmailPasswordSignInFormType>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInFormType.signIn,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInFormType.register,
      EmailPasswordSignInFormType.forgotPassword: EmailPasswordSignInFormType.signIn,
    }[formType];
  }

  String get errorAlertTitle {
    return <EmailPasswordSignInFormType,String>{
      EmailPasswordSignInFormType.register: Strings.registrationFailed,
      EmailPasswordSignInFormType.signIn: Strings.signInFailed,
      EmailPasswordSignInFormType.forgotPassword: Strings.passwordResetFailed,
    }[formType];
  }

  String get title {
    return <EmailPasswordSignInFormType,String>{
      EmailPasswordSignInFormType.register: Strings.register,
      EmailPasswordSignInFormType.signIn: Strings.signIn,
      EmailPasswordSignInFormType.forgotPassword: Strings.forgotPassword,
    }[formType];
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email);
  }

  bool get canSubmitPassword {
    return passwordSubmitValidator.isValid(password);
  }

  bool get canSubmit {
    final bool canSubmitFields = formType == EmailPasswordSignInFormType.forgotPassword ? canSubmitEmail : canSubmitEmail && canSubmitPassword;
    return canSubmitFields && !isLoading;
  }

  String get emailErrorText {
    final bool showErrorText = submitted && !canSubmitEmail;
    final String errorText = email.isEmpty ? Strings.invalidEmailEmpty : Strings.invalidEmailErrorText;
    return showErrorText ? errorText : null;
  }

  String get passwordErrorText {
    final bool showErrorText = submitted && !canSubmitPassword;
    final String errorText = password.isEmpty ? Strings.invalidPasswordEmpty : Strings.invalidPasswordTooShort;
    return showErrorText ? errorText : null;
  }

  @override
  String toString() {
    return 'email: $email, password: $password, formType: $formType, isLoading: $isLoading, submitted: $submitted';
  }
}
