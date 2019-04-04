# Reference Authentication Flow with Flutter & Firebase

This project shows how to implement a full authentication flow in Flutter, using various Firebase sign-in methods.

It aims to be a reference implementation. Think of it as "authentication done right".

## DONE

- [x] Email and password registration & sign in flow
- [x] Only stateless widgets with BLoCs for better separation of concerns

### Email page

- [x] Custom submit button with loading state
- [x] Disable all form inputs while authentication is in progress
- [x] Email regex validation
- [x] Error hints
- [x] Focus order (email -> password -> submit by pressing "next" on keyboard)

### Authentication service

- [x] Abstract `AuthService` class, modeled after the `firebase_auth` API
- [x] `FirebaseAuthService` implementation
- [x] `MockAuthService` for testing

### Other

- [x] Platform-aware alert dialogs for confirmation/error messages
- [x] Fully compliant with the official Flutter `analysis_options.yaml` rules

## TODO

- [ ] Google sign-in
- [ ] Facebook sign-in
- [ ] Anonymous sign-in
- [ ] Internationalization
- [ ] Firebase project configuration for iOS & Android
- [ ] Full test coverage
- [ ] Password of at least 8 characters
- [ ] Client password validation against 10000 most common password
- [ ] Improve documentation
- [ ] Screenshots / video for README

## [License: MIT](LICENSE.md)