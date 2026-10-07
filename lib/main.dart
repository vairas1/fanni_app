import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/common/auth_screen.dart';
import 'screens/common/splash_screen.dart';
import 'screens/client/client_shell.dart';
import 'screens/tech/tech_shell.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  runApp(const FanniApp());
}

class FanniApp extends StatelessWidget {
  const FanniApp({super.key});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0D47A1);
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
          colorScheme: ColorScheme.fromSeed(seedColor: deepBlue),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: deepBlue,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: deepBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Color(0xFFBBDEFB),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/auth': (_) => const AuthScreen(),
          '/client': (_) => const ClientShell(),
          '/tech': (_) => const TechShell(),
        },
      ),
    );
  }
}
