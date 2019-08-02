import 'dart:ui';

import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_email_link_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'mocks.dart';

class MockErrorController extends Mock implements BehaviorSubject<EmailLinkError> {}

void main() {
  group('tests', () {
    final mockAuth = MockAuthService();
    final mockWidgetsBinding = MockWidgetsBinding();
    final mockEmailSecureStore = MockEmailSecureStore();

    final sampleLink = Uri.https('', 'example.com');
    const sampleEmail = 'test@test.com';
    const sampleUser = User(uid: '123', email: sampleEmail);

    FirebaseEmailLinkHandler buildHandler() {
      return FirebaseEmailLinkHandler(
        auth: mockAuth,
        widgetsBinding: mockWidgetsBinding,
        emailStore: mockEmailSecureStore,
        //errorController: mockErrorController,
      );
    }

    /* Email sending tests */
    // test(
    //     'WHEN sendLinkToEmail called\n'
    //     'THEN setEmail called\n'
    //     'AND auth sendLinkToEmail called', () async {
    //   final handler = buildHandler();
    //   const url = 'example.com';
    //   const bundleID = 'demo.codingwithflutter.com';
    //   await handler.sendLinkToEmail(email: sampleEmail, url: url, iOSBundleID: bundleID, androidPackageName: bundleID);
    //   verify(mockEmailSecureStore.setEmail(sampleEmail)).called(1);
    //   verify(mockAuth.sendSignInWithEmailLink(
    //     email: sampleEmail,
    //     url: url,
    //     handleCodeInApp: true,
    //     iOSBundleID: bundleID,
    //     androidPackageName: bundleID,
    //     androidInstallIfNotAvailable: true,
    //     androidMinimumVersion: '21',
    //   )).called(1);
    // });

    void stubCurrentUser(User user) {
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(user));
    }

    void stubStoredEmail(String email) {
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(email));
    }

    /* Email processing tests */
    test(
        'WHEN create FirebaseEmailLinkHandler'
        'THEN registers widgets binding', () async {
      final handler = buildHandler();
      verify(mockWidgetsBinding.addObserver(handler)).called(1);
    });

    test(
        'WHEN didChangeAppLifecycleState called with `resumed` event'
        'AND currentUser is null'
        'AND stored email is null'
        'AND link received'
        'AND error NOT received'
        'THEN emits emailNotSet error'
        'AND sign in not called', () async {
      stubCurrentUser(null);
      stubStoredEmail(null);
      final handler = buildHandler();
      handler.handleLink(sampleLink);
      handler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      expect(handler.errorStream, emits(EmailLinkError(error: EmailLinkErrorType.emailNotSet)));
      verifyNever(mockAuth.isSignInWithEmailLink(any));
      handler.dispose();
    });
  });
}
