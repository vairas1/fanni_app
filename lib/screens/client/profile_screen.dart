import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(auth.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(auth.user?.uid ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            if (auth.role == 'technician')
              _TechSettings()
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('يمكنك حجز: تركيب كاميرات، دش، إنتركم والمزيد من تبويب الخدمات.'),
                ),
              ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/role', (_) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechSettings extends StatefulWidget {
  @override
  State<_TechSettings> createState() => _TechSettingsState();
}

class _TechSettingsState extends State<_TechSettings> {
  bool available = true;
  final Set<String> selected = {'cameras', 'dish', 'intercom'};
  final phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إعدادات الفني', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('متاح لاستقبال طلبات'),
              value: available,
              onChanged: (v) => setState(() => available = v),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in appServices)
                  FilterChip(
                    label: Text(s.nameAr),
                    selected: selected.contains(s.id),
                    onSelected: (v) => setState(() {
                      v ? selected.add(s.id) : selected.remove(s.id);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await auth.updateTechProfile(
                  services: selected.toList(),
                  available: available,
                  phone: phoneCtrl.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ الإعدادات')));
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
