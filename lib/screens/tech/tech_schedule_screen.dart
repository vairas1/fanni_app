import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/screen_bg.dart';
import '../common/booking_details_screen.dart';
import 'tech_requests_screen.dart' show techGreen;

/// الجدول الزمني للفني + تحديث حالة الخدمة
class TechScheduleScreen extends StatelessWidget {
  const TechScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
          title: const Text('📅 جدولي الزمني'),
          backgroundColor: techGreen),
      body: ScreenBg(
        child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.techBookings(uid),
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
          final all = snap.data!.docs
              .map((d) => Booking.fromDoc(d))
              .where((b) =>
                  b.status == BookingStatus.accepted ||
                  b.status == BookingStatus.inProgress ||
                  b.status == BookingStatus.completed)
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          FirestoreService.cleanupOldBookings(snap.data!.docs);
          if (all.isEmpty) {
            return const Center(
                child: Text('لا توجد مهام مجدولة'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: all.length,
            itemBuilder: (c, i) {
              final b = all[i];
              final sc = serviceColor(b.serviceId);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sc,
                    child: const Icon(Icons.build,
                        color: Colors.white),
                  ),
                  title: Text('${b.serviceName} - ${b.clientName}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)}\n${BookingStatus.label(b.status)}${b.rating != null ? ' ⭐${b.rating}' : ''}'),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(bookingId: b.id)),
                  ),
                  trailing: _NextAction(booking: b),
                ),
              );
            },
          );
        },
      ),
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
    Future<void> go(String s) async {
      try {
        await bp.setStatus(booking.id, s);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('خطأ: $e')));
        }
      }
    }

    switch (booking.status) {
      case BookingStatus.accepted:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange),
          onPressed: () => go(BookingStatus.inProgress),
          child: const Text('بدء ▶'),
        );
      case BookingStatus.inProgress:
        return ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: techGreen),
          onPressed: () => go(BookingStatus.completed),
          child: const Text('إنهاء ✔'),
        );
      default:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}
