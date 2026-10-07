import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/service.dart';
import '../../models/technician.dart';
import '../../services/firestore_service.dart';
import '../../widgets/rating_stars.dart';
import 'booking_screen.dart';

class TechniciansScreen extends StatelessWidget {
  final ServiceModel service;
  const TechniciansScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${service.imageEmoji} ${service.nameAr}'),
        backgroundColor: service.color,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: service.color.withOpacity(0.12),
            padding: const EdgeInsets.all(12),
            child: Text(service.descAr,
                style: TextStyle(color: service.color)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirestoreService.techniciansStream(serviceId: service.id),
              builder: (c, snap) {
                if (snap.hasError) {
                  return Center(child: Text('خطأ: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('لا يوجد فنيون متاحون حالياً'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
                    final t = Technician.fromDoc(docs[i]);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: service.color,
                              child: Text(
                                t.name.isEmpty ? 'ف' : t.name[0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(t.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  RatingStars(
                                      value: t.ratingAvg,
                                      count: t.ratingCount),
                                  if (t.phone.isNotEmpty)
                                    Text('📞 ${t.phone}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: service.color),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingScreen(
                                      service: service, technician: t),
                                ),
                              ),
                              child: const Text('احجز'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
