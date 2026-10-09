import 'dart:math' show asin, cos, pi, sin, sqrt;

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/call_buttons.dart';
import '../../widgets/screen_bg.dart';
import '../../widgets/rating_dialog.dart';
import 'chat_screen.dart';

/// تفاصيل الحجز + تتبع مباشر لموقع الفني + منبه وصول 🔔
class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _player = AudioPlayer();
  bool _rung = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// المسافة بالكيلومتر (Haversine)
  double _km(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }

  Future<void> _ringArrival(BuildContext context, Booking b) async {
    if (_rung || b.arrivalNotified) return;
    _rung = true;
    await FirestoreService.setArrivalNotified(b.id);
    try {
      await _player.play(AssetSource('alarm.wav'));
    } catch (_) {}
    await NotificationService.showLocal(
      title: '🎉 الفني وصل!',
      body: '${b.technicianName} وصل لمكانك',
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 الفني وصل!'),
        content: Text('${b.technicianName} وصل لمكانك الآن'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تمام'),
          ),
        ],
      ),
    );
  }

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
      body: ScreenBg(
        child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
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
              // خريطة التتبع المباشر 🗺️ (للعميل)
              if (!isTech &&
                  (b.status == BookingStatus.accepted ||
                      b.status == BookingStatus.inProgress))
                _trackingCard(context, b, sc),
              _row('العميل', '🙋 ${b.clientName}'),
              _row('الفني', '🛠️ ${b.technicianName}'),
              _row('العنوان', '📍 ${b.address}'),
              _row('الإحداثيات',
                  '${b.lat.toStringAsFixed(5)} ، ${b.lng.toStringAsFixed(5)}'),
              if (b.notes.isNotEmpty) _row('ملاحظات', '📝 ${b.notes}'),
              if (b.rating != null)
                _row('التقييم', '⭐ ${b.rating} ${b.review ?? ''}'),
              const SizedBox(height: 8),
              // أزرار اتصال بالطرف الآخر 📞💬
              if (!isTech && b.technicianPhone.isNotEmpty)
                CallButtons(
                    phone: b.technicianPhone, color: sc),
              if (isTech && b.clientPhone.isNotEmpty)
                CallButtons(
                    phone: b.clientPhone,
                    color: const Color(0xFF1B5E20)),
              const SizedBox(height: 8),
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
      ),
    );
  }

  /// بطاقة التتبع المباشر
  Widget _trackingCard(BuildContext context, Booking b, Color sc) {
    if (b.techLat == null || b.techLng == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'بانتظار مشاركة الفني لموقعه المباشر...')),
            ],
          ),
        ),
      );
    }
    final km = _km(b.lat, b.lng, b.techLat!, b.techLng!);
    if (km < 0.15) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ringArrival(context, b);
      });
    }
    final distTxt = km < 1
        ? 'على بعد ${(km * 1000).toInt()} متر'
        : 'على بعد ${km.toStringAsFixed(1)} كم';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🛵 ',
                    style: TextStyle(fontSize: 22)),
                Expanded(
                  child: Text(
                    km < 0.15
                        ? 'الفني وصل 🎉'
                        : 'الفني في الطريق... $distTxt',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        LatLng(b.lat, b.lng),
                    initialZoom: 14,
                    interactionOptions:
                        const InteractionOptions(
                            flags: InteractiveFlag.all &
                                ~InteractiveFlag.rotate),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.fanni.fanni_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(b.lat, b.lng),
                          width: 50,
                          height: 50,
                          child: Icon(Icons.home,
                              size: 40, color: sc),
                        ),
                        Marker(
                          point: LatLng(
                              b.techLat!, b.techLng!),
                          width: 50,
                          height: 50,
                          child: const Text('🛵',
                              style: TextStyle(fontSize: 34)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
