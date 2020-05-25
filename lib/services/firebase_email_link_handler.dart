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
class FirebaseEmailLinkHandler {
  FirebaseEmailLinkHandler({
    @required this.auth,
    @required this.emailStore,
    @required this.firebaseDynamicLinks,
  });
  final AuthService auth;
  final EmailSecureStore emailStore;
  final FirebaseDynamicLinks firebaseDynamicLinks;

  /// Sets up listeners to process all links from [FirebaseDynamicLinks.instance.getInitialLink()] and [FirebaseDynamicLinks.instance.onLink]
  Future<void> init() async {
    try {
      // Listen to incoming links when the app is open
      firebaseDynamicLinks.onLink(
        onSuccess: (linkData) => _processDynamicLink(linkData?.link),
        onError: (error) => _handleLinkError(PlatformException(
          code: error.code,
          message: error.message,
          details: error.details,
        )),
      );

      // Check dynamic link once on app startup.
      // This is required to process any dynamic links that are opened when the app was closed
      final linkData = await firebaseDynamicLinks.getInitialLink();
      final link = linkData?.link?.toString();
      if (link != null) {
        await _processDynamicLink(linkData?.link);
      }
    } on PlatformException catch (e) {
      _handleLinkError(e);
    }
  }

  /// Clients can listen to this stream and show error alerts when dynamic link processing fails
  final PublishSubject<EmailLinkError> _errorController =
      PublishSubject<EmailLinkError>();
  Stream<EmailLinkError> get errorStream => _errorController.stream;

  /// Clients can listen to this stream and show a loading indicator while sign in is in progress
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<String> getEmail() => emailStore.getEmail();

  Future<dynamic> _handleLinkError(PlatformException error) {
    _errorController.add(EmailLinkError(
      error: EmailLinkErrorType.linkError,
      description: error.message,
    ));

    return Future<dynamic>.value();
  }

  void dispose() {
    _errorController.close();
    isLoading.dispose();
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
    } on PlatformException catch (_) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
