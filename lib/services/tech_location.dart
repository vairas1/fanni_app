import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'firestore_service.dart';

/// مشاركة موقع الفني المباشر أثناء تنفيذ الحجوزات
class TechLocationService {
  Timer? _timer;
  bool _running = false;

  /// يبدأ التحديث الدوري لكل حجوزات الفني الجارية
  Future<void> start(String techId) async {
    if (_running) return;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
    } catch (_) {
      return;
    }
    _running = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await _push(techId);
    });
    await _push(techId);
  }

  Future<void> _push(String techId) async {
    try {
      final p = await Geolocator.getCurrentPosition();
      final snap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('technicianId', isEqualTo: techId)
          .where('status', whereIn: ['accepted', 'in_progress']).get();
      for (final d in snap.docs) {
        await FirestoreService.updateTechLocation(
            d.id, p.latitude, p.longitude);
      }
    } catch (_) {}
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();
}
