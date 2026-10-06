# تطبيق فنيّات 🛠️

Flutter + Firebase: واجهة عملاء + واجهة فنيين.

## المميزات
- عميل: خدمات (كاميرات/دش/إنتركم...)، اختيار فني، خريطة Google Maps، تحديد موعد
- فني: استلام طلبات، قبول/رفض، جدول زمني، تحديث الحالة
- دردشة مباشرة مع إرفاق صور (Storage + Firestore)
- تقييمات ⭐ مع متوسط تقييم الفني (Transaction)
- إشعارات FCM فورية (functions/index.js)

## التشغيل
1. `flutterfire configure` لملء `lib/firebase_options.dart`
2. أضف `google-services.json` (أندرويد) و `GoogleService-Info.plist` (iOS)
3. فعّل: Auth (Anonymous) + Firestore + Storage + FCM
4. ضع مفتاح خرائط جوجل في `AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
```
5. `flutter pub get && flutter run`
6. للنشر: `cd functions && npm install && firebase deploy --only functions,firestore:rules`

## المعاينة
- `preview_client.html` : واجهة العميل
- `preview_tech.html` : واجهة الفني
