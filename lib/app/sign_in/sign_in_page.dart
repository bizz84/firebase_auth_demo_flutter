import 'package:firebase_auth_demo_flutter/app/developer_menu.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_manager.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/social_sign_in_button.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/platform_exception_alert_dialog.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage._({Key key, this.manager, this.title}) : super(key: key);
  final SignInManager manager;
  final String title;

  static Widget create(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    return Provider<SignInManager>(
      builder: (BuildContext context) => SignInManager(auth: auth),
      child: Consumer<SignInManager>(
        builder: (BuildContext context, SignInManager manager, _) => SignInPage._(
              manager: manager,
              title: 'Firebase Auth Demo',
            ),
      ),
    );
  }

  Future<void> _showSignInError(BuildContext context, PlatformException exception) async {
    await PlatformExceptionAlertDialog(
      title: Strings.signInFailed,
      exception: exception,
    ).show(context);
  }

  Future<void> _signInAnonymously(BuildContext context, SignInModel model) async {
    try {
      await manager.signInAnonymously(model);
    } on PlatformException catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context, SignInModel model) async {
    try {
      await manager.signInWithGoogle(model);
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e);
      }
    }
  }

  Future<void> _signInWithFacebook(BuildContext context, SignInModel model) async {
    try {
      await manager.signInWithFacebook(model);
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e);
      }
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
    return ChangeNotifierProvider<SignInModel>(
      builder: (BuildContext context) => SignInModel(),
      child: Consumer<SignInModel>(builder: (BuildContext context, SignInModel model, _) {
        return Scaffold(
          appBar: AppBar(
            elevation: 2.0,
            title: Text(title),
          ),
          // Hide developer menu while loading in progress.
          // This is so that it's not possible to switch auth service while a request is in progress
          drawer: model.loading ? null : DeveloperMenu(),
          backgroundColor: Colors.grey[200],
          body: _buildSignIn(context, model),
        );
      }),
    );
  }

  Widget _buildHeader(SignInModel model) {
    if (model.loading) {
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

  Widget _buildSignIn(BuildContext context, SignInModel model) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: _buildHeader(model),
          ),
          SizedBox(height: 48.0),
          SocialSignInButton(
            assetName: 'assets/go-logo.png',
            text: Strings.signInWithGoogle,
            onPressed: model.loading ? null : () => _signInWithGoogle(context, model),
            color: Colors.white,
          ),
          SizedBox(height: 8),
          SocialSignInButton(
            assetName: 'assets/fb-logo.png',
            text: Strings.signInWithFacebook,
            textColor: Colors.white,
            onPressed: model.loading ? null : () => _signInWithFacebook(context, model),
            color: Color(0xFF334D92),
          ),
          SizedBox(height: 8),
          SignInButton(
            text: Strings.signInWithEmail,
            onPressed: model.loading ? null : () => _signInWithEmail(context),
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
            onPressed: model.loading ? null : () => _signInAnonymously(context, model),
          ),
        ],
      ),
    );
  }
}
