import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/rating_dialog.dart';
import 'chat_screen.dart';

/// تفاصيل الحجز: الحالة + الخريطة/العنوان + أزرار (دردشة / تحديث حالة / تقييم)
class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isTech = auth.role == 'technician';
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _row('الخدمة', b.serviceName),
              _row('العميل', b.clientName),
              _row('الفني', b.technicianName),
              _row('الحالة', BookingStatus.label(b.status)),
              _row('الموعد',
                  DateFormat('yyyy/MM/dd HH:mm').format(b.dateTime)),
              _row('العنوان', b.address),
              if (b.notes.isNotEmpty) _row('ملاحظات', b.notes),
              if (b.rating != null)
                _row('التقييم', '${b.rating} ⭐ ${b.review ?? ''}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(bookingId: b.id)),
                ),
                icon: const Icon(Icons.chat),
                label: const Text('الدردشة المباشرة'),
              ),
              const SizedBox(height: 8),
              if (isTech) _techActions(context, b),
              if (!isTech &&
                  b.status == BookingStatus.completed &&
                  b.rating == null)
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => RatingDialog(booking: b),
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text('قيّم الخدمة'),
                ),
              if (!isTech && b.status == BookingStatus.pending)
                OutlinedButton(
                  onPressed: () => context
                      .read<BookingProvider>()
                      .setStatus(b.id, BookingStatus.cancelled),
                  child: const Text('إلغاء الحجز'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 90,
                child: Text(k,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey))),
            Expanded(child: Text(v)),
          ],
        ),
      );

  Widget _techActions(BuildContext context, Booking b) {
    final bp = context.read<BookingProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b.status == BookingStatus.pending)
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () =>
                        bp.setStatus(b.id, BookingStatus.accepted),
                    child: const Text('قبول'))),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton(
                    onPressed: () =>
                        bp.setStatus(b.id, BookingStatus.cancelled),
                    child: const Text('رفض'))),
          ]),
        if (b.status == BookingStatus.accepted)
          ElevatedButton(
              onPressed: () =>
                  bp.setStatus(b.id, BookingStatus.inProgress),
              child: const Text('بدء التنفيذ')),
        if (b.status == BookingStatus.inProgress)
          ElevatedButton(
              onPressed: () => bp.setStatus(b.id, BookingStatus.completed),
              child: const Text('إنهاء الخدمة')),
      ],
    );
  }
}
