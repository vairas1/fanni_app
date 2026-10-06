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
      appBar: AppBar(title: Text(service.nameAr)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.techniciansStream(serviceId: service.id),
        builder: (c, snap) {
          if (snap.hasError) return Center(child: Text('خطأ: ${snap.error}'));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('لا يوجد فنيون متاحون حالياً'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final t = Technician.fromDoc(docs[i]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(t.name.isEmpty ? 'ف' : t.name[0]),
                  ),
                  title: Text(t.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RatingStars(value: t.ratingAvg, count: t.ratingCount),
                      Text(t.phone),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingScreen(service: service, technician: t),
                      ),
                    ),
                    child: const Text('احجز'),
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
