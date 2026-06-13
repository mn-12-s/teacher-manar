import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../config/firebase_config.dart';
import '../providers/data_provider.dart';
import '../services/messaging_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = '⏳ جاري الاتصال...';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      // 1) تهيئة Firebase بإعداد المعهد الفعّال (افتراضي أو محفوظ).
      if (Firebase.apps.isEmpty) {
        final options = await FirebaseConfig.load();
        await Firebase.initializeApp(options: options);
      }

      final provider = context.read<DataProvider>();
      provider.attachFirestore(FirebaseFirestore.instance);

      // 2) إشعارات FCM (لا توقف الإقلاع عند الفشل).
      MessagingService.init();

      // 3) تحميل البيانات + محاولة دخول تلقائي.
      setState(() => _status = '⏳ جاري تحميل البيانات...');
      await provider.loadAll();

      if (provider.error != null) {
        setState(() => _status = '⚠️ تعذر الاتصال: ${provider.error}');
        return;
      }

      final auto = await provider.tryAutoLogin();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => auto ? const HomeScreen() : const LoginScreen(),
      ));
    } catch (e) {
      if (mounted) setState(() => _status = '⚠️ خطأ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, AppColors.primaryLight, AppColors.accent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.school, size: 52, color: Colors.white),
              ),
              const SizedBox(height: 18),
              const Text('بوابة المدرسين',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(_status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
