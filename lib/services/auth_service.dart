import 'package:shared_preferences/shared_preferences.dart';

/// حفظ/استرجاع حالة تسجيل دخول المدرس (نظام teacherCodes — بدون Firebase Auth).
class AuthService {
  static const _kTeacherId = 'logged_teacher_id';

  /// حفظ معرّف المدرس بعد نجاح الدخول.
  static Future<void> saveSession(String teacherId) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTeacherId, teacherId);
  }

  /// معرّف المدرس المحفوظ (أو null).
  static Future<String?> savedTeacherId() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString(_kTeacherId);
    return (id != null && id.isNotEmpty) ? id : null;
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kTeacherId);
  }
}
