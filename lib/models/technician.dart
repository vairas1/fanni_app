import 'package:cloud_firestore/cloud_firestore.dart';

class Technician {
  final String uid;
  final String name;
  final String phone;
  final String avatarUrl;
  final List<String> services;
  final double ratingAvg;
  final int ratingCount;
  final double lat;
  final double lng;
  final bool available;
  final String? fcmToken;

  Technician({
    required this.uid,
    required this.name,
    required this.phone,
    this.avatarUrl = '',
    this.services = const [],
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.lat = 0,
    this.lng = 0,
    this.available = true,
    this.fcmToken,
  });

  factory Technician.fromDoc(DocumentSnapshot doc) {
    final m = (doc.data() as Map<String, dynamic>?) ?? {};
    return Technician(
      uid: doc.id,
      name: (m['name'] ?? 'فني') as String,
      phone: (m['phone'] ?? '') as String,
      avatarUrl: (m['avatarUrl'] ?? '') as String,
      services: List<String>.from(m['services'] ?? []),
      ratingAvg: ((m['ratingAvg'] ?? 0) as num).toDouble(),
      ratingCount: ((m['ratingCount'] ?? 0) as num).toInt(),
      lat: ((m['lat'] ?? 0) as num).toDouble(),
      lng: ((m['lng'] ?? 0) as num).toDouble(),
      available: (m['available'] ?? true) as bool,
      fcmToken: m['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'services': services,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'lat': lat,
        'lng': lng,
        'available': available,
        'role': 'technician',
      };
}
