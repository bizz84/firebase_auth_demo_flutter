import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service_facade.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class AuthServiceTypeBloc {
  AuthServiceTypeBloc({@required this.authServiceFacade});
  final AuthServiceFacade authServiceFacade;

  // Use BehaviorSubject to track last value when listening multiple times
  final BehaviorSubject<AuthServiceType> _authServiceTypeController =
      BehaviorSubject<AuthServiceType>.seeded(AuthServiceType.firebase);
  Stream<AuthServiceType> get authServiceTypeStream => _authServiceTypeController.stream;

  void setAuthServiceType(AuthServiceType type) {
    print('type: $type');
    authServiceFacade.authServiceType = type;
    _authServiceTypeController.add(type);
  }

  void dispose() {
    _authServiceTypeController.close();
  }
}
