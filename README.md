# Flutter FCM Example

A small demo app for using Firestore Cloud Messaging with Flutter. This app shows a web page specified by the payload of push notification.
To deploy, you need to register [iOS](https://firebase.google.com/docs/cloud-messaging/ios/first-message#register-app) or [Android](https://firebase.google.com/docs/cloud-messaging/android/first-message#register_your_app_with_firebase) apps on Firebase Console
and place `GoogleService-Info.plist` and `google-services.json` to `ios/Runner` and `android/app`, respectively.

## FYI: things that made me confused

1. `onMessage` and `onResume` are not called in iOS

Though the [README](https://pub.dev/packages/firebase_messaging#ios-integration) of firebase\_messaging requires an addition to `AppDelegate.swift`, it disables these functions according to [this issue](https://github.com/FirebaseExtended/flutterfire/issues/2009).

2. Notifications don't launch the app in Android

We need to include a `click_action: FLUTTER_NOTIFICATION_CLICK` property to the nofitication payload as mentioned in the [README](https://pub.dev/packages/firebase_messaging#sending-messages).

3. WebView in iOS app shows a blank page

We need to add an `io.flutter.embedded_views_preview` parameter in `Info.plist` as mentioned in the [README](https://pub.dev/packages/webview_flutter#developers-preview-status) of flutter\_webview.
