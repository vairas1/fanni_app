import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  Future<String?> createBooking({
    required String clientId,
    required String clientName,
    required String technicianId,
    required String technicianName,
    required String serviceId,
    required String serviceName,
    required double lat,
    required double lng,
    required String address,
    required DateTime dateTime,
    String notes = '',
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final id = await FirestoreService.createBooking({
        'clientId': clientId,
        'clientName': clientName,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'lat': lat,
        'lng': lng,
        'address': address,
        'dateTime': dateTime,
        'notes': notes,
      });
      return id;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setStatus(String bookingId, String status) {
    return FirestoreService.updateStatus(bookingId, status);
  }

  Future<void> rate({
    required Booking booking,
    required double rating,
    required String comment,
  }) {
    return FirestoreService.submitRating(
      bookingId: booking.id,
      technicianId: booking.technicianId,
      rating: rating,
      comment: comment,
    );
  }
}
