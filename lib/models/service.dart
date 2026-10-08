import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String nameAr;
  final String descAr;
  final IconData icon;
  final double priceFrom;
  final String imageEmoji;
  final Color color;

  const ServiceModel({
    required this.id,
    required this.nameAr,
    required this.descAr,
    required this.icon,
    required this.priceFrom,
    required this.imageEmoji,
    required this.color,
  });
}

/// قائمة الخدمات التقنية — كل خدمة بلونها الخاص
const appServices = <ServiceModel>[
  ServiceModel(
    id: 'cameras',
    nameAr: 'تركيب كاميرات مراقبة',
    descAr: 'تركيب وصيانة كاميرات المراقبة DVR و IP',
    icon: Icons.videocam,
    priceFrom: 150,
    imageEmoji: '📹',
    color: Color(0xFF1565C0),
  ),
  ServiceModel(
    id: 'dish',
    nameAr: 'تركيب الدش',
    descAr: 'تركيب وضبط أطباق الدش والريسيفر',
    icon: Icons.satellite_alt,
    priceFrom: 100,
    imageEmoji: '📡',
    color: Color(0xFF6A1B9A),
  ),
  ServiceModel(
    id: 'intercom',
    nameAr: 'تركيب الإنتركم',
    descAr: 'إنتركم صوتي ومرئي للعمارات والفلل',
    icon: Icons.phone_in_talk,
    priceFrom: 200,
    imageEmoji: '🔔',
    color: Color(0xFFEF6C00),
  ),
  ServiceModel(
    id: 'network',
    nameAr: 'شبكات وإنترنت',
    descAr: 'تمديد شبكات وتقوية واي فاي',
    icon: Icons.wifi,
    priceFrom: 120,
    imageEmoji: '🌐',
    color: Color(0xFF00897B),
  ),
  ServiceModel(
    id: 'electric',
    nameAr: 'كهرباء عامة',
    descAr: 'صيانة وتأسيس كهرباء منازل',
    icon: Icons.electrical_services,
    priceFrom: 80,
    imageEmoji: '💡',
    color: Color(0xFFF9A825),
  ),
  ServiceModel(
    id: 'ac',
    nameAr: 'تكييف وتبريد',
    descAr: 'تركيب وصيانة أجهزة التكييف',
    icon: Icons.ac_unit,
    priceFrom: 130,
    imageEmoji: '❄️',
    color: Color(0xFF00ACC1),
  ),
];

/// أقسام إضافية جاهزة داخل التطبيق (تظهر فوراً بدون إعداد)
List<ServiceModel> get extraCategories => [
      const ServiceModel(
        id: 'remote_pharmacies',
        nameAr: 'صيدليات',
        descAr: 'اطلب أدوية من أقرب صيدلية',
        icon: Icons.local_pharmacy,
        priceFrom: 0,
        imageEmoji: '💊',
        color: Color(0xFF00838F),
      ),
      const ServiceModel(
        id: 'remote_markets',
        nameAr: 'سوبر ماركت',
        descAr: 'اطلب احتياجاتك من أقرب ماركت',
        icon: Icons.shopping_cart,
        priceFrom: 0,
        imageEmoji: '🛒',
        color: Color(0xFF2E7D32),
      ),
    ];

/// أماكن الأقسام الجاهزة (الاسم + التليفون + العنوان)
Map<String, List<PlaceModel>> get builtinPlaces => {
      'remote_pharmacies': [
        PlaceModel(
            id: 'p1',
            name: 'صيدلية الشفا',
            phone: '01001112233',
            address: 'شارع 15 مدينة نصر',
            emoji: '💊',
            ratingAvg: 4.7,
            ratingCount: 45),
        PlaceModel(
            id: 'p2',
            name: 'صيدلية النور',
            phone: '01004445566',
            address: 'المعادي الجديدة',
            emoji: '💊',
            ratingAvg: 4.5,
            ratingCount: 30),
      ],
      'remote_markets': [
        PlaceModel(
            id: 'm1',
            name: 'ماركت البركة',
            phone: '01007778899',
            address: 'شارع 9 المعادي',
            emoji: '🛒',
            ratingAvg: 4.6,
            ratingCount: 60),
        PlaceModel(
            id: 'm2',
            name: 'ماركت العائلة',
            phone: '01000011122',
            address: 'زهراء مدينة نصر',
            emoji: '🛒',
            ratingAvg: 4.4,
            ratingCount: 25),
      ],
    };
Color serviceColor(String serviceId) {
  for (final s in appServices) {
    if (s.id == serviceId) return s.color;
  }
  return const Color(0xFF0D47A1);
}

/// قسم قادم من Firestore (لإضافة أقسام جديدة بدون تحديث التطبيق)
class RemoteCategory {
  final String id;
  final String nameAr;
  final String descAr;
  final String imageEmoji;
  final Color color;

  RemoteCategory({
    required this.id,
    required this.nameAr,
    required this.descAr,
    required this.imageEmoji,
    required this.color,
  });

  factory RemoteCategory.fromDoc(dynamic doc) {
    final m = (doc.data() as Map<String, dynamic>?) ?? {};
    return RemoteCategory(
      id: doc.id,
      nameAr: (m['nameAr'] ?? m['name'] ?? 'قسم') as String,
      descAr: (m['descAr'] ?? m['desc'] ?? '') as String,
      imageEmoji: (m['emoji'] ?? '🏷️') as String,
      color: Color(((m['color'] ?? 0xFF0D47A1) as num).toInt()),
    );
  }

  ServiceModel toService() => ServiceModel(
        id: 'remote_$id',
        nameAr: nameAr,
        descAr: descAr,
        icon: Icons.store,
        priceFrom: 0,
        imageEmoji: imageEmoji,
        color: color,
      );
}

/// مكان داخل قسم (صيدلية / سوبر ماركت ...)
class PlaceModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String emoji;
  final double ratingAvg;
  final int ratingCount;

  PlaceModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.emoji = '🏪',
    this.ratingAvg = 0,
    this.ratingCount = 0,
  });

  factory PlaceModel.fromDoc(dynamic doc) {
    final m = (doc.data() as Map<String, dynamic>?) ?? {};
    return PlaceModel(
      id: doc.id,
      name: (m['name'] ?? 'مكان') as String,
      phone: (m['phone'] ?? '') as String,
      address: (m['address'] ?? '') as String,
      emoji: (m['emoji'] ?? '🏪') as String,
      ratingAvg: ((m['ratingAvg'] ?? 0) as num).toDouble(),
      ratingCount: ((m['ratingCount'] ?? 0) as num).toInt(),
    );
  }
}
