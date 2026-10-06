import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/firestore_service.dart';
import '../common/booking_details_screen.dart';

/// الجدول الزمني للفني + تحديث حالة الخدمة
class TechScheduleScreen extends StatelessWidget {
  const TechScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('جدولي الزمني')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.techBookings(uid),
        builder: (c, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!.docs
              .map((d) => Booking.fromDoc(d))
              .where((b) =>
                  b.status == BookingStatus.accepted ||
                  b.status == BookingStatus.inProgress ||
                  b.status == BookingStatus.completed)
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          if (all.isEmpty) {
            return const Center(child: Text('لا توجد مهام مجدولة'));
          }
          return ListView.builder(
            itemCount: all.length,
            itemBuilder: (c, i) {
              final b = all[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${b.serviceName} - ${b.clientName}'),
                  subtitle: Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)}\n${BookingStatus.label(b.status)}'),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingDetailsScreen(bookingId: b.id)),
                  ),
                  trailing: _NextAction(booking: b),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NextAction extends StatelessWidget {
  final Booking booking;
  const _NextAction({required this.booking});

  @override
  Widget build(BuildContext context) {
    final bp = context.read<BookingProvider>();
    switch (booking.status) {
      case BookingStatus.accepted:
        return ElevatedButton(
          onPressed: () => bp.setStatus(booking.id, BookingStatus.inProgress),
          child: const Text('بدء'),
        );
      case BookingStatus.inProgress:
        return ElevatedButton(
          onPressed: () => bp.setStatus(booking.id, BookingStatus.completed),
          child: const Text('إنهاء'),
        );
      default:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}
