import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_model.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/form_submit_button.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/platform_alert_dialog.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/platform_exception_alert_dialog.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// This class relies on a EmailSignInBloc + StreamBuilder to manage its state.
/// However, it still needs to be a StatefulWidget due to an issue when
/// TextEditingController and StreamBuilder are used together.
class EmailPasswordSignInPage extends StatefulWidget {
  const EmailPasswordSignInPage._({Key key, this.bloc}) : super(key: key);
  final EmailPasswordSignInBloc bloc;

  /// Creates a Provider with a EmailSignInBloc and a EmailSignInPage
  static Widget create(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    return Provider<EmailPasswordSignInBloc>(
      builder: (BuildContext context) => EmailPasswordSignInBloc(auth: auth),
      dispose: (BuildContext context, EmailPasswordSignInBloc bloc) => bloc.dispose(),
      child: Consumer<EmailPasswordSignInBloc>(
        builder: (BuildContext context, EmailPasswordSignInBloc bloc, _) => EmailPasswordSignInPage._(bloc: bloc),
      ),
    );
  }

  @override
  _EmailPasswordSignInPageState createState() => _EmailPasswordSignInPageState();
}

class _EmailPasswordSignInPageState extends State<EmailPasswordSignInPage> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSignInError(EmailPasswordSignInModel model, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: model.errorAlertTitle,
      exception: exception,
    ).show(context);
  }

  void _unfocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  Future<void> _submit(EmailPasswordSignInModel model) async {
    _unfocus();
    try {
      final bool success = await widget.bloc.submit();
      if (success) {
        if (model.formType == EmailPasswordSignInFormType.forgotPassword) {
          PlatformAlertDialog(
            title: Strings.resetLinkSentTitle,
            content: Strings.resetLinkSentMessage,
            defaultActionText: Strings.ok,
          ).show(context);
        } else {
          Navigator.of(context).pop();
        }
      }
    } on PlatformException catch (e) {
      _showSignInError(model, e);
    }
  }

  void _emailEditingComplete(EmailPasswordSignInModel model) {
    final FocusNode newFocus = model.canSubmitEmail ? _passwordFocusNode : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _updateFormType(EmailPasswordSignInFormType formType) {
    widget.bloc.updateFormType(formType);
    _emailController.clear();
    _passwordController.clear();
  }

  Widget _buildEmailField(EmailPasswordSignInModel model) {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        labelText: Strings.emailLabel,
        hintText: Strings.emailHint,
        errorText: model.emailErrorText,
        enabled: !model.isLoading,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onChanged: widget.bloc.updateEmail,
      onEditingComplete: () => _emailEditingComplete(model),
      inputFormatters: <TextInputFormatter>[
        model.emailInputFormatter,
      ],
    );
  }

  Widget _buildPasswordField(EmailPasswordSignInModel model) {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: Strings.passwordLabel,
        errorText: model.passwordErrorText,
        enabled: !model.isLoading,
      ),
      obscureText: true,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      onChanged: widget.bloc.updatePassword,
      onEditingComplete: () => _submit(model),
    );
  }

  Widget _buildContent(EmailPasswordSignInModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 8.0),
        _buildEmailField(model),
        if (model.formType != EmailPasswordSignInFormType.forgotPassword) ...<Widget>[
          SizedBox(height: 8.0),
          _buildPasswordField(model),
        ],
        SizedBox(height: 8.0),
        FormSubmitButton(
          text: model.primaryButtonText,
          loading: model.isLoading,
          onPressed: () => _submit(model),
        ),
        SizedBox(height: 8.0),
        FlatButton(
          child: Text(model.secondaryButtonText),
          onPressed: model.isLoading ? null : () => _updateFormType(model.secondaryActionFormType),
        ),
        if (model.formType == EmailPasswordSignInFormType.signIn)
          FlatButton(
            child: Text(Strings.forgotPasswordQuestion),
            onPressed: model.isLoading ? null : () => _updateFormType(EmailPasswordSignInFormType.forgotPassword),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailPasswordSignInModel>(
      stream: widget.bloc.modelStream,
      initialData: EmailPasswordSignInModel(),
      builder: (BuildContext context, AsyncSnapshot<EmailPasswordSignInModel> snapshot) {
        final EmailPasswordSignInModel model = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            elevation: 2.0,
            title: Text(model.title),
          ),
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _buildContent(model),
                  //child: _buildEmailSignInForm(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
