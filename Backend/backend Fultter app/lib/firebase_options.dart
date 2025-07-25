// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAS8TAvwIDl09tGl0Lv3CCJYDC2dTlou8',
    appId: '1:432197373959:web:4669a1c62e9444cbd31aa2',
    messagingSenderId: '432197373959',
    projectId: 'nutritrack-aef4a',
    authDomain: 'nutritrack-aef4a.firebaseapp.com',
    storageBucket: 'nutritrack-aef4a.firebasestorage.app',
    measurementId: 'G-Q1EXY016KP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJ-v-X0FIUDHxKnXm1KzE3Q2ofk6GHEbI',
    appId: '1:432197373959:android:ee9eceb2bf0b73e5d31aa2',
    messagingSenderId: '432197373959',
    projectId: 'nutritrack-aef4a',
    storageBucket: 'nutritrack-aef4a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBq60wxg4SQAopSjKtzSTY8GeEula-zZVQ',
    appId: '1:432197373959:ios:8289569b0cc2b311d31aa2',
    messagingSenderId: '432197373959',
    projectId: 'nutritrack-aef4a',
    storageBucket: 'nutritrack-aef4a.firebasestorage.app',
    iosBundleId: 'com.example.africaIsTalkingTest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBq60wxg4SQAopSjKtzSTY8GeEula-zZVQ',
    appId: '1:432197373959:ios:8289569b0cc2b311d31aa2',
    messagingSenderId: '432197373959',
    projectId: 'nutritrack-aef4a',
    storageBucket: 'nutritrack-aef4a.firebasestorage.app',
    iosBundleId: 'com.example.africaIsTalkingTest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAS8TAvwIDl09tGl0Lv3CCJYDC2dTlou8',
    appId: '1:432197373959:web:ff828f817a753681d31aa2',
    messagingSenderId: '432197373959',
    projectId: 'nutritrack-aef4a',
    authDomain: 'nutritrack-aef4a.firebaseapp.com',
    storageBucket: 'nutritrack-aef4a.firebasestorage.app',
    measurementId: 'G-G4VBS3NCCX',
  );
}
