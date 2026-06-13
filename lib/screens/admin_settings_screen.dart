import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/firebase_config.dart';
import '../theme/app_theme.dart';

/// شاشة مخفية للمشرف لربط معهد جديد (تغيير قاعدة Firebase وقت التشغيل).
/// تُفتح بالضغط المطوّل على شعار شاشة الدخول.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _projectId = TextEditingController();
  final _apiKey = TextEditingController();
  final _appId = TextEditingController();
  final _sender = TextEditingController();
  final _authDomain = TextEditingController();
  final _bucket = TextEditingController();
  bool _hasCustom = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final o = await FirebaseConfig.load();
    final custom = await FirebaseConfig.hasCustom();
    setState(() {
      _projectId.text = o.projectId;
      _apiKey.text = o.apiKey;
      _appId.text = o.appId;
      _sender.text = o.messagingSenderId;
      _authDomain.text = o.authDomain ?? '';
      _bucket.text = o.storageBucket ?? '';
      _hasCustom = custom;
    });
  }

  Future<void> _save() async {
    if (_projectId.text.trim().isEmpty ||
        _apiKey.text.trim().isEmpty ||
        _appId.text.trim().isEmpty ||
        _sender.text.trim().isEmpty) {
      _msg('يرجى تعبئة الحقول الأساسية (projectId, apiKey, appId, senderId)');
      return;
    }
    await FirebaseConfig.save(
      apiKey: _apiKey.text.trim(),
      appId: _appId.text.trim(),
      messagingSenderId: _sender.text.trim(),
      projectId: _projectId.text.trim(),
      authDomain:
          _authDomain.text.trim().isEmpty ? null : _authDomain.text.trim(),
      storageBucket:
          _bucket.text.trim().isEmpty ? null : _bucket.text.trim(),
    );
    _restartDialog();
  }

  Future<void> _reset() async {
    await FirebaseConfig.reset();
    _restartDialog();
  }

  void _restartDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تم الحفظ'),
        content: const Text(
            'أُعدّ الإعداد الجديد. أغلق التطبيق وأعد فتحه ليتصل بالمعهد الجديد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _msg(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final currentPid =
        Firebase.apps.isNotEmpty ? Firebase.app().options.projectId : '—';
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات المشرف — ربط معهد')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFFF7ED),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المعهد المتصل حالياً: $currentPid',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(
                      _hasCustom
                          ? '⚙️ يعمل بإعداد مخصص محفوظ.'
                          : '📦 يعمل بالإعداد الافتراضي المضمّن.',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _field(_projectId, 'projectId *'),
          _field(_apiKey, 'apiKey *'),
          _field(_appId, 'appId *'),
          _field(_sender, 'messagingSenderId *'),
          _field(_authDomain, 'authDomain (اختياري)'),
          _field(_bucket, 'storageBucket (اختياري)'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('حفظ وربط المعهد'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restore),
            label: const Text('استعادة الإعداد الافتراضي'),
          ),
          const SizedBox(height: 16),
          const Text(
            'ملاحظة: هذا التبديل يغيّر قاعدة Firestore وقت التشغيل. '
            'إشعارات FCM تبقى مرتبطة بـ google-services.json المُجمَّع مع الـ APK.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          decoration: InputDecoration(labelText: label),
          textDirection: TextDirection.ltr,
        ),
      );

  @override
  void dispose() {
    _projectId.dispose();
    _apiKey.dispose();
    _appId.dispose();
    _sender.dispose();
    _authDomain.dispose();
    _bucket.dispose();
    super.dispose();
  }
}
