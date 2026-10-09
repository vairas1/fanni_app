import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../services/tech_location.dart';
import 'tech_requests_screen.dart';
import 'tech_schedule_screen.dart';
import '../client/profile_screen.dart';

class TechShell extends StatefulWidget {
  const TechShell({super.key});

  @override
  State<TechShell> createState() => _TechShellState();
}

class _TechShellState extends State<TechShell> {
  int _i = 0;
  final _pages = const [
    TechRequestsScreen(),
    TechScheduleScreen(),
    ProfileScreen(),
  ];

  StreamSubscription<QuerySnapshot>? _sub;
  final Set<String> _seen = {};
  bool _first = true;
  final _locService = TechLocationService();
  bool _locStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _watchBookings());
  }

  /// تنبيه فوري داخل التطبيق عند وصول حجز جديد 🔔
  void _watchBookings() {
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    if (uid.isEmpty) return;
    _sub = FirestoreService.techBookings(uid).listen((snap) {
      if (_first) {
        _first = false;
        _seen.addAll(snap.docs.map((d) => d.id));
      }
      // بدء/إيقاف مشاركة الموقع حسب وجود مهام جارية
      final hasActive = snap.docs.any((d) {
        final m = (d.data() as Map<String, dynamic>?) ?? {};
        final s = (m['status'] ?? '') as String;
        return s == 'accepted' || s == 'in_progress';
      });
      if (hasActive && !_locStarted) {
        _locStarted = true;
        _locService.start(uid);
      } else if (!hasActive && _locStarted) {
        _locStarted = false;
        _locService.stop();
      }
      for (final d in snap.docs) {
        if (_seen.contains(d.id)) continue;
        _seen.add(d.id);
        try {
          final b = Booking.fromDoc(d);
          if (b.status == BookingStatus.pending) {
            NotificationService.showLocal(
              title: '🔔 حجز جديد: ${b.serviceName}',
              body: '${b.clientName} - ${b.address}',
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('🔔 حجز جديد: ${b.serviceName}')));
            }
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _locService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.inbox), label: 'الطلبات'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'جدولي'),
          NavigationDestination(
              icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
