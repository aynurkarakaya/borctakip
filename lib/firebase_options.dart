// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Bu dosya FlutterFire CLI ile otomatik üretilir.
/// Komutu çalıştır: flutterfire configure
/// Daha fazla bilgi için: https://firebase.flutter.dev/docs/cli
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
          'DefaultFirebaseOptions Linux desteklenmemektedir.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions bu platform icin yapilandirilmamistir.',
        );
    }
  }

  // !! ONEMLI: Bu degerleri Firebase Console > Proje Ayarlari'ndan kendi
  // projenize gore degistirin. flutterfire configure komutu bu islemi otomatik yapar.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDzK6Eb_JRfcHTk9O_GH20uGPPPUpS8R4E',
    appId: '1:498913870690:web:d5a7f0b53de20fdfd5223b',
    messagingSenderId: '498913870690',
    projectId: 'borc-takip-app-2026',
    authDomain: 'borc-takip-app-2026.firebaseapp.com',
    storageBucket: 'borc-takip-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFI7yzGIRnF_Sq3aWPQTKNPOAG6aAZa7k',
    appId: '1:498913870690:android:80e556e0592c5c14d5223b',
    messagingSenderId: '498913870690',
    projectId: 'borc-takip-app-2026',
    storageBucket: 'borc-takip-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-PROJECT-ID.appspot.com',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.example.borctakip',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-PROJECT-ID.appspot.com',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'com.example.borctakip',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDzK6Eb_JRfcHTk9O_GH20uGPPPUpS8R4E',
    appId: '1:498913870690:web:fa569e05b61b486bd5223b',
    messagingSenderId: '498913870690',
    projectId: 'borc-takip-app-2026',
    authDomain: 'borc-takip-app-2026.firebaseapp.com',
    storageBucket: 'borc-takip-app-2026.firebasestorage.app',
  );

}