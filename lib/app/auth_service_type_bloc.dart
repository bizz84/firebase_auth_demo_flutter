import 'dart:async';

import 'package:firebase_auth_demo_flutter/services/auth_service_facade.dart';
import 'package:meta/meta.dart';

class AuthServiceTypeBloc {
  AuthServiceTypeBloc({@required this.authServiceFacade});
  final AuthServiceFacade authServiceFacade;

  final StreamController<AuthServiceType> _authServiceTypeController = StreamController<AuthServiceType>.broadcast();
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
