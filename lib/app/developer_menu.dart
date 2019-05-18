import 'package:firebase_auth_demo_flutter/app/auth_service_type_bloc.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/segmented_control.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service_facade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeveloperMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Drawer(
        child: Column(children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const <Widget>[
                Text(
                  Strings.developerMenu,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
          ),
          _buildOptions(context),
        ]),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final AuthServiceTypeBloc authServiceTypeBloc = Provider.of<AuthServiceTypeBloc>(context);
    return StreamBuilder<AuthServiceType>(
      stream: authServiceTypeBloc.authServiceTypeStream,
      builder: (_, AsyncSnapshot<AuthServiceType> snapshot) {
        final AuthServiceType type = snapshot.data;
        return Expanded(
          child: ListView(
            children: <Widget>[
              SegmentedControl<AuthServiceType>(
                header: Text(
                  Strings.authenticationType,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                value: type,
                onValueChanged: (AuthServiceType type) => authServiceTypeBloc.setAuthServiceType(type),
                children: const <AuthServiceType, Widget>{
                  AuthServiceType.firebase: Text(Strings.firebase),
                  AuthServiceType.mock: Text(Strings.mock),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

