import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
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
        return;
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
