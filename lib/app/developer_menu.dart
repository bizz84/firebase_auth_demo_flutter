import 'package:firebase_auth_demo_flutter/app/auth_service_type_bloc.dart';
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
                  'Developer menu',
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
      builder: (BuildContext context, AsyncSnapshot<AuthServiceType> snapshot) {
        final AuthServiceType type = snapshot.data;
        return Expanded(
          child: ListView(
            children: <Widget>[
              SegmentedControl<AuthServiceType>(
                header: Text(
                  'Authentication type',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                value: type,
                onValueChanged: (AuthServiceType type) => authServiceTypeBloc.setAuthServiceType(type),
                children: const <AuthServiceType, Widget>{
                  AuthServiceType.firebase: Text('Firebase'),
                  AuthServiceType.mock: Text('Mock'),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({this.header, this.value, this.children, this.onValueChanged});
  final Widget header;
  final T value;
  final Map<T, Widget> children;
  final ValueChanged<T> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: header,
        ),
        SizedBox(
          width: double.infinity,
          child: CupertinoSegmentedControl<T>(
            children: children,
            groupValue: value,
            onValueChanged: onValueChanged,
          ),
        ),
      ],
    );
  }
}
