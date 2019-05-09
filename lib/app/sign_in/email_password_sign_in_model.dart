
import 'package:firebase_auth_demo_flutter/app/sign_in/validator.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';

enum EmailPasswordSignInFormType { signIn, register, forgotPassword }

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
