import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// أزرار اتصال عادي 📞 + واتساب مجاني 💬 برقم معيّن
class CallButtons extends StatelessWidget {
  final String phone;
  final Color color;
  const CallButtons({super.key, required this.phone, required this.color});

  /// تحويل الرقم المصري لصيغة واتساب الدولية
  static String toWhatsApp(String phone) {
    var p = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('01') && p.length == 11) {
      p = '2$p';
    } else if (p.startsWith('1') && p.length == 10) {
      p = '20$p';
    }
    return p;
  }

  static Future<void> callPhone(
      BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  static Future<void> whatsapp(
      BuildContext context, String phone) async {
    final uri =
        Uri.parse('https://wa.me/${toWhatsApp(phone)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ثبت واتساب أولاً')));
      }
    } catch (_) {}
  }

  Future<void> _call(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'تعذر الاتصال';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e: $phone')));
      }
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/${toWhatsApp(phone)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode.externalApplication);
      } else {
        throw 'ثبت واتساب أولاً';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (phone.trim().isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.phone, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(phone,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: () => _call(context),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('اتصال'),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366)),
              onPressed: () => _whatsapp(context),
              icon: const Text('💬', style: TextStyle(fontSize: 16)),
              label: const Text('واتساب'),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة المطور: اسلام عادل + الرقمين + اتصال وواتساب
class DeveloperCard extends StatelessWidget {
  const DeveloperCard({super.key});

  static const _n1 = '01128307052';
  static const _n2 = '01019492116';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('👨‍💻 ',
                    style: TextStyle(fontSize: 24)),
                Expanded(
                  child: Text('مطور البرنامج: اسلام عادل',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _numRow(context, _n1),
            const SizedBox(height: 6),
            _numRow(context, _n2),
          ],
        ),
      ),
    );
  }

  Widget _numRow(BuildContext context, String phone) {
    return Row(
      children: [
        Expanded(
          child: Text('📞 $phone',
              style: const TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () async {
            final uri = Uri(scheme: 'tel', path: phone);
            try {
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            } catch (_) {}
          },
          child: const Text('اتصال 📞'),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366)),
          onPressed: () async {
            final uri = Uri.parse(
                'https://wa.me/${CallButtons.toWhatsApp(phone)}');
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            } catch (_) {}
          },
          child: const Text('واتساب 💬'),
        ),
      ],
    );
  }
}
