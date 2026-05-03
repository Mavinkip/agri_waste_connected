import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbwTyetEmbreywKaEKWrsBLiW50R4IziE',
    appId: '1:365460448162:web:216ab580f9d90d5e2308fb',
    messagingSenderId: '365460448162',
    projectId: 'agri-waste-farmer',
    authDomain: 'agri-waste-farmer.firebaseapp.com',
    storageBucket: 'agri-waste-farmer.firebasestorage.app',
    measurementId: 'G-G0YE0ZVVTF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbwTyetEmbreywKaEKWrsBLiW50R4IziE',
    appId: '1:365460448162:android:216ab580f9d90d5e2308fb',
    messagingSenderId: '365460448162',
    projectId: 'agri-waste-farmer',
    storageBucket: 'agri-waste-farmer.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbwTyetEmbreywKaEKWrsBLiW50R4IziE',
    appId: '1:365460448162:ios:216ab580f9d90d5e2308fb',
    messagingSenderId: '365460448162',
    projectId: 'agri-waste-farmer',
    storageBucket: 'agri-waste-farmer.firebasestorage.app',
  );
}
