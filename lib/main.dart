import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/common/role_select_screen.dart';
import 'screens/common/splash_screen.dart';
import 'screens/client/client_shell.dart';
import 'screens/tech/tech_shell.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // تهيئة الإشعارات (المعالج الخلفي يجب أن يكون top-level)
  await NotificationService.init();
  runApp(const FanniApp());
}

class FanniApp extends StatelessWidget {
  const FanniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'فنيّات - خدمات تقنية',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: null,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        home: const SplashScreen(),
        routes: {
          '/role': (_) => const RoleSelectScreen(),
          '/client': (_) => const ClientShell(),
          '/tech': (_) => const TechShell(),
        },
      ),
    );
  }
}
