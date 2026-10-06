import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../common/booking_details_screen.dart';

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
    final uid = context.watch<AuthProvider>().user!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.clientBookings(uid),
        builder: (c, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات بعد'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final b = Booking.fromDoc(docs[i]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${b.serviceName} - ${b.technicianName}'),
                  subtitle: Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)}\n${BookingStatus.label(b.status)}'),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(BookingStatus.label(b.status),
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                    backgroundColor: _color(b.status),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingDetailsScreen(bookingId: b.id)),
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
