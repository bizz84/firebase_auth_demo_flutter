import 'dart:async';

import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/email_secure_store.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

enum EmailLinkErrorType {
  linkError,
  isNotSignInWithEmailLink,
  emailNotSet,
  signInFailed,
  userAlreadySignedIn,
}

class EmailLinkError {
  EmailLinkError({@required this.error, this.description});
  final EmailLinkErrorType error;
  final String description;

  Map<EmailLinkErrorType, String> get _messages => {
        EmailLinkErrorType.linkError: description,
        EmailLinkErrorType.isNotSignInWithEmailLink:
            Strings.isNotSignInWithEmailLinkMessage,
        EmailLinkErrorType.emailNotSet: Strings.submitEmailAgain,
        EmailLinkErrorType.signInFailed: description,
        EmailLinkErrorType.userAlreadySignedIn: Strings.userAlreadySignedIn,
      };

  String get message => _messages[error];

  @override
  String toString() => '$error: ${_messages[error]}';

  @override
  int get hashCode => error.hashCode;
  @override
  bool operator ==(dynamic other) {
    if (other is EmailLinkError) {
      return error == other.error && description == other.description;
    }
    return false;
  }
}

/// Checks incoming dynamic links and uses them to sign in the user with Firebase
class FirebaseEmailLinkHandler with WidgetsBindingObserver {
  FirebaseEmailLinkHandler({
    @required this.auth,
    @required this.widgetsBinding,
    @required this.emailStore,
  }) {
    // Register WidgetsBinding observer so that we can detect when the app is resumed.
    // See [didChangeAppLifecycleState].
    widgetsBinding.addObserver(this);
  }
  final AuthService auth;
  final WidgetsBinding widgetsBinding;
  final EmailSecureStore emailStore;

  static FirebaseEmailLinkHandler createAndConfigure({
    @required AuthService auth,
    @required EmailSecureStore userCredentialsStorage,
  }) {
    final linkHandler = FirebaseEmailLinkHandler(
      auth: auth,
      widgetsBinding: WidgetsBinding.instance,
      emailStore: userCredentialsStorage,
    );
    // Check dynamic link once on app startup. This is required to process any dynamic links that may have opened
    // the app when it was closed.
    FirebaseDynamicLinks.instance
        .getInitialLink()
        .then((link) => linkHandler._processDynamicLink(link?.link));
    // Listen to subsequent links
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (linkData) => linkHandler.handleLink(linkData?.link),
      // convert to PlatformException as OnLinkErrorCallback has private constructor and can't be tested
      onError: (error) => linkHandler.handleLinkError(PlatformException(
        code: error.code,
        message: error.message,
        details: error.details,
      )),
    );
    return linkHandler;
  }

  /// Clients can listen to this stream and show error alerts when dynamic link processing fails
  final PublishSubject<EmailLinkError> _errorController =
      PublishSubject<EmailLinkError>();
  Observable<EmailLinkError> get errorStream => _errorController.stream;

  /// Clients can listen to this stream and show a loading indicator while sign in is in progress
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<String> getEmail() => emailStore.getEmail();

  /// last link data received from FirebaseDynamicLinks
  Uri _lastUnprocessedLink;

  /// last link error received from FirebaseDynamicLinks
  PlatformException _lastUnprocessedLinkError;

  Future<dynamic> handleLink(Uri link) {
    _lastUnprocessedLink = link;
    _lastUnprocessedLinkError = null;
    return Future<dynamic>.value();
  }

  Future<dynamic> handleLinkError(PlatformException error) {
    _lastUnprocessedLink = null;
    _lastUnprocessedLinkError = error;
    return Future<dynamic>.value();
  }

  void dispose() {
    _errorController.close();
    isLoading.dispose();
    widgetsBinding.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the application comes into focus
    if (state == AppLifecycleState.resumed) {
      _checkUnprocessedLinks();
    }
  }

  /// Checks for a dynamic link, and tries to use it to sign in with email (passwordless)
  Future<void> _checkUnprocessedLinks() async {
    if (_lastUnprocessedLink != null) {
      await _processDynamicLink(_lastUnprocessedLink);
      _lastUnprocessedLink = null;
    }
    if (_lastUnprocessedLinkError != null) {
      _errorController.add(EmailLinkError(
        error: EmailLinkErrorType.linkError,
        description: _lastUnprocessedLinkError.message,
      ));
      _lastUnprocessedLinkError = null;
    }
  }

  Future<void> _processDynamicLink(Uri deepLink) async {
    if (deepLink != null) {
      await _signInWithEmail(deepLink.toString());
    }
  }

  Future<void> _signInWithEmail(String link) async {
    try {
      isLoading.value = true;
      // check that user is not signed in
      final User user = await auth.currentUser();
      if (user != null) {
        _errorController.add(EmailLinkError(
          error: EmailLinkErrorType.userAlreadySignedIn,
        ));
        return;
      }
      // check that email is set
      final email = await emailStore.getEmail();
      if (email == null) {
        _errorController.add(EmailLinkError(
          error: EmailLinkErrorType.emailNotSet,
        ));
        return;
      }
      // sign in
      if (await auth.isSignInWithEmailLink(link)) {
        await auth.signInWithEmailAndLink(email: email, link: link);
      } else {
        _errorController.add(EmailLinkError(
          error: EmailLinkErrorType.isNotSignInWithEmailLink,
        ));
      }
    } on PlatformException catch (e) {
      _errorController.add(EmailLinkError(
        error: EmailLinkErrorType.signInFailed,
        description: e.message,
      ));
    } finally {
      isLoading.value = false;
    }
  }

  // sign in
  Future<void> sendSignInWithEmailLink({
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String packageName,
    @required bool androidInstallIfNotAvailable,
    @required String androidMinimumVersion,
  }) async {
    try {
      isLoading.value = true;
      // Save to email store
      await emailStore.setEmail(email);
      // Send link
      await auth.sendSignInWithEmailLink(
        email: email,
        url: url,
        handleCodeInApp: handleCodeInApp,
        iOSBundleID: packageName,
        androidPackageName: packageName,
        androidInstallIfNotAvailable: androidInstallIfNotAvailable,
        androidMinimumVersion: androidMinimumVersion,
      );
    } on PlatformException catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
