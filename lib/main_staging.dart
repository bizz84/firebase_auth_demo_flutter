import 'package:firebase_auth_demo_flutter/flavor.dart';
import 'package:firebase_auth_demo_flutter/my_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(Provider<Flavor>.value(
      value: Flavor.staging,
      child: MyApp(),
    ));
