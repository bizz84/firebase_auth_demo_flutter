abstract class Database {
  set uid(String value);

  // TODO: Firestore API calls here
}

class FirestoreDatabase implements Database {
  String _uid;

  @override
  set uid(String newValue) {
    if (_uid == newValue) {
      return;
    }
    _uid = newValue;
  }

  // TODO: Firestore API calls here
}
