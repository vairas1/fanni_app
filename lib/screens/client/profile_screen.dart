import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isTech = auth.role == 'technician';
    return Scaffold(
      appBar: AppBar(
          title: const Text('👤 حسابي'),
          backgroundColor:
              isTech ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: isTech
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFF0D47A1),
                    child: Text(
                      auth.name.isEmpty ? '؟' : auth.name[0],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.name,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold)),
                        if (auth.phone.isNotEmpty)
                          Text('📞 ${auth.phone}',
                              style:
                                  const TextStyle(color: Colors.grey)),
                        Chip(
                          label: Text(
                              isTech ? 'فني 🛠️' : 'عميل 🙋',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          backgroundColor: isTech
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFF0D47A1),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (isTech)
            _TechSettings()
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                    '💡 احجز أي خدمة من تبويب الخدمات، وتابع حالتها وتواصل مع الفني بالدردشة من تبويب حجوزاتي.'),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/auth', (_) => false);
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('تسجيل الخروج',
                style: TextStyle(color: Colors.red)),
          ),
        ],
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
  void initState() {
    super.initState();
    phoneCtrl.text = context.read<AuthProvider>().phone;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚙️ إعدادات الفني',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SwitchListTile(
              title: const Text('متاح لاستقبال طلبات'),
              value: available,
              activeColor: const Color(0xFF1B5E20),
              onChanged: (v) => setState(() => available = v),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 8),
            const Text('خدماتي:'),
            Wrap(
              spacing: 8,
              children: [
                for (final s in appServices)
                  FilterChip(
                    label: Text('${s.imageEmoji} ${s.nameAr}'),
                    selected: selected.contains(s.id),
                    selectedColor: s.color.withOpacity(0.25),
                    onSelected: (v) => setState(() {
                      v ? selected.add(s.id) : selected.remove(s.id);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20)),
                onPressed: () async {
                  try {
                    await auth.updateTechProfile(
                      services: selected.toList(),
                      available: available,
                      phone: phoneCtrl.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم حفظ الإعدادات ✅')));
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ: $e')));
                    }
                  }
                },
                child: const Text('حفظ الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
