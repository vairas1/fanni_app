import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inbox), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'جدولي'),
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
