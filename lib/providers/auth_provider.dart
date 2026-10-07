import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// الدخول الحقيقي: إيميل + باسورد (+ اسم ورقم موبايل ودور عند التسجيل)
class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;

  String? _role; // client | technician
  String _name = '';
  String _phone = '';
  bool _ready = false;

  String? get role => _role;
  String get name => _name;
  String get phone => _phone;
  bool get ready => _ready;
  bool get isSignedIn => _auth.currentUser != null;
  User? get user => _auth.currentUser;

  Future<void> init() async {
    final u = _auth.currentUser;
    if (u != null) await _loadRole(u.uid);
    _ready = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen((u) async {
      if (u == null) {
        _role = null;
        _name = '';
        _phone = '';
      } else {
        await _loadRole(u.uid);
      }
      notifyListeners();
    });
  }

  Future<void> _loadRole(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final m = doc.data();
      _role = m?['role'] as String?;
      _name = (m?['name'] ?? '') as String;
      _phone = (m?['phone'] ?? '') as String;
    } catch (_) {
      _role = null;
    }
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': role,
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _role = role;
    _name = name.trim();
    _phone = phone.trim();
    await _afterRole(uid, role, name.trim());
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _loadRole(cred.user!.uid);
    await NotificationService.saveTokenToFirestore(cred.user!.uid);
    notifyListeners();
  }

  Future<void> _afterRole(String uid, String role, String name) async {
    if (role == 'technician') {
      await FirebaseFirestore.instance.collection('technicians').doc(uid).set({
        'name': name,
        'phone': _phone,
        'services': ['cameras', 'dish', 'intercom'],
        'available': true,
      }, SetOptions(merge: true));
      try {
        await NotificationService.subscribeTechnician();
      } catch (_) {}
    }
    try {
      await NotificationService.saveTokenToFirestore(uid);
    } catch (_) {}
  }

  Future<void> updateTechProfile({
    required List<String> services,
    required bool available,
    required String phone,
  }) async {
    final uid = _auth.currentUser!.uid;
    _phone = phone;
    await FirebaseFirestore.instance.collection('technicians').doc(uid).set({
      'services': services,
      'available': available,
      'phone': phone,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'phone': phone},
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _role = null;
    _name = '';
    _phone = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
