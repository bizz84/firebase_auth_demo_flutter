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
