import 'package:flutter/foundation.dart';

abstract class Database {
  // TODO: Firestore API calls here
}

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid});
  final String uid;

  // TODO: Firestore API calls here
}
