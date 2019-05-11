import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_manager.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  MockAuthService mockAuthService;
  SignInManager bloc;

  setUp(() {
    mockAuthService = MockAuthService();
    bloc = SignInManager(auth: mockAuthService);
  });

  tearDown(() {
    mockAuthService = null;
    bloc = null;
  });

  void stubSignInAnonymouslyReturnsUser() {
    when(mockAuthService.signInAnonymously()).thenAnswer((_) => Future<User>.value(User(uid: '123')));
  }

  void stubSignInAnonymouslyThrows(Exception exception) {
    when(mockAuthService.signInAnonymously()).thenThrow(exception);
  }

  test(
      'WHEN bloc signs in anonymously'
      'AND auth returns valid user'
      'THEN loading stream emits true, false', () async {
    stubSignInAnonymouslyReturnsUser();

    await bloc.signInAnonymously();

    expect(
      bloc.isLoadingStream,
      emitsInOrder(
        <bool>[
          true,
          false,
        ],
      ),
    );
  });

  test(
      'WHEN bloc signs in anonymously'
      'AND auth throws an exception'
      'THEN bloc throws an exception'
      'AND loading stream emits true, false', () async {
    final exception = PlatformException(code: 'ERROR_MISSING_PERMISSIONS');
    stubSignInAnonymouslyThrows(exception);

    expect(() async => await bloc.signInAnonymously(), throwsA(exception));

    expect(
      bloc.isLoadingStream,
      emitsInOrder(
        <bool>[
          true,
          false,
        ],
      ),
    );
  });
}
