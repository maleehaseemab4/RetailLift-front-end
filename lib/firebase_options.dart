import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBL6hzDs8CvUYg5chHOj3n3pjNqtgR0vuM',
    appId: '1:334937589408:android:e34826db18516e5c886bc5',
    messagingSenderId: '334937589408',
    projectId: 'retaillift-ed290',
    storageBucket: 'retaillift-ed290.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD3XYMWheIqRwCREGHuh3EUIM9qK2NusEI',
    appId: '1:334937589408:ios:61f1e74b9d053759886bc5',
    messagingSenderId: '334937589408',
    projectId: 'retaillift-ed290',
    storageBucket: 'retaillift-ed290.firebasestorage.app',
    iosBundleId: 'com.example.shopliftingApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDg9cn4F1t3dxicgR44qRN3oDbUCud-dGE',
    appId: '1:334937589408:web:0737a2ed5a209a23886bc5',
    messagingSenderId: '334937589408',
    projectId: 'retaillift-ed290',
    authDomain: 'retaillift-ed290.firebaseapp.com',
    storageBucket: 'retaillift-ed290.firebasestorage.app',
    measurementId: 'G-LDLHRE1PQY',
  );
}
