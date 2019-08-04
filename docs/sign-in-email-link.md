
# Sign-in with email link (password-less)

This document shows:

- how to add password-less sign-in to Flutter projects.
- how this is implemented in this reference demo app.

## User flow

Once setup is done (see steps below), the user can sign-in via email link by following this sequence:

![](../media/email-link-sequence.png)

In summary:

- the user can enter and sumbit her email address to Firebase
- Firebase sends an email with an activation link to that address
- the user taps on the link, and is taken back to the app
- the app signs in the user if the link was valid

## Setup steps

This section shows how to setup password-less sign in with Flutter & Firebase.

TODO: Expand with screenshots & explanations

### 1. Firebase Dynamic Links page

Choose a new domain (e.g. `domain.page.link`), and add a dynamic link.

TODO: Screenshot

Firebase will present a wizard, where it's possible to setup a few options, including the link behaviour on iOS/Android

### 2. Authentication -> Sign-in method

Enable both Email/Password and Email link as a sign-in method.

Scroll down to the Authorized domains section, and note the name of the default domain named `*.firebaseapp.com`.

### 3. Firebae project settings

Ensure that the support email is set.

Add an Android app and configure the SHA-1 and SHA-256 fingerprints.

Add an iOS app and setup the App Store ID and Team ID.

Use the (?) tooltip for instructions on the steps above.

### 4. Android setup

TODO: AndroidManifest.xml changes

### 5. iOS setup

TODO: Associated domains changes

## Additional reference

The official docs have guides for setting things up on iOS and Android (not Flutter):

- [Authenticate with Firebase Using Email Link in iOS](https://firebase.google.com/docs/auth/ios/email-link-auth)
- [Authenticate with Firebase Using Email Link in Android](https://firebase.google.com/docs/auth/android/email-link-auth)
- [Passing State in Email Actions](https://firebase.google.com/docs/auth/ios/passing-state-in-email-actions#configuring_firebase_dynamic_links)
