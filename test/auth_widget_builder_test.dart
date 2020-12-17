import 'dart:async';

import 'package:firebase_auth_demo_flutter/app/auth_widget_builder.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'mocks.dart';

void main() {
  MockAuthService mockAuthService;
  StreamController<MyAppUser> onAuthStateChangedController;

  setUp(() {
    mockAuthService = MockAuthService();
    onAuthStateChangedController = StreamController<MyAppUser>();
  });

  tearDown(() {
    mockAuthService = null;
    onAuthStateChangedController.close();
  });

  void stubOnAuthStateChangedYields(Iterable<MyAppUser> onAuthStateChanged) {
    onAuthStateChangedController
        .addStream(Stream<MyAppUser>.fromIterable(onAuthStateChanged));
    when(mockAuthService.onAuthStateChanged).thenAnswer((_) {
      return onAuthStateChangedController.stream;
    });
  }

  Future<void> pumpAuthWidget(
      WidgetTester tester,
      {@required
          Widget Function(BuildContext, AsyncSnapshot<MyAppUser>)
              builder}) async {
    await tester.pumpWidget(
      Provider<AuthService>(
        create: (_) => mockAuthService,
        child: AuthWidgetBuilder(builder: builder),
      ),
    );
    await tester.pump(Duration.zero);
  }

  testWidgets(
      'WHEN onAuthStateChanged in waiting state'
      'THEN calls builder with snapshot in waiting state'
      'AND doesn\'t find MultiProvider', (WidgetTester tester) async {
    stubOnAuthStateChangedYields(<MyAppUser>[]);

    final snapshots = <AsyncSnapshot<MyAppUser>>[];
    await pumpAuthWidget(tester, builder: (context, userSnapshot) {
      snapshots.add(userSnapshot);
      return Container();
    });
    expect(snapshots, [
      AsyncSnapshot<MyAppUser>.withData(ConnectionState.waiting, null),
    ]);
    expect(find.byType(MultiProvider), findsNothing);
  });

  testWidgets(
      'WHEN onAuthStateChanged returns null user'
      'THEN calls builder with null user and active state'
      'AND doesn\'t find MultiProvider', (WidgetTester tester) async {
    stubOnAuthStateChangedYields(<MyAppUser>[null]);

    final snapshots = <AsyncSnapshot<MyAppUser>>[];
    await pumpAuthWidget(tester, builder: (context, userSnapshot) {
      snapshots.add(userSnapshot);
      return Container();
    });
    expect(snapshots, [
      AsyncSnapshot<MyAppUser>.withData(ConnectionState.waiting, null),
      AsyncSnapshot<MyAppUser>.withData(ConnectionState.active, null),
    ]);
    expect(find.byType(MultiProvider), findsNothing);
  });

  testWidgets(
      'WHEN onAuthStateChanged returns valid user'
      'THEN calls builder with same user and active state'
      'AND finds MultiProvider', (WidgetTester tester) async {
    final user = MyAppUser(uid: '123');
    stubOnAuthStateChangedYields(<MyAppUser>[user]);

    final snapshots = <AsyncSnapshot<MyAppUser>>[];
    await pumpAuthWidget(tester, builder: (context, userSnapshot) {
      snapshots.add(userSnapshot);
      return Container();
    });
    expect(snapshots, [
      AsyncSnapshot<MyAppUser>.withData(ConnectionState.waiting, null),
      AsyncSnapshot<MyAppUser>.withData(ConnectionState.active, user),
    ]);
    expect(find.byType(MultiProvider), findsOneWidget);
  });
}
