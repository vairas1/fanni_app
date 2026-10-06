import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String nameAr;
  final String descAr;
  final IconData icon;
  final double priceFrom;
  final String imageEmoji;

  const ServiceModel({
    required this.id,
    required this.nameAr,
    required this.descAr,
    required this.icon,
    required this.priceFrom,
    required this.imageEmoji,
  });
}

/// قائمة الخدمات التقنية الثابتة (تركيب كاميرات / دش / إنتركم ...)
const appServices = <ServiceModel>[
  ServiceModel(
    id: 'cameras',
    nameAr: 'تركيب كاميرات مراقبة',
    descAr: 'تركيب وصيانة كاميرات المراقبة DVR و IP',
    icon: Icons.videocam,
    priceFrom: 150,
    imageEmoji: '📹',
  ),
  ServiceModel(
    id: 'dish',
    nameAr: 'تركيب الدش',
    descAr: 'تركيب وضبط أطباق الدش والريسيفر',
    icon: Icons.satellite_alt,
    priceFrom: 100,
    imageEmoji: '📡',
  ),
  ServiceModel(
    id: 'intercom',
    nameAr: 'تركيب الإنتركم',
    descAr: 'إنتركم صوتي ومرئي للعمارات والفلل',
    icon: Icons.phone_in_talk,
    priceFrom: 200,
    imageEmoji: '🔔',
  ),
  ServiceModel(
    id: 'network',
    nameAr: 'شبكات وإنترنت',
    descAr: 'تمديد شبكات وتقوية واي فاي',
    icon: Icons.wifi,
    priceFrom: 120,
    imageEmoji: '🌐',
  ),
  ServiceModel(
    id: 'electric',
    nameAr: 'كهرباء عامة',
    descAr: 'صيانة وتأسيس كهرباء منازل',
    icon: Icons.electrical_services,
    priceFrom: 80,
    imageEmoji: '💡',
  ),
  ServiceModel(
    id: 'ac',
    nameAr: 'تكييف وتبريد',
    descAr: 'تركيب وصيانة أجهزة التكييف',
    icon: Icons.ac_unit,
    priceFrom: 130,
    imageEmoji: '❄️',
  ),
];
