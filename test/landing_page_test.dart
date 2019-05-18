import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/home_page.dart';
import 'package:firebase_auth_demo_flutter/app/landing_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'mocks.dart';

void main() {
  MockAuthService mockAuthService;
  StreamController<User> onAuthStateChangedController;

  setUp(() {
    mockAuthService = MockAuthService();
    onAuthStateChangedController = StreamController<User>();
  });

  tearDown(() {
    mockAuthService = null;
    onAuthStateChangedController.close();
  });

  void stubOnAuthStateChangedYields(Iterable<User> onAuthStateChanged) {
    onAuthStateChangedController.addStream(Stream<User>.fromIterable(onAuthStateChanged));
    when(mockAuthService.onAuthStateChanged).thenAnswer((_) {
      return onAuthStateChangedController.stream;
    });
  }

  Future<void> pumpLandingPage(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthService>(
        builder: (_) => mockAuthService,
        child: MaterialApp(home: LandingPage()),
      ),
    );
    await tester.pump(Duration.zero);
  }

  testWidgets(
      'WHEN onAuthStateChanged in waiting state'
      'THEN builds CircularProgressIndicator', (WidgetTester tester) async {
    stubOnAuthStateChangedYields(<User>[]);

    await pumpLandingPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'WHEN onAuthStateChanged returns null user'
      'THEN builds SignInPage', (WidgetTester tester) async {
    stubOnAuthStateChangedYields(<User>[null]);

    await pumpLandingPage(tester);

    expect(find.byType(SignInPage), findsOneWidget);
  });

  testWidgets(
      'WHEN onAuthStateChanged returns valid user'
      'THEN builds HomePage', (WidgetTester tester) async {
    stubOnAuthStateChangedYields(<User>[User(uid: '123')]);

    await pumpLandingPage(tester);

    expect(find.byType(HomePage), findsOneWidget);
  });
}
