import 'package:firebase_auth_demo_flutter/app/developer_menu.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/social_sign_in_button.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/platform_exception_alert_dialog.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, this.bloc, this.title}) : super(key: key);
  final SignInBloc bloc;
  final String title;

  void _showAlert(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: Strings.signInFailed,
      exception: exception,
    ).show(context);
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await bloc.signInAnonymously();
    } on PlatformException catch (e) {
      _showAlert(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on PlatformException catch (e) {
      _showAlert(context, e);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await bloc.signInWithFacebook();
    } on PlatformException catch (e) {
      _showAlert(context, e);
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(title),
      ),
      drawer: DeveloperMenu(),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<bool>(
        stream: bloc.isLoadingStream,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return _buildSignIn(context, snapshot.data);
        },
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
      Strings.signIn,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
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
            assetName: 'assets/go-logo.png',
            text: Strings.signInWithGoogle,
            onPressed: isLoading ? null : () => _signInWithGoogle(context),
            color: Colors.white,
          ),
          SizedBox(height: 8),
          SocialSignInButton(
            assetName: 'assets/fb-logo.png',
            text: Strings.signInWithFacebook,
            textColor: Colors.white,
            onPressed: isLoading ? null : () => _signInWithFacebook(context),
            color: Color(0xFF334D92),
          ),
          SizedBox(height: 8),
          SignInButton(
            text: Strings.signInWithEmail,
            onPressed: isLoading ? null : () => _signInWithEmail(context),
            textColor: Colors.white,
            color: Colors.teal[700],
          ),
          SizedBox(height: 8),
          Text(
            Strings.or,
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          SignInButton(
            text: Strings.goAnonymous,
            color: Colors.lime[300],
            textColor: Colors.black,
            onPressed: isLoading ? null : () => _signInAnonymously(context),
          ),
        ],
      ),
    );
  }
}
