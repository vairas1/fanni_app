import 'package:cloud_firestore/cloud_firestore.dart';

/// حالات الحجز
class BookingStatus {
  static const pending = 'pending'; // بانتظار قبول الفني
  static const accepted = 'accepted'; // مقبول
  static const inProgress = 'in_progress'; // جارٍ التنفيذ
  static const completed = 'completed'; // مكتمل
  static const cancelled = 'cancelled'; // ملغي

  static String label(String s) {
    switch (s) {
      case pending:
        return 'بانتظار القبول';
      case accepted:
        return 'مقبول';
      case inProgress:
        return 'جارٍ التنفيذ';
      case completed:
        return 'مكتمل';
      case cancelled:
        return 'ملغي';
      default:
        return s;
    }
  }
}

class Booking {
  final String id;
  final String clientId;
  final String clientName;
  final String technicianId;
  final String technicianName;
  final String serviceId;
  final String serviceName;
  final double lat;
  final double lng;
  final String address;
  final DateTime dateTime;
  final String status;
  final String notes;
  final double? rating;
  final String? review;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.technicianId,
    required this.technicianName,
    required this.serviceId,
    required this.serviceName,
    required this.lat,
    required this.lng,
    required this.address,
    required this.dateTime,
    required this.status,
    this.notes = '',
    this.rating,
    this.review,
    required this.createdAt,
  });

  factory Booking.fromDoc(DocumentSnapshot doc) {
    final m = (doc.data() as Map<String, dynamic>?) ?? {};
    DateTime parseTs(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }

    return Booking(
      id: doc.id,
      clientId: (m['clientId'] ?? '') as String,
      clientName: (m['clientName'] ?? '') as String,
      technicianId: (m['technicianId'] ?? '') as String,
      technicianName: (m['technicianName'] ?? '') as String,
      serviceId: (m['serviceId'] ?? '') as String,
      serviceName: (m['serviceName'] ?? '') as String,
      lat: ((m['lat'] ?? 0) as num).toDouble(),
      lng: ((m['lng'] ?? 0) as num).toDouble(),
      address: (m['address'] ?? '') as String,
      dateTime: parseTs(m['dateTime']),
      status: (m['status'] ?? BookingStatus.pending) as String,
      notes: (m['notes'] ?? '') as String,
      rating: m['rating'] == null ? null : ((m['rating']) as num).toDouble(),
      review: m['review'] as String?,
      createdAt: parseTs(m['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'clientName': clientName,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'lat': lat,
        'lng': lng,
        'address': address,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': status,
        'notes': notes,
        'rating': rating,
        'review': review,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
