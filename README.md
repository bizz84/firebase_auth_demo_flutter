# Reference Authentication Flow with Flutter & Firebase

This project shows how to implement a full authentication flow in Flutter, using various Firebase sign-in methods.

It aims to be a reference implementation. Think of it as "authentication done right".

## Project goals

This project aims to show how to:

- use the various Firebase sign-in methods
- abstract away Firebase authentication code
- build a robust authentication flow
- use blocs for state management and better separation of concerns
- handle errors and present user-friendly error messages 

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

### Authentication

- [x] Abstract `AuthService` class, modeled after the `firebase_auth` API
- [x] `FirebaseAuthService` implementation
- [x] `MockAuthService` for testing
- [x] Firebase project configuration for iOS & Android

### Architecture

- [x] Logic inside BLoCs for better separation of concerns

### Other

- [x] Platform-aware alert dialogs for confirmation/error messages
- [x] Fully compliant with the official Flutter `analysis_options.yaml` rules

## TODO

- [ ] Internationalization
- [ ] Full test coverage
- [ ] Improve documentation
- [ ] Screenshots / video for README

## [License: MIT](LICENSE.md)