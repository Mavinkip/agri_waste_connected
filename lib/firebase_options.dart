import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAagFCNfx1oAr2rXbinI_t9-vS8nK6hfA4',
    appId: '1:992467198831:android:99faf58b3219d25e52fe9a',
    messagingSenderId: '992467198831',
    projectId: 'consolt-bd64e',
    storageBucket: 'consolt-bd64e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAagFCNfx1oAr2rXbinI_t9-vS8nK6hfA4',
    appId: '1:992467198831:ios:99faf58b3219d25e52fe9a',
    messagingSenderId: '992467198831',
    projectId: 'consolt-bd64e',
    storageBucket: 'consolt-bd64e.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAagFCNfx1oAr2rXbinI_t9-vS8nK6hfA4',
    appId: '1:992467198831:web:99faf58b3219d25e52fe9a',
    messagingSenderId: '992467198831',
    projectId: 'consolt-bd64e',
    storageBucket: 'consolt-bd64e.firebasestorage.app',
    authDomain: 'consolt-bd64e.firebaseapp.com',
  );
}
