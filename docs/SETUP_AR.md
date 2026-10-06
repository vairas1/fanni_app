# تشغيل المشروع خطوة بخطوة 🛠️

## 1) المتطلبات
- Flutter SDK (3.24+) + Android Studio + حساب Firebase + مفتاح Google Maps

## 2) توليد مجلدات المنصات
```bash
cd fanni_app
flutter create --platforms=android,ios --project-name fanni_app --org com.example.fanni .
```
> سيضيف مجلدي `android/` و `ios/` دون المساس بمجلد `lib/`.

## 3) انسخ إعدادات المنصات
- انسخ محتوى `platform_config/android/AndroidManifest.xml` إلى `android/app/src/main/AndroidManifest.xml` وضع مفتاح الخرائط مكان `YOUR_MAPS_KEY`
- طبّق ملاحظات `platform_config/android/app-build-gradle-NOTES.txt` على `android/app/build.gradle`
- أضف مفاتيح `platform_config/ios/Info-plist-additions.xml` داخل `ios/Runner/Info.plist`

## 4) ربط Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
- فعّل في Console: Authentication (Anonymous) + Firestore + Storage + Cloud Messaging
- انشر القواعد والفهارس:
```bash
firebase deploy --only firestore:rules,firestore:indexes
cd functions && npm install && cd ..
firebase deploy --only functions
```

## 5) أضف فنيين تجريبيين
- من Firestore Console أنشئ مجموعة `technicians` وأضف المستندات من `docs/seed_technicians.json`
- **مهم:** غيّر `_docId` إلى الـ UID الحقيقي للفني (يظهر بعد دخوله كفني من التطبيق)، أو ادخل كفني أولاً ثم عدّل بياناته

## 6) التشغيل والبناء
```bash
flutter pub get
flutter run
flutter build apk --debug
```

## 7) iOS
- يحتاج macOS + Xcode. على Windows استخدم الـ Workflow الجاهز `.github/workflows/build.yml` (Actions ← Build APK + iOS)
- نسخة قابلة للتثبيت على آيفون حقيقي تحتاج حساب Apple Developer للتوقيع
