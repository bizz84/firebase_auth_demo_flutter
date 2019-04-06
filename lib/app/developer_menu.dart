import 'package:firebase_auth_demo_flutter/app/developer_options_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeveloperMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const <Widget>[
              Text('Developer menu'),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.indigo,
          ),
        ),
        _buildOptions(context),
      ]),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final DeveloperOptionsBloc bloc = Provider.of<DeveloperOptionsBloc>(context);
    return Expanded(
      child: ListView(
        children: <Widget>[
          SegmentedControl<AuthServiceType>(
            header: Text('Authentication type'),
            // An ancestor StreamBuilder already rebuilds based on `bloc.authServiceStream`,
            // so here we can read the value directly
            value: bloc.authServiceType,
            onValueChanged: (AuthServiceType type) => bloc.setAuthServiceType(type),
            children: const <AuthServiceType, Widget>{
              AuthServiceType.firebase: Text('Firebase'),
              AuthServiceType.mock: Text('Mock'),
            },
          ),
        ],
      ),
    );
  }
}

class SegmentedControl<T> extends StatelessWidget {
  SegmentedControl({this.header, this.value, this.children, this.onValueChanged});
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
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: header,
        ),
        SizedBox(
          width: double.infinity,
          child: CupertinoSegmentedControl<T>(
            children: children,
            groupValue: value,
//            selectedColor: Palette.blueSky,
//            pressedColor: Palette.blueSkyLighter,
            onValueChanged: onValueChanged,
          ),
        ),
      ],
    );
  }
}
