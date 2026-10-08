import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final String? imageBase64;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.text = '',
    this.imageUrl,
    this.imageBase64,
    required this.createdAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final m = (doc.data() as Map<String, dynamic>?) ?? {};
    DateTime parseTs(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }

    return ChatMessage(
      id: doc.id,
      senderId: (m['senderId'] ?? '') as String,
      text: (m['text'] ?? '') as String,
      imageUrl: m['imageUrl'] as String?,
      imageBase64: m['imageBase64'] as String?,
      createdAt: parseTs(m['createdAt']),
    );
  }

  Map<String, dynamic> toMap(String senderId) => {
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
