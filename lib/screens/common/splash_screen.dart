import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    await auth.init();
    if (!mounted) return;
    if (auth.role == 'client') {
      Navigator.pushReplacementNamed(context, '/client');
    } else if (auth.role == 'technician') {
      Navigator.pushReplacementNamed(context, '/tech');
    } else {
      Navigator.pushReplacementNamed(context, '/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
