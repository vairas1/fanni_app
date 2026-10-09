import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/screen_bg.dart';
import 'places_screen.dart';
import 'technicians_screen.dart';

/// الشبكة الرئيسية: الخدمات الأساسية + أقسام إضافية من Firestore (بدون أسعار)
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().name;
    return Scaffold(
      appBar: AppBar(title: const Text('🔧 الخدمات والأقسام')),
      body: ScreenBg(
        child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              name.isEmpty
                  ? 'أهلاً بيك 👋\nاختار القسم اللي محتاجه'
                  : 'أهلاً $name 👋\nاختار القسم اللي محتاجه',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.categoriesStream(),
              builder: (c, snap) {
                final List<ServiceModel> items = List.of(appServices)
                  ..addAll(extraCategories);
                if (snap.hasData) {
                  for (final d in snap.data!.docs) {
                    try {
                      items.add(RemoteCategory.fromDoc(d).toService());
                    } catch (_) {}
                  }
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (c, i) {
                    final s = items[i];
                    final isRemote = s.id.startsWith('remote_');
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (isRemote) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PlacesScreen(
                                      categoryId:
                                          s.id.substring(7),
                                      title: s.nameAr,
                                      color: s.color,
                                      emoji: s.imageEmoji,
                                    )),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    TechniciansScreen(service: s)),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              s.color,
                              s.color.withOpacity(0.65)
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: s.color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s.imageEmoji,
                                style:
                                    const TextStyle(fontSize: 44)),
                            const SizedBox(height: 8),
                            Text(s.nameAr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            if (s.descAr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(s.descAr,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
