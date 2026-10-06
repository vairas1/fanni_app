import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// المعالج الخلفي يجب أن يكون دالة top-level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: DarwinInitializationSettings());
    await _local.initialize(settings);

    // إظهار إشعار محلي عند استلام رسالة أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final n = msg.notification;
      if (n != null) {
        _local.show(
          n.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'bookings_channel',
              'تنبيهات الحجوزات',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  /// حفظ توكن الجهاز في مستند المستخدم ليستعمله Cloud Functions
  static Future<void> saveTokenToFirestore(String uid) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    // لو المستخدم فني، انسخ التوكن أيضاً لمجموعة technicians
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if ((userDoc.data()?['role'] ?? '') == 'technician') {
      await FirebaseFirestore.instance.collection('technicians').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }
  }

  static Future<void> subscribeTechnician() async {
    await _messaging.subscribeToTopic('technicians');
  }

  static User? get currentUser => FirebaseAuth.instance.currentUser;
}
