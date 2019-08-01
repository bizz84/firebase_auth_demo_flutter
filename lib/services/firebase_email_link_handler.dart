import 'dart:async';

import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/email_secure_store.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// Needed for testing because the constructor of PendingDynamicLinkData is private :/
class FirebaseDynamicLinksListener {
  FirebaseDynamicLinksListener() {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData linkData) {
        _linkController.add(linkData?.link);
        return;
      },
      onError: (OnLinkErrorException error) {
        _linkController.addError(error);
        return;
      },
    );
  }
  final StreamController<Uri> _linkController = StreamController<Uri>();
  Stream<Uri> get linkStream => _linkController.stream;

  void dispose() {
    _linkController?.close();
  }

  Future<Uri> getInitialLink() async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    return data?.link;
  }
}

enum EmailLinkErrorType {
  emailNotSet,
  signInFailed,
}

class EmailLinkError {
  EmailLinkError({@required this.error, this.description});
  final EmailLinkErrorType error;
  final String description;

  String get errorMessage {
    switch (error) {
      case EmailLinkErrorType.emailNotSet:
        return Strings.submitEmailAgain;
      case EmailLinkErrorType.signInFailed:
        return description;
    }
    return description;
  }

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
    @required this.firebaseDynamicLinksListener,
    @required this.errorController,
  }) {
    // Register WidgetsBinding observer so that we can detect when the app is resumed.
    // See [didChangeAppLifecycleState].
    widgetsBinding.addObserver(this);
    // Check dynamic link once on app startup. This is required to process any dynamic links that may have opened
    // the app when it was closed.
    firebaseDynamicLinksListener.getInitialLink().then((link) => processDynamicLink(link));
    // Listen to subsequent links
    _linkSubscription = firebaseDynamicLinksListener.linkStream.listen((link) => _lastUnprocessedLink = link);
  }
  final AuthService auth;
  final WidgetsBinding widgetsBinding;
  final EmailSecureStore emailStore;
  final FirebaseDynamicLinksListener firebaseDynamicLinksListener;
  // Injecting this as couldn't find a way to test if values/errors are NOT added to the stream
  final BehaviorSubject<EmailLinkError> errorController;

  static FirebaseEmailLinkHandler createAndConfigure({
    @required AuthService auth,
    @required EmailSecureStore userCredentialsStorage,
  }) {
    return FirebaseEmailLinkHandler(
      auth: auth,
      widgetsBinding: WidgetsBinding.instance,
      emailStore: userCredentialsStorage,
      firebaseDynamicLinksListener: FirebaseDynamicLinksListener(),
      errorController: BehaviorSubject<EmailLinkError>(),
    );
  }

  StreamSubscription<Uri> _linkSubscription;
  Uri _lastUnprocessedLink;

  /// Clients can listen to this stream and show error alerts when dynamic link processing fails
  Observable<EmailLinkError> get errorStream => errorController.stream;

  Future<String> get email async => await emailStore.getEmail();

  void dispose() {
    _linkSubscription?.cancel();
    errorController.close();
    widgetsBinding.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the application comes into focus
    if (state == AppLifecycleState.resumed) {
      checkUnprocessedLink();
    }
  }

  /// Checks for a dynamic link, and tries to use it to sign in with email (passwordless)
  Future<void> checkUnprocessedLink() async {
    if (_lastUnprocessedLink != null) {
      processDynamicLink(_lastUnprocessedLink);
      _lastUnprocessedLink = null;
    }
  }

  Future<void> processDynamicLink(Uri deepLink) async {
    if (deepLink != null) {
      await _signInWithEmail(deepLink.toString());
    } else {
      print('No deep links found');
    }
  }

  Future<void> _signInWithEmail(String link) async {
    final User user = await auth.currentUser();
    if (user != null) {
      // TODO: We should record a log with analytics if this happens
      print('User is already signed in');
      return;
    }
    final email = await emailStore.getEmail();
    if (email == null) {
      // TODO: We should record an error with analytics if this happens
      errorController.add(EmailLinkError(error: EmailLinkErrorType.emailNotSet));
      return;
    }

    print('Received link: $link');
    if (await auth.isSignInWithEmailLink(link)) {
      try {
        final user = await auth.signInWithEmailAndLink(email: email, link: link);
        print('email: ${user.email}, uid: ${user.uid}');
      } catch (e) {
        print(e);
        errorController.add(EmailLinkError(error: EmailLinkErrorType.signInFailed, description: e.toString()));
      }
    } else {
      print('Invalid link: $link');
    }
  }

  /// Sends an activation link to the email provided
  Future<void> sendLinkToEmail({String email, String url, String iOSBundleID, String androidPackageName}) async {
    await emailStore.setEmail(email);

    // Send link
    await auth.sendSignInWithEmailLink(
      email: email,
      url: url,
      handleCodeInApp: true,
      iOSBundleID: iOSBundleID,
      androidPackageName: androidPackageName,
      androidInstallIfNotAvailable: true,
      androidMinimumVersion: '21',
    );
    print('Sent email link to $email, url: $url');
  }
}
