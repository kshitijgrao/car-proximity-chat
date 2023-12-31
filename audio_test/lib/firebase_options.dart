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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3_Y882TGRSV3JjY-SBWG7gtJ5BlSLWHo',
    appId: '1:343426553612:web:99cd0c150749dc5c505b29',
    messagingSenderId: '343426553612',
    projectId: 'prox-94507',
    authDomain: 'prox-94507.firebaseapp.com',
    storageBucket: 'prox-94507.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmHRVdvF2EoDjoejdkxB6mdYwGmImi4mw',
    appId: '1:343426553612:android:7b385a98e71a4e41505b29',
    messagingSenderId: '343426553612',
    projectId: 'prox-94507',
    storageBucket: 'prox-94507.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0LH7kIfThoYLgqd77JJJ2deh0qlTVOog',
    appId: '1:343426553612:ios:b8f511f89f2cd0b8505b29',
    messagingSenderId: '343426553612',
    projectId: 'prox-94507',
    storageBucket: 'prox-94507.appspot.com',
    iosClientId: '343426553612-7i3l8rm4sv29isva8i27vanpmie5d1h2.apps.googleusercontent.com',
    iosBundleId: 'com.example.audioTest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0LH7kIfThoYLgqd77JJJ2deh0qlTVOog',
    appId: '1:343426553612:ios:b8f511f89f2cd0b8505b29',
    messagingSenderId: '343426553612',
    projectId: 'prox-94507',
    storageBucket: 'prox-94507.appspot.com',
    iosClientId: '343426553612-7i3l8rm4sv29isva8i27vanpmie5d1h2.apps.googleusercontent.com',
    iosBundleId: 'com.example.audioTest',
  );
}
