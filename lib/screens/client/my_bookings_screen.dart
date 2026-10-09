import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/screen_bg.dart';
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
      body: ScreenBg(
        child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.clientBookings(uid),
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
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
                child: Text('لا توجد حجوزات بعد\nاحجز من تبويب الخدمات 🛠️',
                    textAlign: TextAlign.center));
          }
          final list = docs.map((d) => Booking.fromDoc(d)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          // مسح تلقائي للمنتهية الأقدم من 7 أيام
          FirestoreService.cleanupOldBookings(docs);
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final b = list[i];
              final sc = serviceColor(b.serviceId);
              return Dismissible(
                key: ValueKey(b.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('مسح الحجز؟'),
                          content: const Text(
                              'سيتم مسح هذا الحجز نهائياً'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('إلغاء')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('مسح',
                                    style:
                                        TextStyle(color: Colors.red))),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) {
                  FirestoreService.deleteBooking(b.id).catchError(
                      (_) {});
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم مسح الحجز 🗑️')));
                },
                child: Card(
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
