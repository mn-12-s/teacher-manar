import '../models/student.dart';
import '../models/teacher.dart';
import '../models/subject_setting.dart';
import '../models/receipt.dart';
import '../models/teacher_stats.dart';

/// ════════════════════════════════════════════════════════════
///  منطق نِسَب المدرسين — منقول حرفياً من لوحة الإدارة
///  (studentHasTeacher / distributePrivatePayment / getTeacherStats)
///  يدعم نظامي التوزيع: "جميع المواد" (gold) و"مواد محددة" (private).
/// ════════════════════════════════════════════════════════════

const List<String> kSlabs = [
  'الإسلامية',
  'العربي',
  'الإنكليزي',
  'الرياضيات',
  'الأحياء',
  'الفيزياء',
  'الكيمياء',
  'المدرسة',
];

/// هل ينتمي الطالب لهذا المدرس؟ (يعالج gold و private).
bool studentHasTeacher(
  Student s,
  String tid,
  List<SubjectSetting> subjectSettings,
) {
  if (tid.isEmpty) return true;
  if (s.studyType == 'private') {
    return s.subjectValues.any((val) {
      SubjectSetting? ss =
          subjectSettings.where((x) => x.id == val).firstOrNull;
      if (ss == null) return val == tid; // توافق خلفي / مدرس المدرسة
      return ss.teacherId == tid || ss.secondId == tid;
    });
  }
  return s.subjectValues.contains(tid);
}

/// توزيع المبلغ المدفوع في نظام "المواد المحددة" (الأوزان النسبية).
/// يعيد {teachers:{tid:amount}, institute:amount} أو null.
Map<String, dynamic>? distributePrivatePayment(
  Student s,
  num amount,
  List<SubjectSetting> subjectSettings,
) {
  final subjects = <_PrivSub>[];
  s.subjects.forEach((idxStr, val) {
    final idx = int.tryParse(idxStr) ?? -1;
    if (val == null || val.toString().isEmpty || idx >= 7 || idx < 0) return;
    final v = val.toString();
    final subjectName = (idx < kSlabs.length) ? kSlabs[idx] : '';

    SubjectSetting? ss = subjectSettings.where((x) => x.id == v).firstOrNull;
    ss ??= subjectSettings
        .where((x) => x.subject == subjectName && x.teacherId == v)
        .firstOrNull;
    ss ??= subjectSettings.where((x) => x.subject == subjectName).firstOrNull;
    if (ss == null) return;

    subjects.add(_PrivSub(
      teacherId: ss.teacherId,
      price: ss.price,
      teacherPct: ss.teacherPct,
      instPct: ss.instPct,
      secondId: ss.secondId.isEmpty ? 'inst' : ss.secondId,
    ));
  });

  if (subjects.isEmpty) return null;
  final totalPrice = subjects.fold<num>(0, (a, x) => a + x.price);
  if (totalPrice == 0) return null;

  final teachersShare = <String, num>{};
  num institute = 0;
  num allocated = 0;

  for (final sub in subjects) {
    final subjectPaid = (sub.price / totalPrice) * amount;
    final teacherShare = (subjectPaid * sub.teacherPct / 100).round();
    final secondShare = (subjectPaid * sub.instPct / 100).round();

    teachersShare[sub.teacherId] =
        (teachersShare[sub.teacherId] ?? 0) + teacherShare;

    if (sub.secondId != 'inst') {
      teachersShare[sub.secondId] =
          (teachersShare[sub.secondId] ?? 0) + secondShare;
    } else {
      institute += secondShare;
    }
    allocated += teacherShare + secondShare;
  }
  institute += (amount - allocated);
  return {'teachers': teachersShare, 'institute': institute};
}

/// إحصاءات المدرس المالية الكاملة.
TeacherStats? getTeacherStats(
  String tid, {
  required List<Teacher> teachers,
  required List<Student> students,
  required List<Receipt> receipts,
  required List<TeacherPay> teacherPays,
  required List<SubjectSetting> subjectSettings,
}) {
  final t = teachers.where((x) => x.id == tid).firstOrNull;
  if (t == null) return null;

  num share = 0;
  num totalPaid = 0;

  for (final s in students.where((s) => !s.deleted)) {
    final paid = receipts
        .where((r) => r.studentId == s.id)
        .fold<num>(0, (a, r) => a + r.amount);
    if (paid <= 0) continue;

    if (s.studyType == 'private') {
      final dist = distributePrivatePayment(s, paid, subjectSettings);
      final myShare =
          (dist?['teachers'] as Map<String, num>?)?[tid] ?? 0;
      if (myShare > 0) {
        share += myShare;
        totalPaid += paid;
      }
    } else {
      if (s.subjectValues.contains(tid)) {
        share += (paid * t.percent / 100).round();
        totalPaid += paid;
      }
    }
  }

  final withdrawn = teacherPays
      .where((p) => p.teacherId == tid)
      .fold<num>(0, (a, p) => a + p.amount);
  final remaining = (share - withdrawn) < 0 ? 0 : (share - withdrawn);

  return TeacherStats(
    name: t.name,
    percent: t.percent,
    totalPaid: totalPaid,
    share: share,
    withdrawn: withdrawn,
    remaining: remaining,
  );
}

class _PrivSub {
  final String teacherId;
  final num price;
  final num teacherPct;
  final num instPct;
  final String secondId;
  _PrivSub({
    required this.teacherId,
    required this.price,
    required this.teacherPct,
    required this.instPct,
    required this.secondId,
  });
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
