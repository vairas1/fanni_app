import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/firestore_service.dart';
import '../common/booking_details_screen.dart';

/// طلبات الحجز الجديدة للفني (pending) + الكل
class TechRequestsScreen extends StatelessWidget {
  const TechRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الحجز')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.techBookings(uid),
        builder: (c, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all =
              snap.data!.docs.map((d) => Booking.fromDoc(d)).toList();
          final pending =
              all.where((b) => b.status == BookingStatus.pending).toList();
          if (pending.isEmpty) {
            return const Center(child: Text('لا توجد طلبات جديدة 🎉'));
          }
          return ListView.builder(
            itemCount: pending.length,
            itemBuilder: (c, i) {
              final b = pending[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${b.serviceName} - ${b.clientName}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)),
                      Text(b.address),
                      if (b.notes.isNotEmpty) Text('ملاحظات: ${b.notes}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context
                                  .read<BookingProvider>()
                                  .setStatus(b.id, BookingStatus.accepted),
                              child: const Text('قبول'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context
                                  .read<BookingProvider>()
                                  .setStatus(b.id, BookingStatus.cancelled),
                              child: const Text('رفض'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      BookingDetailsScreen(bookingId: b.id)),
                            ),
                          ),
                        ],
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
