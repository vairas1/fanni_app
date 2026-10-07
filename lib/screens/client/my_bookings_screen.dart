import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../common/booking_details_screen.dart';
import '../common/chat_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Color _color(String s) {
    switch (s) {
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.inProgress:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('🧾 حجوزاتي')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.clientBookings(uid),
        builder: (c, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
                child: Text('لا توجد حجوزات بعد\nاحجز من تبويب الخدمات 🛠️',
                    textAlign: TextAlign.center));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final b = Booking.fromDoc(docs[i]);
              final sc = serviceColor(b.serviceId);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sc,
                    child: const Icon(Icons.build, color: Colors.white),
                  ),
                  title: Text('${b.serviceName} - ${b.technicianName}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('yyyy/MM/dd HH:mm')
                          .format(b.dateTime)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                                BookingStatus.label(b.status),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                            backgroundColor: _color(b.status),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          const Spacer(),
                          // زر الدردشة المباشرة 💬
                          IconButton(
                            tooltip: 'الدردشة مع الفني',
                            icon: const Icon(Icons.chat_bubble,
                                color: Color(0xFF0D47A1)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ChatScreen(bookingId: b.id)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(bookingId: b.id)),
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
