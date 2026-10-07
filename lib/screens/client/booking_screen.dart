import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/technician.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../common/chat_screen.dart';

/// شاشة الحجز: خريطة OpenStreet (بدون مفتاح) + اختيار موعد + تأكيد
class BookingScreen extends StatefulWidget {
  final ServiceModel service;
  final Technician technician;
  const BookingScreen({super.key, required this.service, required this.technician});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  LatLng _pos = LatLng(30.0444, 31.2357); // القاهرة افتراضياً
  final MapController _mapCtrl = MapController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  Future<void> _confirm() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('من فضلك أدخل العنوان')));
      return;
    }
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سجل الدخول أولاً')));
      return;
    }
    final bp = context.read<BookingProvider>();
    final dateTime = DateTime(
        _date.year, _date.month, _date.day, _time.hour, _time.minute);
    try {
      final id = await bp.createBooking(
        clientId: auth.user!.uid,
        clientName: auth.name.isEmpty ? 'عميل' : auth.name,
        technicianId: widget.technician.uid,
        technicianName: widget.technician.name,
        serviceId: widget.service.id,
        serviceName: widget.service.nameAr,
        lat: _pos.latitude,
        lng: _pos.longitude,
        address: _addressCtrl.text.trim(),
        dateTime: dateTime,
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted || id == null) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إرسال الحجز للفني وسيصله إشعار فوري')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(bookingId: id)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر إتمام الحجز: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd').format(_date);
    final c = widget.service.color;
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز: ${widget.service.nameAr}'),
        backgroundColor: c,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: c,
                child: Text(widget.service.imageEmoji,
                    style: const TextStyle(fontSize: 22)),
              ),
              title: Text(widget.technician.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(widget.technician.phone),
            ),
          ),
          const SizedBox(height: 8),
          const Text('حدد موقعك على الخريطة (اضغط على أي مكان):',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: _pos,
                  initialZoom: 14,
                  onTap: (tap, p) => setState(() => _pos = p),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.fanni.fanni_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pos,
                        width: 60,
                        height: 60,
                        child: Icon(Icons.location_pin,
                            size: 48, color: c),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الإحداثيات: ${_pos.latitude.toStringAsFixed(5)} ، ${_pos.longitude.toStringAsFixed(5)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'العنوان بالتفصيل *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(dateStr),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_time.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'ملاحظات للفني (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<BookingProvider>(
            builder: (c2, bp, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: c),
              onPressed: bp.loading ? null : _confirm,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: bp.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('تأكيد الحجز ✅',
                        style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
