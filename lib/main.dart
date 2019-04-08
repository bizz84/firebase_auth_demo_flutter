import 'package:firebase_auth_demo_flutter/app/auth_service_type_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/landing_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service_facade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final AuthServiceFacade authServiceFacade = AuthServiceFacade();
  @override
  Widget build(BuildContext context) {
    return StatefulProvider<AuthService>(
      valueBuilder: (BuildContext context) => authServiceFacade,
      onDispose: (BuildContext context, AuthService facade) => authServiceFacade.dispose(),
      child: StatefulProvider<AuthServiceTypeBloc>(
        valueBuilder: (BuildContext context) => AuthServiceTypeBloc(authServiceFacade: authServiceFacade),
        onDispose: (BuildContext context, AuthServiceTypeBloc bloc) => bloc.dispose(),
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          home: LandingPage(),
        ),
      ),
    );
  }
}
