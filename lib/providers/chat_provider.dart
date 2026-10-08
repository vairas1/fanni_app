import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';

/// إرسال نصوص + صور (مضغوطة base64 داخل Firestore — لا يحتاج Storage مدفوع)
class ChatProvider extends ChangeNotifier {
  bool _sending = false;
  bool get sending => _sending;

  Future<void> sendText({
    required String bookingId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    await FirestoreService.sendMessage(
      bookingId: bookingId,
      senderId: senderId,
      text: text.trim(),
    );
  }

  Future<void> sendImage({
    required String bookingId,
    required String senderId,
  }) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 60,
    );
    if (file == null) return;
    _sending = true;
    notifyListeners();
    try {
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 600 * 1024) {
        throw 'الصورة كبيرة — اختر صورة أصغر';
      }
      await FirestoreService.sendMessage(
        bookingId: bookingId,
        senderId: senderId,
        text: '',
        imageBase64: base64Encode(bytes),
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
