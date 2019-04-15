import 'package:firebase_auth_demo_flutter/app/home_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          return _buildContents(context, user);
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildContents(BuildContext context, User user) {
    if (user == null) {
      return _buildSignInPage(context);
    }
    return HomePage();
  }

  Widget _buildSignInPage(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    final SignInBloc signInBloc = SignInBloc(auth: auth);
    return StatefulProvider<SignInBloc>(
      valueBuilder: (BuildContext context) => signInBloc,
      onDispose: (BuildContext context, SignInBloc bloc) => bloc.dispose(),
      child: SignInPage(
        bloc: signInBloc,
        title: 'Time Tracker',
      ),
    );
  }
}
