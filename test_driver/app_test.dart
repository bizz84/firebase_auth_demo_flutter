// Imports the Flutter Driver API.
//import 'dart:io';

// https://stackoverflow.com/questions/52462646/how-to-solve-not-found-dartui-error-while-running-integration-tests-on-flutt
// http://cogitas.net/write-integration-test-flutter/
// https://medium.com/flutter-community/testing-flutter-ui-with-flutter-driver-c1583681e337

/*
 Rules:
 - Not importing flutter code
 - Not importing flutter_tet code
*/

import 'package:firebase_auth_demo_flutter/constants/keys.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
//import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:flutter_driver/flutter_driver.dart';
//import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';

void main() {
  group('Auth Demo', () {
    FlutterDriver driver;
    Future<void> delay([int milliseconds = 250]) async {
      await Future<void>.delayed(Duration(milliseconds: milliseconds));
    }

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      //await Directory('screenshots').create();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    // Future<void> takeScreenshot(String path) async {
    //   final List<int> pixels = await driver.screenshot();
    //   final file = File(path);
    //   await file.writeAsBytes(pixels);
    //   print('Written: $path');
    // }

    test('check flutter driver health', () async {
      final health = await driver.checkHealth();
      expect(health.status, HealthStatus.ok);
    });

    // test('open drawer', () async {
    //   // https://stackoverflow.com/questions/56634946/flutter-how-test-drawer-in-widgets-test
    //   final drawer = find.byValueKey(Keys.drawer);
    //   //expect(drawer, findsWidgets);
    //   //expect(drawer, prefix0.findsOneWidget);
    //   await driver.tap(drawer);

    //   //await driver.waitFor(find.text(Strings.developerMenu));
    //   //await takeScreenshot('drawer-menu.png');
    //   await delay(1000);
    // });

    test('sign in anonymously, sign out', () async {
      // https://stackoverflow.com/questions/56634946/flutter-how-test-drawer-in-widgets-test
      final anonymousSignInButton = find.byValueKey(Keys.anonymous);
      //expect(drawer, findsWidgets);
      //expect(drawer, prefix0.findsOneWidget);
      await driver.tap(anonymousSignInButton);

      await driver.waitFor(find.text(Strings.logout));
      //await takeScreenshot('drawer-menu.png');
      await delay(3000);
    });
  });
}
