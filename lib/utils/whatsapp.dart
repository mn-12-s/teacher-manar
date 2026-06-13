import 'package:url_launcher/url_launcher.dart';

/// فتح واتساب لإرسال رسالة غياب لولي الأمر — مطابق لمنطق الأصل:
/// https://wa.me/964<phone بعد إزالة الصفر البادئ>?text=...
class WhatsApp {
  static String buildAbsenceMessage({
    required String studentName,
    required String className,
    required String teacherName,
    required String date,
    required String instName,
  }) {
    return 'السيد ولي امر الطالب المحترم...\n'
        'نود اعلامكم بغياب الطالب/ة ($studentName) في الصف ($className) '
        'عن محاضرة الأستاذ ($teacherName) بتاريخ ($date) '
        'للتفضل بالاطلاع ومتابعة الامر شاكرين تعاونكم معنا ($instName)';
  }

  /// يبني رابط wa.me. يُرجع null إذا لا يوجد رقم صالح.
  static Uri? buildUri({required String phone, required String message}) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final local = digits.replaceFirst(RegExp(r'^0'), '');
    return Uri.parse(
        'https://wa.me/964$local?text=${Uri.encodeComponent(message)}');
  }

  static Future<bool> open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
