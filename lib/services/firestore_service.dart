import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ---------- الفنيون ----------
  // ملاحظة: فلتر واحد فقط لتجنب الحاجة لفهرس مركب — يُستكمل الفلترة في الواجهة
  static Stream<QuerySnapshot> techniciansStream({String? serviceId}) {
    if (serviceId != null && serviceId.isNotEmpty) {
      return _db
          .collection('technicians')
          .where('services', arrayContains: serviceId)
          .snapshots();
    }
    return _db
        .collection('technicians')
        .where('available', isEqualTo: true)
        .snapshots();
  }

  // ---------- الحجوزات ----------
  static Future<String> createBooking(Map<String, dynamic> data) async {
    final ref = await _db.collection('bookings').add({
      ...data,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Stream<QuerySnapshot> clientBookings(String clientId) {
    // بدون orderBy لتجنب الفهرس المركب — الترتيب يتم في الواجهة
    return _db
        .collection('bookings')
        .where('clientId', isEqualTo: clientId)
        .snapshots();
  }

  static Stream<QuerySnapshot> techBookings(String techId, {String? status}) {
    // بدون orderBy لتجنب الفهرس المركب — الترتيب يتم في الواجهة
    return _db
        .collection('bookings')
        .where('technicianId', isEqualTo: techId)
        .snapshots();
  }

  static Future<void> updateStatus(String bookingId, String status) {
    return _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  /// حفظ التقييم وتحديث متوسط تقييم الفني بمعاملة واحدة
  static Future<void> submitRating({
    required String bookingId,
    required String technicianId,
    required double rating,
    required String comment,
  }) async {
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final techRef = _db.collection('technicians').doc(technicianId);
    await _db.runTransaction((tx) async {
      final techSnap = await tx.get(techRef);
      final m = techSnap.data() ?? {};
      final count = ((m['ratingCount'] ?? 0) as num).toInt();
      final avg = ((m['ratingAvg'] ?? 0) as num).toDouble();
      final newCount = count + 1;
      final newAvg = ((avg * count) + rating) / newCount;
      tx.update(techRef, {'ratingAvg': newAvg, 'ratingCount': newCount});
      tx.update(bookingRef, {'rating': rating, 'review': comment});
      tx.set(_db.collection('reviews').doc(), {
        'bookingId': bookingId,
        'technicianId': technicianId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ---------- الدردشة ----------
  static Stream<QuerySnapshot> messagesStream(String bookingId) {
    return _db
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    String text = '',
    String? imageUrl,
    String? imageBase64,
  }) {
    return _db
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------- الأقسام والأماكن (منيو ديناميكي) ----------
  static Stream<QuerySnapshot> categoriesStream() {
    return _db.collection('categories').snapshots();
  }

  static Stream<QuerySnapshot> placesStream(String categoryId) {
    return _db.collection('categories').doc(categoryId).collection('places').snapshots();
  }

  // ---------- حذف وتنظيف تلقائي ----------
  static Future<void> deleteBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).delete();
  }

  static bool _cleaned = false;

  /// مسح تلقائي للحجوزات المكتملة/الملغية الأقدم من 7 أيام (يعمل مرة واحدة)
  static void cleanupOldBookings(List<QueryDocumentSnapshot> docs) {
    if (_cleaned) return;
    _cleaned = true;
    try {
      final limit = DateTime.now().subtract(const Duration(days: 7));
      var n = 0;
      for (final d in docs) {
        if (n >= 10) break;
        final m = (d.data() as Map<String, dynamic>?) ?? {};
        final st = (m['status'] ?? '') as String;
        if (st != 'completed' && st != 'cancelled') continue;
        final ts = m['createdAt'];
        DateTime? created;
        if (ts is Timestamp) created = ts.toDate();
        if (created == null || created.isAfter(limit)) continue;
        n++;
        _db.collection('bookings').doc(d.id).delete().catchError((_) {});
      }
    } catch (_) {}
  }
  static Future<String> uploadChatImage(String bookingId, XFile file) async {
    final ref = FirebaseStorage.instance.ref().child(
        'chats/$bookingId/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
    await ref.putFile(File(file.path));
    return ref.getDownloadURL();
  }
}
