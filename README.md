# Reference Authentication Flow with Flutter & Firebase

This project shows how to implement a full authentication flow in Flutter, using various Firebase sign-in methods.

It aims to be a reference implementation. Think of it as "authentication done right".

## Supported sign-in methods

- [x] Email and password
- [x] Google
- [x] Facebook
- [x] Anonymous
- [ ] Email link (passwordless)
- [ ] Phone


### Sign-in Page

- [x] Navigation to email and password sign-in
- [x] Google sign-in
- [x] Facebook sign-in
- [x] Anonymous sign-in

### Email page

- [x] Custom submit button with loading state
- [x] Disable all input widgets while authentication is in progress
- [x] Email regex validation
- [x] Error hints
- [x] Focus order (email -> password -> submit by pressing "next" on keyboard)
- [x] Password of at least 8 characters


### Authentication service

- [x] Abstract `AuthService` class, modeled after the `firebase_auth` API
- [x] `FirebaseAuthService` implementation
- [x] `MockAuthService` for testing

### Architecture

- [x] Logic inside BLoCs for better separation of concerns

### Other

- [x] Platform-aware alert dialogs for confirmation/error messages
- [x] Fully compliant with the official Flutter `analysis_options.yaml` rules

## TODO

- [ ] Internationalization
- [ ] Firebase project configuration for iOS & Android
- [ ] Full test coverage
- [ ] Improve documentation
- [ ] Screenshots / video for README

## [License: MIT](LICENSE.md)