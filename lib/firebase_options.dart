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
    apiKey: 'AIzaSyCQ3mqJTyaR6mjRZvMa9SsEXPURbPBa6LI',
    appId: '1:210315915755:android:89f0655a1f8e73dfe6e9ae',
    messagingSenderId: '210315915755',
    projectId: 'wanderin-app',
    storageBucket: 'wanderin-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwvuppo40AA82oLgg1xR1ud22IiBvexHs',
    appId: '1:210315915755:ios:7a51f03e28274034e6e9ae',
    messagingSenderId: '210315915755',
    projectId: 'wanderin-app',
    storageBucket: 'wanderin-app.appspot.com',
    androidClientId: '210315915755-vjgu58v8ed56kjhc6tbst4m5qt57knb1.apps.googleusercontent.com',
    iosClientId: '210315915755-km2h2rd19rg6a8410at7tfv9sbrc0kql.apps.googleusercontent.com',
    iosBundleId: 'com.example.wanderinApp',
  );
}
