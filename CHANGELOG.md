# 0.1.3

- Fix email-link sign in ([#59](https://github.com/bizz84/firebase_auth_demo_flutter/pull/59))

# 0.1.2

- Add sign-in with Apple

# 0.1.1

- Update to Provider version 4.0.1

# 0.1.0

- Update to all latest Dart packages as of 2019-12-19

# 0.0.9

- Add `AuthWidgetBuilder` above `MaterialApp` ([#39](https://github.com/bizz84/firebase_auth_demo_flutter/pull/39), fixes [#32](https://github.com/bizz84/firebase_auth_demo_flutter/issues/32))
- Only update loading state `ValueNotifier` when authentication calls fail ([#41](https://github.com/bizz84/firebase_auth_demo_flutter/pull/41))
- Update dependencies

# 0.0.8

- Add widget tests for email and password sign-in ([#31](https://github.com/bizz84/firebase_auth_demo_flutter/pull/31))
- Show camera image icon when avatar is not loaded
- Use the new FocusScopeNode in the email & password page

# 0.0.7

- Show the user photo and display name in the HomePage ([#29](https://github.com/bizz84/firebase_auth_demo_flutter/pull/29))

# 0.0.6

- Add sign-in with email link (passwordless) ([#28](https://github.com/bizz84/firebase_auth_demo_flutter/pull/28))

# 0.0.5

- Update to firebase_auth 0.14.0 and fix breaking changes ([#27](https://github.com/bizz84/firebase_auth_demo_flutter/pull/27))

# 0.0.4

- Simpler (and less opinionated) email regex validator ([#24](https://github.com/bizz84/firebase_auth_demo_flutter/pull/24), see [#20](https://github.com/bizz84/firebase_auth_demo_flutter/issues/20))

# 0.0.3

- Rename `AuthServiceFacade` to `AuthServiceAdapter`
- Do not use `listen: false` in `Provider.of<AuthService>` calls.

# 0.0.2

- Simplify `AuthServiceFacade` creation, add `ValueNotifier<AuthServiceType>` ([#14](https://github.com/bizz84/firebase_auth_demo_flutter/pull/14), [#15](https://github.com/bizz84/firebase_auth_demo_flutter/pull/15))

# 0.0.1

## FirebaseAuth features

### Supported sign-in methods

- [x] Anonymous
- [x] Email & Password
- [x] Facebook
- [x] Google

### Other authentication features

- [x] Password reset

## Application features

### Sign-in Page

- [x] Navigation to email and password sign-in
- [x] Google sign-in
- [x] Facebook sign-in
- [x] Anonymous sign-in

### Email & password page

- [x] Custom submit button with loading state
- [x] Disable all input widgets while authentication is in progress
- [x] Email regex validation
- [x] Error hints
- [x] Focus order (email -> password -> submit by pressing "next" on keyboard)
- [x] Password of at least 8 characters when registering
- [x] Password reset flow

### Authentication

- [x] Abstract `AuthService` class, modeled after the `firebase_auth` API
- [x] `FirebaseAuthService` implementation
- [x] `MockAuthService` for testing
- [x] Firebase project configuration for iOS & Android
- [x] Toggle `FirebaseAuthService` and `MockAuthService` at runtime via developer menu

### Architecture

- [x] Logic inside models for better separation of concerns (using ChangeNotifier)

### Other

- [x] Platform-aware alert dialogs for confirmation/error messages
- [x] Fully compliant with the official Flutter `analysis_options.yaml` rules
