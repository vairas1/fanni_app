import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/firestore_service.dart';
import '../common/booking_details_screen.dart';
import '../common/chat_screen.dart';

const techGreen = Color(0xFF1B5E20);

/// طلبات الحجز الجديدة للفني + الكل
class TechRequestsScreen extends StatelessWidget {
  const TechRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
          title: const Text('📥 طلبات الحجز'), backgroundColor: techGreen),
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
            return const Center(
                child: Text('لا توجد طلبات جديدة 🎉',
                    style: TextStyle(fontSize: 17)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pending.length,
            itemBuilder: (c, i) {
              final b = pending[i];
              final sc = serviceColor(b.serviceId);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundColor: sc,
                              child: const Icon(Icons.build,
                                  color: Colors.white)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                '${b.serviceName} - ${b.clientName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                          '🕙 ${DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)}'),
                      Text('📍 ${b.address}'),
                      if (b.notes.isNotEmpty)
                        Text('📝 ${b.notes}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: techGreen),
                              onPressed: () async {
                                try {
                                  await context
                                      .read<BookingProvider>()
                                      .setStatus(
                                          b.id, BookingStatus.accepted);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text('خطأ: $e')));
                                  }
                                }
                              },
                              child: const Text('قبول ✅'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context
                                  .read<BookingProvider>()
                                  .setStatus(
                                      b.id, BookingStatus.cancelled),
                              child: const Text('رفض'),
                            ),
                          ),
                          IconButton(
                            tooltip: 'الدردشة',
                            icon: const Icon(Icons.chat_bubble,
                                color: techGreen),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ChatScreen(bookingId: b.id)),
                            ),
                          ),
                          IconButton(
                            tooltip: 'التفاصيل',
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BookingDetailsScreen(
                                      bookingId: b.id)),
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
