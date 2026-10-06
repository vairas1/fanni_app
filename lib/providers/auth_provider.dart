import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// إدارة الدخول والدور (عميل / فني)
class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  String? _role; // client | technician
  String _name = '';

  String? get role => _role;
  String get name => _name;
  User? get user => _auth.currentUser;

  Future<void> init() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final uid = _auth.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _role = doc.data()?['role'] as String?;
    _name = (doc.data()?['name'] ?? '') as String;
    notifyListeners();
  }

  Future<void> setRole({required String role, required String name}) async {
    final uid = _auth.currentUser!.uid;
    _role = role;
    _name = name;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': role,
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (role == 'technician') {
      // إنشاء/تحديث ملف الفني
      await FirebaseFirestore.instance.collection('technicians').doc(uid).set({
        'name': name,
        'phone': '',
        'services': ['cameras', 'dish', 'intercom'],
        'available': true,
      }, SetOptions(merge: true));
      await NotificationService.subscribeTechnician();
    }
    await NotificationService.saveTokenToFirestore(uid);
    notifyListeners();
  }

  Future<void> updateTechProfile({
    required List<String> services,
    required bool available,
    required String phone,
  }) async {
    final uid = _auth.currentUser!.uid;
    await FirebaseFirestore.instance.collection('technicians').doc(uid).set({
      'services': services,
      'available': available,
      'phone': phone,
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _role = null;
    notifyListeners();
  }
}
