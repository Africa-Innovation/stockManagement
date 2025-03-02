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
    apiKey: 'AIzaSyCGOdB7WIGhM-BXoOdIDqKkn71S5evEUm8',
    appId: '1:889257060975:web:71dbe73dfbc5dd54f17b9a',
    messagingSenderId: '889257060975',
    projectId: 'stockmanagement-e8b88',
    authDomain: 'stockmanagement-e8b88.firebaseapp.com',
    storageBucket: 'stockmanagement-e8b88.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1K9tvk0nWha4rTHQp2RGg2zjGJE9q89A',
    appId: '1:889257060975:android:60258e29c2cdfd90f17b9a',
    messagingSenderId: '889257060975',
    projectId: 'stockmanagement-e8b88',
    storageBucket: 'stockmanagement-e8b88.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCR-UubE8BoQz6dRx2alYJ3aBAsFPK7kog',
    appId: '1:889257060975:ios:081c9e09f906ace8f17b9a',
    messagingSenderId: '889257060975',
    projectId: 'stockmanagement-e8b88',
    storageBucket: 'stockmanagement-e8b88.firebasestorage.app',
    iosBundleId: 'com.example.stockmanagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCR-UubE8BoQz6dRx2alYJ3aBAsFPK7kog',
    appId: '1:889257060975:ios:081c9e09f906ace8f17b9a',
    messagingSenderId: '889257060975',
    projectId: 'stockmanagement-e8b88',
    storageBucket: 'stockmanagement-e8b88.firebasestorage.app',
    iosBundleId: 'com.example.stockmanagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCGOdB7WIGhM-BXoOdIDqKkn71S5evEUm8',
    appId: '1:889257060975:web:6885114d850b9680f17b9a',
    messagingSenderId: '889257060975',
    projectId: 'stockmanagement-e8b88',
    authDomain: 'stockmanagement-e8b88.firebaseapp.com',
    storageBucket: 'stockmanagement-e8b88.firebasestorage.app',
  );
}
