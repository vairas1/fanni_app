import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/screen_bg.dart';

/// الدردشة المباشرة بين العميل والفني مع إرفاق صور 📷
class ChatScreen extends StatefulWidget {
  final String bookingId;
  final String serviceId;
  const ChatScreen(
      {super.key, required this.bookingId, this.serviceId = ''});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  bool _showEmoji = false;

  static const _emojis = [
    '😀', '😁', '😂', '🤣', '😊', '😍', '😎', '🤔',
    '👍', '👎', '🙏', '👏', '👋', '💪', '✅', '❌',
    '⏰', '📍', '📷', '📞', '🏠', '🚗', '💰', '⭐',
    '🎉', '🔧', '📹', '📡', '🔔', '🌐', '💡', '❄️',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    final chat = context.watch<ChatProvider>();
    final sc = serviceColor(widget.serviceId);
    return Scaffold(
      appBar: AppBar(
          title: const Text('💬 الدردشة المباشرة'), backgroundColor: sc),
      body: ScreenBg(
        child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirestoreService.messagesStream(widget.bookingId),
              builder: (c, snap) {
                if (snap.hasError) {
                  return Center(child: Text('خطأ: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final msgs = snap.data!.docs
                    .map((d) => ChatMessage.fromDoc(d))
                    .toList();
                if (msgs.isEmpty) {
                  return const Center(
                      child: Text(
                          'ابدأ المحادثة مع الطرف الآخر 👋\nيمكنك إرفاق صور من زر 📷',
                          textAlign: TextAlign.center));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (c, i) {
                    final m = msgs[i];
                    final mine = m.senderId == uid;
                    return Align(
                      alignment: mine
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context)
                                    .size
                                    .width *
                                0.75),
                        decoration: BoxDecoration(
                          color: mine ? sc : Colors.grey[200],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (m.imageBase64 != null &&
                                m.imageBase64!.isNotEmpty)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(m.imageBase64!),
                                  height: 170,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (m.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(m.imageUrl!,
                                    height: 170,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (c, w, p) =>
                                        p == null
                                            ? w
                                            : const SizedBox(
                                                height: 170,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Colors
                                                                .white)))),
                              ),
                            if (m.text.isNotEmpty)
                              Text(m.text,
                                  style: TextStyle(
                                      color: mine
                                          ? Colors.white
                                          : Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (chat.sending) const LinearProgressIndicator(),
          if (_showEmoji)
            Container(
              height: 220,
              color: Colors.grey[100],
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8),
                itemCount: _emojis.length,
                itemBuilder: (c, i) => InkWell(
                  onTap: () {
                    _ctrl.text += _emojis[i];
                    _ctrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _ctrl.text.length));
                  },
                  child: Center(
                      child: Text(_emojis[i],
                          style:
                              const TextStyle(fontSize: 26))),
                ),
              ),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _showEmoji
                            ? Icons.keyboard
                            : Icons.emoji_emotions,
                        color: sc),
                    tooltip: 'إيموجي 😀',
                    onPressed: () => setState(
                        () => _showEmoji = !_showEmoji),
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on, color: sc),
                    tooltip: 'إرسال موقعي 📍',
                    onPressed: chat.sending
                        ? null
                        : () => _sendLocation(context, uid),
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: sc),
                    tooltip: 'إرفاق صورة 📷',
                    onPressed: chat.sending
                        ? null
                        : () async {
                            try {
                              await context
                                  .read<ChatProvider>()
                                  .sendImage(
                                    bookingId: widget.bookingId,
                                    senderId: uid,
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text('تعذر رفع الصورة: $e')));
                              }
                            }
                          },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _send(uid),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: sc,
                    child: IconButton(
                      icon: const Icon(Icons.send,
                          color: Colors.white, size: 20),
                      onPressed: () => _send(uid),
                    ),
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

  void _send(String uid) {
    if (_ctrl.text.trim().isEmpty || uid.isEmpty) return;
    context.read<ChatProvider>().sendText(
          bookingId: widget.bookingId,
          senderId: uid,
          text: _ctrl.text,
        );
    _ctrl.clear();
  }

  /// إرسال الموقع الحالي في الشات 📍 (للعميل والفني)
  Future<void> _sendLocation(BuildContext context, String uid) async {
    if (uid.isEmpty) return;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw 'يرجى السماح بالوصول للموقع من إعدادات الموبايل';
      }
      final p = await Geolocator.getCurrentPosition();
      final link =
          'https://www.openstreetmap.org/?mlat=${p.latitude}&mlon=${p.longitude}#map=16/${p.latitude}/${p.longitude}';
      await context.read<ChatProvider>().sendText(
            bookingId: widget.bookingId,
            senderId: uid,
            text:
                '📍 موقعي الحالي:\n${p.latitude.toStringAsFixed(5)} ، ${p.longitude.toStringAsFixed(5)}\n$link',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال موقعك 📍')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
