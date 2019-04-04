import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/social_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, this.bloc, this.title}) : super(key: key);
  final SignInBloc bloc;
  final String title;

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await bloc.signInAnonymously();
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _signInWithEmail(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => EmailPasswordSignInPage.create(context),
      ),
    );
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await bloc.signInWithFacebook();
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(title),
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<bool>(
        stream: bloc.isLoadingStream,
        initialData: false,
        builder: (context, snapshot) {
          return _buildSignIn(context, snapshot.data);
        },
      ),
    );
  }

  Widget _buildSignIn(BuildContext context, bool isLoading) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: _buildHeader(isLoading),
          ),
          SizedBox(height: 48.0),
          SocialSignInButton(
            key: Key('googleSignIn'),
            assetName: 'assets/go-logo.png',
            text: 'Sign in with Google',
            onPressed: isLoading ? null : () => _signInWithGoogle(context),
            color: Colors.white,
          ),
          SizedBox(height: 8),
          SocialSignInButton(
            key: Key('facebookSignIn'),
            assetName: 'assets/fb-logo.png',
            text: 'Sign in with Facebook',
            textColor: Colors.white,
            onPressed: isLoading ? null : () => _signInWithFacebook(context),
            color: Color(0xFF334D92),
          ),
          SizedBox(height: 8),
          SignInButton(
            key: Key('emailSignIn'),
            text: 'Sign in with email',
            onPressed: isLoading ? null : () => _signInWithEmail(context),
            textColor: Colors.white,
            color: Colors.teal[700],
          ),
          SizedBox(height: 8),
          Text(
            'or',
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          SignInButton(
            key: Key('anonymousSignIn'),
            text: 'Go anonymous',
            color: Colors.lime[300],
            textColor: Colors.black,
            onPressed: isLoading ? null : () => _signInAnonymously(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign In',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }
}
