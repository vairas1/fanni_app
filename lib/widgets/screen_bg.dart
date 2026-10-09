import 'package:flutter/material.dart';

/// خلفية التطبيق الاحترافية (تدرج كحلي + نقشة ناعمة)
class ScreenBg extends StatelessWidget {
  final Widget child;
  const ScreenBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
