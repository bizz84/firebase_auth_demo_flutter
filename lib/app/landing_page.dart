import 'package:firebase_auth_demo_flutter/app/home_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key, @required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<User> userSnapshot;

  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      return userSnapshot.hasData ? HomePage() : SignInPageBuilder();
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
