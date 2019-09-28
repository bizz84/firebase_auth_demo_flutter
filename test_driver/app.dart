import 'package:firebase_auth_demo_flutter/main.dart' as app;
import 'package:flutter_driver/driver_extension.dart';

void main() {
  // This line enables the extension.
  enableFlutterDriverExtension();

  // Call the `main()` function of the app, or call `runApp` with
  // any widget you are interested in testing.
  //runApp(MyApp());
  app.main();
}
