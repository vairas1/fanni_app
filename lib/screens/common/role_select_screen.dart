import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  final _nameCtrl = TextEditingController(text: '');

  Future<void> _enter(String role) async {
    final name = _nameCtrl.text.trim().isEmpty
        ? (role == 'client' ? 'عميل' : 'فني')
        : _nameCtrl.text.trim();
    final auth = context.read<AuthProvider>();
    await auth.setRole(role: role, name: name);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
        context, role == 'client' ? '/client' : '/tech');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تطبيق الخدمات الفنية\nكاميرات • دش • إنتركم',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _enter('client'),
              icon: const Icon(Icons.person_search),
              label: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('دخول كعميل', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _enter('technician'),
              icon: const Icon(Icons.handyman),
              label: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('دخول كفني', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
