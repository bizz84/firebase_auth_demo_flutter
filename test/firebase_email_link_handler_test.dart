import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_email_link_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  group('tests', () {
    MockAuthService mockAuth;
    MockEmailSecureStore mockEmailSecureStore;
    MockFirebaseDynamicLinks mockFirebaseDynamicLinks;

    final sampleLink = Uri.https('', 'example.com');
    const sampleEmail = 'test@test.com';
    const sampleUser = User(uid: '123', email: sampleEmail);

    setUp(() {
      mockAuth = MockAuthService();
      mockEmailSecureStore = MockEmailSecureStore();
      mockFirebaseDynamicLinks = MockFirebaseDynamicLinks();
    });

    FirebaseEmailLinkHandler buildHandler() {
      return FirebaseEmailLinkHandler(
        auth: mockAuth,
        emailStore: mockEmailSecureStore,
        firebaseDynamicLinks: mockFirebaseDynamicLinks,
      );
    }

    void stubNullInitialLink() {
      when(mockFirebaseDynamicLinks.getInitialLink())
          .thenAnswer((_) => Future.value(null));
    }

    void stubValidInitialLink() {
      final linkData = MockPendingDynamicLinkData();
      when(linkData.link).thenReturn(sampleLink);
      when(mockFirebaseDynamicLinks.getInitialLink())
          .thenAnswer((_) => Future.value(linkData));
    }

    void stubGetInitialLinkThrows() {
      when(mockFirebaseDynamicLinks.getInitialLink())
          .thenThrow(PlatformException(
        code: 'ERROR',
        message: 'error',
      ));
    }

    void stubCurrentUser(User user) {
      when(mockAuth.currentUser()).thenAnswer((_) => Future.value(user));
    }

    void stubStoredEmail(String email) {
      when(mockEmailSecureStore.getEmail())
          .thenAnswer((_) => Future.value(email));
    }

    void stubIsSignInWithEmailLinkReturns(bool result) {
      when(mockAuth.isSignInWithEmailLink(any))
          .thenAnswer((_) => Future.value(result));
    }

    void stubSignInWithEmailLinkThrows(PlatformException exception) {
      when(mockAuth.signInWithEmailAndLink(
        email: anyNamed('email'),
        link: anyNamed('link'),
      )).thenThrow(exception);
    }

    /* Email processing tests */

    test(
        'WHEN currentUser is null'
        'AND stored email is null'
        'AND link NOT received'
        'AND error NOT received'
        'THEN never emits emailNotSet error'
        'AND isSignInWithEmailLink not called', () async {
      stubCurrentUser(null);
      stubStoredEmail(null);
      final handler = buildHandler();
      expect(handler.errorStream,
          neverEmits(EmailLinkError(error: EmailLinkErrorType.emailNotSet)));
      stubNullInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verifyNever(mockAuth.isSignInWithEmailLink(any));
      handler.dispose();
    });

    test(
        'WHEN currentUser is null'
        'AND stored email is null'
        'AND link received'
        'AND error NOT received'
        'THEN emits emailNotSet error'
        'AND isSignInWithEmailLink not called', () async {
      stubCurrentUser(null);
      stubStoredEmail(null);
      final handler = buildHandler();
      expect(handler.errorStream,
          emits(EmailLinkError(error: EmailLinkErrorType.emailNotSet)));
      stubValidInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verifyNever(mockAuth.isSignInWithEmailLink(any));
      handler.dispose();
    });

    test(
        'WHEN currentUser is null'
        'AND stored email is null'
        'AND link NOT received'
        'AND error received'
        'THEN emits linkError error'
        'AND isSignInWithEmailLink not called', () async {
      stubCurrentUser(null);
      stubStoredEmail(null);
      final handler = buildHandler();
      expect(
          handler.errorStream,
          emits(EmailLinkError(
            error: EmailLinkErrorType.linkError,
            description: 'error',
          )));
      stubGetInitialLinkThrows();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verifyNever(mockAuth.isSignInWithEmailLink(any));
      handler.dispose();
    });

    test(
        'WHEN currentUser is NOT null'
        'AND stored email is null'
        'AND link received'
        'THEN emits userAlreadySignedIn error'
        'AND isSignInWithEmailLink not called', () async {
      stubCurrentUser(sampleUser);
      stubStoredEmail(null);
      final handler = buildHandler();
      expect(handler.errorStream,
          emits(EmailLinkError(error: EmailLinkErrorType.userAlreadySignedIn)));
      stubValidInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verifyNever(mockAuth.isSignInWithEmailLink(any));
      handler.dispose();
    });

    test(
        'WHEN currentUser is NOT null'
        'AND stored email is NOT null'
        'AND link received'
        'THEN emits userAlreadySignedIn error'
        'AND isSignInWithEmailLink not called', () async {
      stubCurrentUser(sampleUser);
      stubStoredEmail(sampleEmail);
      final handler = buildHandler();
      expect(handler.errorStream,
          emits(EmailLinkError(error: EmailLinkErrorType.userAlreadySignedIn)));
      stubValidInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verifyNever(mockAuth.isSignInWithEmailLink(any));
      handler.dispose();
    });
    test(
        'WHEN currentUser is null'
        'AND stored email is NOT null'
        'AND is NOT sign in link'
        'AND link received'
        'THEN isSignInWithEmailLink called', () async {
      stubCurrentUser(null);
      stubStoredEmail(sampleEmail);
      stubIsSignInWithEmailLinkReturns(false);
      final handler = buildHandler();
      expect(
          handler.errorStream,
          emits(EmailLinkError(
              error: EmailLinkErrorType.isNotSignInWithEmailLink)));
      stubValidInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verify(mockAuth.isSignInWithEmailLink(any)).called(1);
      handler.dispose();
    });
    test(
        'WHEN currentUser is null'
        'AND stored email is NOT null'
        'AND is sign in link'
        'AND link received'
        'THEN isSignInWithEmailLink called'
        'AND signInWithEmailAndLink called', () async {
      stubCurrentUser(null);
      stubStoredEmail(sampleEmail);
      stubIsSignInWithEmailLinkReturns(true);
      final handler = buildHandler();
      expect(
          handler.errorStream,
          neverEmits(EmailLinkError(
              error: EmailLinkErrorType.isNotSignInWithEmailLink)));
      stubValidInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verify(mockAuth.isSignInWithEmailLink(any)).called(1);
      verify(mockAuth.signInWithEmailAndLink(
          email: sampleEmail, link: anyNamed('link')));
      handler.dispose();
    });

    test(
        'WHEN currentUser is null'
        'AND stored email is NOT null'
        'AND is sign in link'
        'AND sign in throws exception'
        'AND link received'
        'THEN isSignInWithEmailLink called'
        'AND signInWithEmailAndLink called', () async {
      stubCurrentUser(null);
      stubStoredEmail(sampleEmail);
      stubIsSignInWithEmailLinkReturns(true);
      stubSignInWithEmailLinkThrows(
          PlatformException(code: 'ERROR_SIGN_IN_FAILED', message: 'fail'));
      final handler = buildHandler();
      expect(
          handler.errorStream,
          emits(EmailLinkError(
              error: EmailLinkErrorType.signInFailed, description: 'fail')));
      stubValidInitialLink();
      await handler.init();
      // artificial delay so that valeus are added to stream
      await Future<void>.delayed(Duration());
      verify(mockAuth.isSignInWithEmailLink(any)).called(1);
      verify(mockAuth.signInWithEmailAndLink(
          email: sampleEmail, link: anyNamed('link')));
      handler.dispose();
    });
  });

  // TODO: sendSignInWithEmailLink tests
  // TODO: ValueNotifier loading tests
}
