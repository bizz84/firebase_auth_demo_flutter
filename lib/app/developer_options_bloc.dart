import 'dart:async';

enum AuthServiceType { firebase, mock }
//enum MockAuthServiceDefaultResponse { success, failure }

class DeveloperOptionsBloc {
  final StreamController<AuthServiceType> _authServiceTypeController = StreamController<AuthServiceType>();
  Stream<AuthServiceType> get authServiceTypeStream => _authServiceTypeController.stream;
  AuthServiceType authServiceType = AuthServiceType.firebase;

  void setAuthServiceType(AuthServiceType type) {
    print('type: $type');
    authServiceType = type;
    _authServiceTypeController.add(type);
  }

  void dispose() {
    _authServiceTypeController.close();
  }
}
