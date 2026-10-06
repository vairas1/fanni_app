// ملف إعدادات Firebase النموذجي.
// شغّل: flutterfire configure  لإعادة توليد هذا الملف تلقائياً.
// أو املأ القيم من لوحة Firebase Console.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('غير مدعوم على Linux');
      default:
        return android;
    }
  }

  // ضع قيم مشروعك هنا بعد flutterfire configure
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PUT_YOUR_API_KEY',
    appId: 'PUT_YOUR_APP_ID',
    messagingSenderId: 'PUT_SENDER_ID',
    projectId: 'PUT_PROJECT_ID',
    authDomain: 'PUT_PROJECT_ID.firebaseapp.com',
    storageBucket: 'PUT_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBH_q1UCanYx21xmko75dyIhX7mKgHCmWw',
    appId: '1:496402154712:android:e7f4df31096148e7c603ad',
    messagingSenderId: '496402154712',
    projectId: 'fanni-app-8abb0',
    storageBucket: 'fanni-app-8abb0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBt5vBXJ56TN9PvdBrfxXNhEZTYBN6_XEc',
    appId: '1:496402154712:ios:8242d83075e6bf30c603ad',
    messagingSenderId: '496402154712',
    projectId: 'fanni-app-8abb0',
    storageBucket: 'fanni-app-8abb0.firebasestorage.app',
    iosBundleId: 'com.example.fanni.fanniApp',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
}
