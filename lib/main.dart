import 'package:email_password_auth_flutter/app/landing_page.dart';
import 'package:email_password_auth_flutter/services/auth_service.dart';
import 'package:email_password_auth_flutter/services/firebase_auth_service.dart';
import 'package:email_password_auth_flutter/services/mock_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      value: MockAuthService(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: LandingPage(),
      ),
    );
  }
}
