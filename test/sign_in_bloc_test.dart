import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_bloc.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

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

  void stubSignInAnonymouslyReturnsUser() {
    when(mockAuthService.signInAnonymously()).thenAnswer((invocation) => Future<User>.value(User(uid: '123')));
  }

  void stubSignInAnonymouslyThrows(Exception exception) {
    when(mockAuthService.signInAnonymously()).thenThrow(exception);
  }

  test(
      'WHEN bloc signs in anonymously'
      'AND auth returns valid user'
      'THEN loading stream emits true, false', () async {
    stubSignInAnonymouslyReturnsUser();

    final SignInBloc bloc = SignInBloc(auth: mockAuthService);
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

    final SignInBloc bloc = SignInBloc(auth: mockAuthService);
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
