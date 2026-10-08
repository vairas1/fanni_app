import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/service.dart';
import '../../models/technician.dart';
import '../../services/firestore_service.dart';
import '../../widgets/rating_stars.dart';
import 'booking_screen.dart';

/// منيو الأماكن داخل القسم (صيدليات / سوبر ماركت ...) + طلب من المكان
class PlacesScreen extends StatelessWidget {
  final String categoryId;
  final String title;
  final Color color;
  final String emoji;
  const PlacesScreen({
    super.key,
    required this.categoryId,
    required this.title,
    required this.color,
    this.emoji = '🏪',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$emoji $title'), backgroundColor: color),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.placesStream(categoryId),
        builder: (c, snap) {
          if (snap.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('خطأ في التحميل:\n${snap.error}',
                  textAlign: TextAlign.center),
            ));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final places =
              snap.data!.docs.map((d) => PlaceModel.fromDoc(d)).toList();
          if (places.isEmpty) {
            return const Center(
                child: Text('لا توجد أماكن مضافة بعد في هذا القسم'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: places.length,
            itemBuilder: (c, i) {
              final p = places[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: color,
                        child: Text(p.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            if (p.address.isNotEmpty)
                              Text('📍 ${p.address}',
                                  style: const TextStyle(
                                      color: Colors.grey)),
                            if (p.phone.isNotEmpty)
                              Text('📞 ${p.phone}',
                                  style: const TextStyle(
                                      color: Colors.grey)),
                            if (p.ratingCount > 0)
                              RatingStars(
                                  value: p.ratingAvg,
                                  count: p.ratingCount),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: color),
                        onPressed: () {
                          // طلب من المكان: حجز بدون فني معيّن
                          final svc = ServiceModel(
                            id: 'remote_$categoryId',
                            nameAr: 'طلب من ${p.name}',
                            descAr: title,
                            icon: Icons.store,
                            priceFrom: 0,
                            imageEmoji: p.emoji,
                            color: color,
                          );
                          final tech = Technician(
                            uid: '',
                            name: p.name,
                            phone: p.phone,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(
                                  service: svc, technician: tech),
                            ),
                          );
                        },
                        child: const Text('اطلب'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
