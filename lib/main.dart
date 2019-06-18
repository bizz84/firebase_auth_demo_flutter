import 'package:firebase_auth_demo_flutter/app/landing_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service_adapter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      builder: (_) => AuthServiceAdapter(),
      dispose: (_, AuthService authService) => authService.dispose(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: LandingPage(),
      ),
    );
  }
}
