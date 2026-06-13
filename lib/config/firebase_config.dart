import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ════════════════════════════════════════════════════════════
///  إعدادات Firebase متعددة المعاهد (Multi-Institute)
///  ------------------------------------------------------------
///  مصدر الإعداد بالأولوية:
///   1) إعداد محفوظ محلياً عبر شاشة المشرف (SharedPreferences).
///   2) الإعداد الافتراضي المضمّن أدناه (المعهد الحالي: mahad-5e879).
///
///  لربط معهد جديد دون تعديل الكود: افتح "شاشة إعدادات المشرف"
///  وأدخل بيانات مشروع Firebase الجديد، ثم أعد تشغيل التطبيق.
/// ════════════════════════════════════════════════════════════
class FirebaseConfig {
  static const String _prefsKey = 'fb_config_v1';

  /// الإعداد الافتراضي — مطابق للملف الأصلي (mahad-5e879).
  /// عند بناء نسخة لمعهد مختلف، يكفي تغيير هذه القيم أو استخدام شاشة المشرف.
  static const FirebaseOptions defaultOptions = FirebaseOptions(
    apiKey: 'AIzaSyDlzFSrs2sBVfAjriPC7RqyzRVT5SDPJpM',
    appId: '1:1066657295285:web:3b741fba4764affce287fc',
    messagingSenderId: '1066657295285',
    projectId: 'mahad-5e879',
    authDomain: 'mahad-5e879.firebaseapp.com',
    storageBucket: 'mahad-5e879.firebasestorage.app',
  );

  /// يقرأ الإعداد الفعّال (المحفوظ محلياً إن وُجد، وإلا الافتراضي).
  static Future<FirebaseOptions> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return defaultOptions;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return FirebaseOptions(
        apiKey: m['apiKey'] ?? defaultOptions.apiKey,
        appId: m['appId'] ?? defaultOptions.appId,
        messagingSenderId:
            m['messagingSenderId'] ?? defaultOptions.messagingSenderId,
        projectId: m['projectId'] ?? defaultOptions.projectId,
        authDomain: m['authDomain'],
        storageBucket: m['storageBucket'],
      );
    } catch (_) {
      return defaultOptions;
    }
  }

  /// يحفظ إعداد معهد جديد (من شاشة المشرف).
  static Future<void> save({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    String? authDomain,
    String? storageBucket,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'apiKey': apiKey,
        'appId': appId,
        'messagingSenderId': messagingSenderId,
        'projectId': projectId,
        'authDomain': authDomain ?? '$projectId.firebaseapp.com',
        'storageBucket': storageBucket ?? '$projectId.firebasestorage.app',
      }),
    );
  }

  /// يعيد الإعداد إلى الافتراضي (حذف إعداد المعهد المخصص).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// هل يوجد إعداد مخصص محفوظ؟
  static Future<bool> hasCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    return raw != null && raw.isNotEmpty;
  }
}
