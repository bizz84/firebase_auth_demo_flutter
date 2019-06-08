# Reference Authentication Flow with Flutter & Firebase

This project shows how to implement a full authentication flow in Flutter, using various Firebase sign-in methods.

It aims to be a reference implementation. Think of it as "authentication done right".

## Project goals

This project shows how to:

- use the various Firebase sign-in methods
- build a robust authentication flow
- use appropriate state management techniques to separate UI, logic and Firebase authentication code
- handle errors and present user-friendly error messages
- write production-ready code following best practices

Feel free to use this in your own projects. 😉

_NOTE: This project will be kept up to date with the latest packages and Flutter version._

## Preview

![](media/firebase-auth-screens.png)

**Google Sign-in**

![](media/google-sign-in.gif)

**Facebook Sign-in**

![](media/facebook-sign-in.gif)

**Email & Password auth**

![](media/email-password-sign-in.gif)

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
- [ ] Show/hide password
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

## TODO

- [ ] Internationalization
- [ ] Full test coverage
- [ ] Improve documentation

## Running the project with Firebase

To use this project with Firebase authentication, some configuration steps are required.

- Create a new project with the Firebase console.
- Add iOS and Android apps in the Firebase project settings.
- On Android, use `com.codingwithflutter.firebase_auth_demo_flutter` as the package name (a SHA-1 certificate fingerprint is also needed for Google sign-in)
- then, download and copy `google-services.json` into `android/app`
- On iOS, use `com.codingwithflutter.firebaseAuthDemoFlutter` as the bundle ID
- then, download and copy `GoogleService-Info.plist` into `iOS/Runner`, and add it to the Runner target in Xcode

Additional setup instructions for Google and Facebook sign-in:

- Google Sign-In on iOS: [https://firebase.google.com/docs/auth/ios/google-signin](https://firebase.google.com/docs/auth/ios/google-signin)
- Google Sign-In on Android: [https://firebase.google.com/docs/auth/android/google-signin](https://firebase.google.com/docs/auth/android/google-signin)
- Facebook Login for Android: [https://developers.facebook.com/docs/facebook-login/android](https://developers.facebook.com/docs/facebook-login/android)
- Facebook Login for iOS: [https://developers.facebook.com/docs/facebook-login/ios](https://developers.facebook.com/docs/facebook-login/ios)

## Additional References

A lot of the techniques used in this project are explained in great detail, and implemented step-by-step in my Flutter & Firebase Udemy course.

This is available for early access at this link (discount code included):

- [Flutter & Firebase: Build a Complete App for iOS & Android](https://www.udemy.com/flutter-firebase-build-a-complete-app-for-ios-android/?couponCode=DART15&password=codingwithflutter)


## [License: MIT](LICENSE.md)