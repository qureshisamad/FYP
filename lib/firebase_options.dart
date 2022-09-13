// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFyTPgQmx9VRKre2NDK72_Ui_g-RUFvHI',
    appId: '1:805205457634:android:1e827fb425f0799a5efcbb',
    messagingSenderId: '805205457634',
    projectId: 'robotic-flash-347411',
    databaseURL: 'https://robotic-flash-347411-default-rtdb.firebaseio.com',
    storageBucket: 'robotic-flash-347411.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5bePibnWEn7439mZqs6Idv2-zP_8yjbw',
    appId: '1:805205457634:ios:1d88b2c6a683e1475efcbb',
    messagingSenderId: '805205457634',
    projectId: 'robotic-flash-347411',
    databaseURL: 'https://robotic-flash-347411-default-rtdb.firebaseio.com',
    storageBucket: 'robotic-flash-347411.appspot.com',
    iosClientId: '805205457634-hh8pnvveacpsuo65d9kj3lj20bpsiq8o.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );
}
