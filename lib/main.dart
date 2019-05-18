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
    return Provider<AuthService>(
      builder: (_) => authServiceFacade,
      dispose: (_, AuthService facade) => authServiceFacade.dispose(),
      child: Provider<AuthServiceTypeBloc>(
        builder: (_) => AuthServiceTypeBloc(authServiceFacade: authServiceFacade),
        dispose: (_, AuthServiceTypeBloc bloc) => bloc.dispose(),
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
