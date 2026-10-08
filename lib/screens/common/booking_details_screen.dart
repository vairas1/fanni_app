import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/rating_dialog.dart';
import 'chat_screen.dart';

/// تفاصيل الحجز: الحالة + العنوان + (دردشة / تحديث حالة / تقييم)
class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isTech = auth.role == 'technician';
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧾 تفاصيل الحجز'),
        backgroundColor:
            isTech ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .snapshots(),
        builder: (c, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final b = Booking.fromDoc(snap.data!);
          final sc = serviceColor(b.serviceId);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    sc,
                    sc.withOpacity(0.6),
                  ]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.serviceName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text(
                        '🕙 ${DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)}',
                        style:
                            const TextStyle(color: Colors.white)),
                    Text('📌 ${BookingStatus.label(b.status)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _row('العميل', '🙋 ${b.clientName}'),
              _row('الفني', '🛠️ ${b.technicianName}'),
              _row('العنوان', '📍 ${b.address}'),
              _row('الإحداثيات',
                  '${b.lat.toStringAsFixed(5)} ، ${b.lng.toStringAsFixed(5)}'),
              if (b.notes.isNotEmpty) _row('ملاحظات', '📝 ${b.notes}'),
              if (b.rating != null)
                _row('التقييم', '⭐ ${b.rating} ${b.review ?? ''}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: sc),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(bookingId: b.id)),
                ),
                icon: const Icon(Icons.chat_bubble),
                label: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('الدردشة المباشرة 💬',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              if (isTech) _techActions(context, b),
              if (!isTech &&
                  b.status == BookingStatus.completed &&
                  b.rating == null &&
                  b.technicianId.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700]),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => RatingDialog(booking: b),
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text('قيّم الخدمة ⭐'),
                ),
              if (!isTech && b.status == BookingStatus.pending)
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await context
                          .read<BookingProvider>()
                          .setStatus(b.id, BookingStatus.cancelled);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ: $e')));
                      }
                    }
                  },
                  child: const Text('إلغاء الحجز',
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 95,
                child: Text(k,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 15))),
          ],
        ),
      );

  Widget _techActions(BuildContext context, Booking b) {
    final bp = context.read<BookingProvider>();
    Future<void> go(String s) async {
      try {
        await bp.setStatus(b.id, s);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('خطأ: $e')));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b.status == BookingStatus.pending)
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1B5E20)),
                    onPressed: () => go(BookingStatus.accepted),
                    child: const Text('قبول ✅'))),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton(
                    onPressed: () => go(BookingStatus.cancelled),
                    child: const Text('رفض',
                        style: TextStyle(color: Colors.red)))),
          ]),
        if (b.status == BookingStatus.accepted)
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange),
              onPressed: () => go(BookingStatus.inProgress),
              child: const Text('بدء التنفيذ ▶')),
        if (b.status == BookingStatus.inProgress)
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20)),
              onPressed: () => go(BookingStatus.completed),
              child: const Text('إنهاء الخدمة ✔')),
      ],
    );
  }
}
