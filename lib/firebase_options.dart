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
    apiKey: 'AIzaSyDYAZWpvTFYG6Efc-gGyf1T9zARTh3yzvA',
    appId: '1:622741993787:web:16f11f686471c3be305f1e',
    messagingSenderId: '622741993787',
    projectId: 'zenipay',
    authDomain: 'zenipay.firebaseapp.com',
    storageBucket: 'zenipay.appspot.com',
    measurementId: 'G-W62VJN47QZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhSkBozZjIT-6dEopD0pm913A2ON0Ixqk',
    appId: '1:622741993787:android:38f901d972071645305f1e',
    messagingSenderId: '622741993787',
    projectId: 'zenipay',
    storageBucket: 'zenipay.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnzPU_Sgp8XJnRU9Ob6dbAeWI1ecOiaYI',
    appId: '1:622741993787:ios:49e943fa18a87be3305f1e',
    messagingSenderId: '622741993787',
    projectId: 'zenipay',
    storageBucket: 'zenipay.appspot.com',
    iosClientId: '622741993787-81rfslqfpb9agqpov1lis4hs5b06b1ic.apps.googleusercontent.com',
    iosBundleId: 'zenifin.zenipay',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAnzPU_Sgp8XJnRU9Ob6dbAeWI1ecOiaYI',
    appId: '1:622741993787:ios:49e943fa18a87be3305f1e',
    messagingSenderId: '622741993787',
    projectId: 'zenipay',
    storageBucket: 'zenipay.appspot.com',
    iosClientId: '622741993787-81rfslqfpb9agqpov1lis4hs5b06b1ic.apps.googleusercontent.com',
    iosBundleId: 'zenifin.zenipay',
  );
}
