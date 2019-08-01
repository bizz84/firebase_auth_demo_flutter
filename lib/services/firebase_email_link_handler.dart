import 'dart:async';

import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/email_secure_store.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
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

  Map<EmailLinkErrorType, String> get _descriptions => {
        EmailLinkErrorType.linkError: description,
        EmailLinkErrorType.isNotSignInWithEmailLink: Strings.isNotSignInWithEmailLinkMessage,
        EmailLinkErrorType.emailNotSet: Strings.submitEmailAgain,
        EmailLinkErrorType.signInFailed: description,
        EmailLinkErrorType.userAlreadySignedIn: Strings.userAlreadySignedIn,
      };

  @override
  String toString() => _descriptions[error];

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
    @required this.errorController,
  }) {
    // Register WidgetsBinding observer so that we can detect when the app is resumed.
    // See [didChangeAppLifecycleState].
    widgetsBinding.addObserver(this);
  }
  final AuthService auth;
  final WidgetsBinding widgetsBinding;
  final EmailSecureStore emailStore;
  // Injecting this as couldn't find a way to test if values/errors are NOT added to the stream
  final BehaviorSubject<EmailLinkError> errorController;

  static FirebaseEmailLinkHandler createAndConfigure({
    @required AuthService auth,
    @required EmailSecureStore userCredentialsStorage,
  }) {
    final linkHandler = FirebaseEmailLinkHandler(
      auth: auth,
      widgetsBinding: WidgetsBinding.instance,
      emailStore: userCredentialsStorage,
      errorController: BehaviorSubject<EmailLinkError>(),
    );
    // Check dynamic link once on app startup. This is required to process any dynamic links that may have opened
    // the app when it was closed.
    FirebaseDynamicLinks.instance.getInitialLink().then((link) => linkHandler._processDynamicLink(link?.link));
    // Listen to subsequent links
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: linkHandler.handleLink,
      onError: linkHandler.handleLinkError,
    );
    return linkHandler;
  }

  /// last link data received from FirebaseDynamicLinks
  Uri _lastUnprocessedLink;

  /// last link error received from FirebaseDynamicLinks
  OnLinkErrorException _lastUnprocessedLinkError;

  /// Clients can listen to this stream and show error alerts when dynamic link processing fails
  Observable<EmailLinkError> get errorStream => errorController.stream;

  Future<dynamic> handleLink(PendingDynamicLinkData linkData) {
    _lastUnprocessedLink = linkData?.link;
    _lastUnprocessedLinkError = null;
    return Future<dynamic>.value();
  }

  Future<dynamic> handleLinkError(OnLinkErrorException error) {
    _lastUnprocessedLink = null;
    _lastUnprocessedLinkError = error;
    return Future<dynamic>.value();
  }

  void dispose() {
    errorController.close();
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
      _processDynamicLink(_lastUnprocessedLink);
      _lastUnprocessedLink = null;
    }
    if (_lastUnprocessedLinkError != null) {
      errorController.add(EmailLinkError(
        error: EmailLinkErrorType.linkError,
        description: _lastUnprocessedLinkError.message,
      ));
      _lastUnprocessedLinkError = null;
    }
  }

  Future<void> _processDynamicLink(Uri deepLink) async {
    if (deepLink != null) {
      await _signInWithEmail(deepLink.toString());
    } else {
      print('No deep links found');
    }
  }

  Future<void> _signInWithEmail(String link) async {
    print('Received link: $link');
    final User user = await auth.currentUser();
    if (user != null) {
      errorController.add(EmailLinkError(
        error: EmailLinkErrorType.userAlreadySignedIn,
      ));
      return;
    }
    final email = await emailStore.getEmail();
    if (email == null) {
      errorController.add(EmailLinkError(
        error: EmailLinkErrorType.emailNotSet,
      ));
      return;
    }

    if (await auth.isSignInWithEmailLink(link)) {
      try {
        final user = await auth.signInWithEmailAndLink(email: email, link: link);
        print('email: ${user.email}, uid: ${user.uid}');
      } catch (e) {
        print(e);
        errorController.add(EmailLinkError(
          error: EmailLinkErrorType.signInFailed,
          description: e.toString(),
        ));
      }
    } else {
      errorController.add(EmailLinkError(
        error: EmailLinkErrorType.isNotSignInWithEmailLink,
      ));
    }
  }
}
