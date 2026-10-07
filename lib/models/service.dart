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

/// لون الخدمة حسب الـ id (يُستخدم في الحجوزات والدردشة)
Color serviceColor(String serviceId) {
  for (final s in appServices) {
    if (s.id == serviceId) return s.color;
  }
  return const Color(0xFF0D47A1);
}
