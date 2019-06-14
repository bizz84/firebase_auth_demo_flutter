import 'package:firebase_auth_demo_flutter/app/auth_service_type_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/landing_page.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service_facade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        Provider<AuthService>(
          builder: (_) => AuthServiceFacade(),
          dispose: (_, AuthService authService) => authService.dispose(),
        ),
        ProxyProvider<AuthService, AuthServiceTypeBloc>(
          builder: (_, AuthService authService, __) => AuthServiceTypeBloc(authServiceFacade: authService),
          dispose: (_, AuthServiceTypeBloc bloc) => bloc.dispose(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: LandingPage(),
      ),
    );
  }
}
