import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:firebase_auth_demo_flutter/services/email_secure_store.dart';
import 'package:firebase_auth_demo_flutter/services/firebase_email_link_handler.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {}

class MockWidgetsBinding extends Mock implements WidgetsBinding {}

class MockEmailSecureStore extends Mock implements EmailSecureStore {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFirebaseDynamicLinks extends Mock implements FirebaseDynamicLinks {}

class MockPendingDynamicLinkData extends Mock
    implements PendingDynamicLinkData {}

class MockFirebaseEmailLinkHandler extends Mock
    implements FirebaseEmailLinkHandler {}
