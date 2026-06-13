import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// معالج رسائل الخلفية (يجب أن يكون دالة عُليا top-level).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 FCM background: ${message.messageId}');
}

/// إعداد إشعارات Firebase Cloud Messaging.
///
/// ملاحظة مهمة (multi-institute): FCM مرتبط بـ google-services.json المُجمَّع
/// مع الـ APK. تبديل قاعدة البيانات وقت التشغيل (عبر شاشة المشرف) يبدّل Firestore
/// فقط؛ أما الإشعارات فتبقى على المشروع المُجمَّع. للمعهد الجديد إن لزمت إشعاراته
/// الخاصة، استبدل google-services.json وأعد البناء.
class MessagingService {
  static final FirebaseMessaging _fm = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      await _fm.requestPermission(alert: true, badge: true, sound: true);

      // الاشتراك بموضوع عام لاستقبال إشعارات الإدارة.
      await _fm.subscribeToTopic('teachers');

      final token = await _fm.getToken();
      debugPrint('🔑 FCM token: $token');

      FirebaseMessaging.onMessage.listen((m) {
        debugPrint('📩 FCM foreground: ${m.notification?.title}');
      });
    } catch (e) {
      debugPrint('⚠️ MessagingService.init: $e');
    }
  }

  static Future<String?> token() => _fm.getToken();
}
