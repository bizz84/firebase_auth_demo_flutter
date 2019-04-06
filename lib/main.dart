import 'package:firebase_auth_demo_flutter/app/developer_options_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/landing_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/mock_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeveloperOptionsBloc developerOptionsBloc = DeveloperOptionsBloc();
    return StatefulProvider<DeveloperOptionsBloc>(
      valueBuilder: (BuildContext context) => developerOptionsBloc,
      onDispose: (BuildContext context, DeveloperOptionsBloc bloc) => bloc.dispose(),
      child: Consumer<DeveloperOptionsBloc>(
        builder: (BuildContext context, DeveloperOptionsBloc bloc) {
          return StreamBuilder<AuthServiceType>(
              stream: developerOptionsBloc.authServiceTypeStream,
              initialData: AuthServiceType.firebase,
              builder: (BuildContext context, AsyncSnapshot<AuthServiceType> snapshot) {
                print('type: ${snapshot.data}');
                return Provider<AuthService>(
                  value: _buildAuthService(snapshot.data),
                  child: MaterialApp(
                    theme: ThemeData(
                      primarySwatch: Colors.indigo,
                    ),
                    home: LandingPage(),
                  ),
                );
              });
        },
      ),
    );
  }

  AuthService _buildAuthService(AuthServiceType type) {
    switch (type) {
      case AuthServiceType.firebase:
        return FirebaseAuthService();
      case AuthServiceType.mock:
      default:
        return MockAuthService();
    }
  }
}
