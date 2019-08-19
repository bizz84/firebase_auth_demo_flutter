import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_email_link_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'mocks.dart';

void main() {
  MockAuthService mockAuthService;
  MockFirebaseEmailLinkHandler mockFirebaseEmailLinkHandler;
  MockNavigatorObserver mockNavigatorObserver;
  StreamController<User> onAuthStateChangedController;

  setUp(() {
    mockAuthService = MockAuthService();
    mockFirebaseEmailLinkHandler = MockFirebaseEmailLinkHandler();
    mockNavigatorObserver = MockNavigatorObserver();
    onAuthStateChangedController = StreamController<User>();
  });

  tearDown(() {
    onAuthStateChangedController.close();
  });

  void stubMockFirebaseEmailLinkHandlerGetEmailReturns(String email) {
    when(mockFirebaseEmailLinkHandler.getEmail())
        .thenAnswer((_) => Future<String>.value(email));
  }

  void stubMockFirebaseEmailLinkHandlerIsLoadingReturns(bool loading) {
    when(mockFirebaseEmailLinkHandler.isLoading)
        .thenReturn(ValueNotifier<bool>(loading));
  }

  void stubOnAuthStateChangedYields(Iterable<User> onAuthStateChanged) {
    onAuthStateChangedController
        .addStream(Stream<User>.fromIterable(onAuthStateChanged));
    when(mockAuthService.onAuthStateChanged).thenAnswer((_) {
      return onAuthStateChangedController.stream;
    });
  }

  Future<void> pumpSignInPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>(
            builder: (_) => mockAuthService,
          ),
          Provider<FirebaseEmailLinkHandler>(
            builder: (_) => mockFirebaseEmailLinkHandler,
          ),
        ],
        child: MaterialApp(
          home: SignInPageBuilder(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      ),
    );
    // didPush is called once when the widget is first built
    verify(mockNavigatorObserver.didPush(any, any)).called(1);
  }

  testWidgets('email & password navigation', (WidgetTester tester) async {
    await pumpSignInPage(tester);

    final emailPasswordButton = find.byKey(SignInPage.emailPasswordButtonKey);
    expect(emailPasswordButton, findsOneWidget);

    await tester.tap(emailPasswordButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any)).called(1);
  });

  testWidgets('email link navigation', (WidgetTester tester) async {
    await pumpSignInPage(tester);

    stubMockFirebaseEmailLinkHandlerGetEmailReturns(null);
    stubMockFirebaseEmailLinkHandlerIsLoadingReturns(false);
    stubOnAuthStateChangedYields([]);

    final emailLinkButton = find.byKey(SignInPage.emailLinkButtonKey);
    expect(emailLinkButton, findsOneWidget);

    await tester.tap(emailLinkButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any)).called(1);
  });
}
