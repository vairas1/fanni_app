import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

/// شاشة الدخول وإنشاء الحساب (إيميل + باسورد + اسم + موبايل + الدور)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _role = 'client';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _routeByRole(BuildContext context, String? role) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      role == 'technician' ? '/tech' : '/client',
      (_) => false,
    );
  }

  Future<void> _doLogin() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      _err('أدخل الإيميل والباسورد');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signIn(
            email: _email.text,
            password: _pass.text,
          );
      if (!mounted) return;
      _routeByRole(context, context.read<AuthProvider>().role);
    } on FirebaseAuthException catch (e) {
      _err(_ar(e.code));
    } catch (e) {
      _err('تعذر الدخول: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doSignup() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _pass.text.length < 6) {
      _err('أكمل البيانات (الباسورد 6 أحرف على الأقل)');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signUp(
            name: _name.text,
            phone: _phone.text,
            email: _email.text,
            password: _pass.text,
            role: _role,
          );
      if (!mounted) return;
      _routeByRole(context, _role);
    } on FirebaseAuthException catch (e) {
      _err(_ar(e.code));
    } catch (e) {
      _err('تعذر إنشاء الحساب: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _ar(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'الإيميل مسجل بالفعل — سجل الدخول';
      case 'invalid-email':
        return 'صيغة الإيميل غير صحيحة';
      case 'weak-password':
        return 'الباسورد ضعيف (6 أحرف على الأقل)';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      case 'network-request-failed':
        return 'مشكلة في الإنترنت';
      default:
        return 'خطأ: $code';
    }
  }

  void _err(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('🔧', style: TextStyle(fontSize: 56)),
              const Text('فنيّات',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Text('كاميرات • دش • إنتركم • شبكات',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tab,
                      labelColor: const Color(0xFF0D47A1),
                      tabs: const [
                        Tab(text: 'تسجيل الدخول'),
                        Tab(text: 'حساب جديد'),
                      ],
                    ),
                    SizedBox(
                      height: 380,
                      child: TabBarView(
                        controller: _tab,
                        children: [
                          _loginTab(),
                          _signupTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool pass = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: c,
        obscureText: pass,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _loginTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      children: [
        _field(_email, 'الإيميل', Icons.email,
            type: TextInputType.emailAddress),
        _field(_pass, 'الباسورد', Icons.lock, pass: true),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: _loading ? null : _doLogin,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('دخول', style: TextStyle(fontSize: 17)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signupTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      children: [
        _field(_name, 'الاسم', Icons.person),
        _field(_phone, 'رقم الموبايل', Icons.phone,
            type: TextInputType.phone),
        _field(_email, 'الإيميل', Icons.email,
            type: TextInputType.emailAddress),
        _field(_pass, 'الباسورد (6+ أحرف)', Icons.lock, pass: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('عميل 🙋'),
                  selected: _role == 'client',
                  onSelected: (_) => setState(() => _role = 'client'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('فني 🛠️'),
                  selected: _role == 'technician',
                  onSelected: (_) => setState(() => _role = 'technician'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: _loading ? null : _doSignup,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('إنشاء الحساب',
                      style: TextStyle(fontSize: 17)),
            ),
          ),
        ),
      ],
    );
  }
}
