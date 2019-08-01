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
    final mockFirebaseDynamicLinksURIResolver = MockFirebaseDynamicLinksListener();
    final mockErrorController = MockErrorController();

    const sampleEmail = 'test@test.com';
    const sampleUser = User(uid: '123', email: sampleEmail);

    FirebaseEmailLinkHandler buildHandler() {
      return FirebaseEmailLinkHandler(
        auth: mockAuth,
        widgetsBinding: mockWidgetsBinding,
        emailStore: mockEmailSecureStore,
        firebaseDynamicLinksListener: mockFirebaseDynamicLinksURIResolver,
        errorController: mockErrorController,
      );
    }

    /* Email sending tests */
    test(
        'WHEN sendLinkToEmail called\n'
        'THEN setEmail called\n'
        'AND auth sendLinkToEmail called', () async {
      final handler = buildHandler();
      const url = 'example.com';
      const bundleID = 'demo.codingwithflutter.com';
      await handler.sendLinkToEmail(email: sampleEmail, url: url, iOSBundleID: bundleID, androidPackageName: bundleID);
      verify(mockEmailSecureStore.setEmail(sampleEmail)).called(1);
      verify(mockAuth.sendSignInWithEmailLink(
        email: sampleEmail,
        url: url,
        handleCodeInApp: true,
        iOSBundleID: bundleID,
        androidPackageName: bundleID,
        androidInstallIfNotAvailable: true,
        androidMinimumVersion: '21',
      )).called(1);
    });

    /* Email processing tests */
    test(
        'WHEN create FirebaseEmailLinkHandler'
        'THEN registers widgets binding', () async {
      final handler = buildHandler();
      verify(mockWidgetsBinding.addObserver(handler)).called(1);
    });

    test(
        'WHEN didChangeAppLifecycleState called'
        'AND event is `resumed`'
        'THEN retrieves dynamic link', () async {
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => null);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      final handler = buildHandler();
      handler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      // small delay because didChangeAppLifecycleState is synchronous
      await Future<void>.delayed(Duration(milliseconds: 200));
      verify(mockFirebaseDynamicLinksURIResolver.getInitialLink()).called(1);
    });

    test(
        'WHEN checkUnprocessedLink called'
        'THEN retrieves dynamic link', () async {
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => null);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verify(mockFirebaseDynamicLinksURIResolver.getInitialLink()).called(1);
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is NOT null'
        'THEN email is not checked', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(sampleUser));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verifyNever(mockEmailSecureStore.getEmail());
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is null'
        'AND email is null'
        'THEN an error is emitted', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(null));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verify(mockErrorController.add(EmailLinkError(error: EmailLinkErrorType.emailNotSet))).called(1);
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is null'
        'AND email is not null'
        'THEN link is checked as an email activation link', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(sampleEmail));
      when(mockAuth.isSignInWithEmailLink(uri.toString())).thenAnswer((invocation) => Future.value(false));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verify(mockAuth.isSignInWithEmailLink(uri.toString())).called(1);
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is null'
        'AND email is not null'
        'AND link is checked as an email activation link'
        'AND link is valid'
        'THEN sign in with email is attempted', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(sampleEmail));
      when(mockAuth.isSignInWithEmailLink(uri.toString())).thenAnswer((invocation) => Future.value(true));
      when(mockAuth.signInWithEmailAndLink(email: sampleEmail, link: uri.toString()))
          .thenAnswer((invocation) => Future.value(sampleUser));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verify(mockAuth.signInWithEmailAndLink(email: sampleEmail, link: uri.toString())).called(1);
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is null'
        'AND email is not null'
        'AND link is checked as an email activation link'
        'AND link is NOT valid'
        'THEN sign in with email is NOT attempted', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(sampleEmail));
      when(mockAuth.isSignInWithEmailLink(uri.toString())).thenAnswer((invocation) => Future.value(false));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verifyNever(mockAuth.signInWithEmailAndLink(email: sampleEmail, link: uri.toString()));
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is null'
        'AND email is not null'
        'AND link is checked as an email activation link'
        'AND link is valid'
        'AND sign in with email succeeds'
        'THEN no error is emitted', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(sampleEmail));
      when(mockAuth.isSignInWithEmailLink(uri.toString())).thenAnswer((invocation) => Future.value(true));
      when(mockAuth.signInWithEmailAndLink(email: sampleEmail, link: uri.toString()))
          .thenAnswer((invocation) => Future.value(sampleUser));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verifyNever(mockErrorController.addError(any));
    });

    test(
        'WHEN checkUnprocessedLink called'
        'AND getInitialLink returns link'
        'AND currentUser is null'
        'AND email is not null'
        'AND link is checked as an email activation link'
        'AND link is valid'
        'AND sign in with email fails'
        'THEN an error is emitted', () async {
      final uri = Uri.parse('example.com');
      final response = Future.value(uri);
      const error = 'Sign in failed';
      when(mockFirebaseDynamicLinksURIResolver.getInitialLink()).thenAnswer((invocation) => response);
      when(mockAuth.currentUser()).thenAnswer((invocation) => Future.value(null));
      when(mockEmailSecureStore.getEmail()).thenAnswer((invocation) => Future.value(sampleEmail));
      when(mockAuth.isSignInWithEmailLink(uri.toString())).thenAnswer((invocation) => Future.value(true));
      when(mockAuth.signInWithEmailAndLink(email: sampleEmail, link: uri.toString())).thenThrow(Exception(error));
      final handler = buildHandler();
      await handler.checkUnprocessedLink();
      verify(mockErrorController
              .add(EmailLinkError(error: EmailLinkErrorType.signInFailed, description: Exception(error).toString())))
          .called(1);
    });
  });
}
