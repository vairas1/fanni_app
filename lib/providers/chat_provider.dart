import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';

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
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return;
    _sending = true;
    notifyListeners();
    try {
      final url = await FirestoreService.uploadChatImage(bookingId, file);
      await FirestoreService.sendMessage(
        bookingId: bookingId,
        senderId: senderId,
        text: '',
        imageUrl: url,
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
