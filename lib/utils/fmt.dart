import 'package:intl/intl.dart';

/// تنسيق الأرقام بفواصل آلاف (مطابق لـ fmt في الأصل: en-US).
final NumberFormat _nf = NumberFormat('#,##0', 'en_US');

String fmt(num? n) {
  final v = n ?? 0;
  if (v == 0) return '0';
  return _nf.format(v);
}

String todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

String dateStr(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
