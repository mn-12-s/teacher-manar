import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'admin_settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ctrl = TextEditingController();
  String _err = '';
  bool _busy = false;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _err = '';
    });
    final provider = context.read<DataProvider>();
    final error = await provider.login(_ctrl.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _err = error);
    }
  }

  void _openAdmin() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminSettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final instName = context.watch<DataProvider>().instName;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ضغطة مطوّلة على الشعار تفتح إعدادات المشرف (مخفية).
                  GestureDetector(
                    onLongPress: _openAdmin,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('بوابة المدرسين',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(instName,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, letterSpacing: 6),
                    decoration: const InputDecoration(hintText: '••••'),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _login,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('دخول'),
                    ),
                  ),
                  if (_err.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(_err,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.no,
                            fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
