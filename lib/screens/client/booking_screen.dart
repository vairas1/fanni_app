import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/technician.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../common/chat_screen.dart';

/// شاشة الحجز: خريطة + اختيار موعد + تأكيد
class BookingScreen extends StatefulWidget {
  final ServiceModel service;
  final Technician technician;
  const BookingScreen({super.key, required this.service, required this.technician});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  LatLng _pos = const LatLng(30.0444, 31.2357); // القاهرة افتراضياً
  GoogleMapController? _mapCtrl;
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
    final bp = context.read<BookingProvider>();
    final dateTime = DateTime(
        _date.year, _date.month, _date.day, _time.hour, _time.minute);

    final id = await bp.createBooking(
      clientId: auth.user!.uid,
      clientName: auth.name,
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الحجز للفني وسيصله إشعار فوري')));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(bookingId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd').format(_date);
    return Scaffold(
      appBar: AppBar(title: Text('حجز: ${widget.service.nameAr}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.handyman)),
            title: Text(widget.technician.name),
            subtitle: Text(widget.technician.phone),
          ),
          const SizedBox(height: 8),
          const Text('حدد موقعك على الخريطة:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _pos, zoom: 14),
                markers: {
                  Marker(
                      markerId: const MarkerId('me'),
                      position: _pos,
                      draggable: true,
                      onDragEnd: (v) => setState(() => _pos = v))
                },
                onMapCreated: (c) => _mapCtrl = c,
                onTap: (v) => setState(() => _pos = v),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'حرّك الخريطة أو اسحب الدبوس لتحديد موقعك بدقة',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'العنوان بالتفصيل',
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
            builder: (c, bp, _) => ElevatedButton(
              onPressed: bp.loading ? null : _confirm,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: bp.loading
                    ? const CircularProgressIndicator()
                    : const Text('تأكيد الحجز',
                        style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
