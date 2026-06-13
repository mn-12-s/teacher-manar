import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/teacher.dart';
import '../models/student.dart';
import '../models/simple_models.dart';
import '../models/subject_setting.dart';
import '../models/receipt.dart';
import '../models/attendance.dart';
import '../models/teacher_stats.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../logic/share_logic.dart';
import '../utils/fmt.dart';

/// مزوّد الحالة الرئيسي — يحمّل البيانات، يدير الدخول، ويسجّل الحضور.
class DataProvider extends ChangeNotifier {
  FirestoreService? _fs;

  bool loading = false;
  bool loaded = false;
  String? error;

  List<Teacher> teachers = [];
  List<Student> students = [];
  List<ClassModel> classes = [];
  List<SectionModel> sections = [];
  List<TeacherCode> codes = [];
  List<SubjectSetting> subjectSettings = [];
  List<Receipt> receipts = [];
  List<TeacherPay> teacherPays = [];
  List<AttendanceRecord> attendance = [];
  String instName = 'المعهد';

  Teacher? currentTeacher;
  bool get isLoggedIn => currentTeacher != null;

  void attachFirestore(FirebaseFirestore db) {
    _fs = FirestoreService(db);
  }

  // ── تحميل كل البيانات ───────────────────────────────
  Future<void> loadAll() async {
    if (_fs == null) {
      error = 'لم تتم تهيئة قاعدة البيانات';
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _fs!.getAll('teachers'),
        _fs!.getAll('students'),
        _fs!.getAll('classes'),
        _fs!.getAll('sections'),
        _fs!.getAll('teacherCodes'),
        _fs!.getAll('settings'),
        _fs!.getAll('receipts'),
        _fs!.getAll('teacherPays'),
        _fs!.getAll('subject_settings'),
        _fs!.getAll('attendance'),
      ]);

      teachers = results[0].map((e) => Teacher.fromMap(e.id, e.data)).toList();
      students = results[1]
          .map((e) => Student.fromMap(e.id, e.data))
          .where((s) => !s.deleted)
          .toList();
      classes = results[2].map((e) => ClassModel.fromMap(e.id, e.data)).toList();
      sections =
          results[3].map((e) => SectionModel.fromMap(e.id, e.data)).toList();
      codes = results[4].map((e) => TeacherCode.fromMap(e.id, e.data)).toList();

      final settings = results[5];
      final instRec =
          settings.where((e) => e.data['key'] == 'instName').firstOrNull;
      instName = (instRec?.data['value'] ?? 'المعهد').toString();

      receipts = results[6].map((e) => Receipt.fromMap(e.id, e.data)).toList();
      teacherPays =
          results[7].map((e) => TeacherPay.fromMap(e.id, e.data)).toList();
      subjectSettings =
          results[8].map((e) => SubjectSetting.fromMap(e.id, e.data)).toList();
      attendance = results[9]
          .map((e) => AttendanceRecord.fromMap(e.id, e.data))
          .toList();

      loaded = true;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ── تسجيل الدخول (teacherCodes) ─────────────────────
  String _norm(String v) => v.trim();

  /// يعيد رسالة خطأ أو null عند النجاح.
  Future<String?> login(String code) async {
    final c = _norm(code);
    if (c.isEmpty) return 'يرجى إدخال الرمز';
    if (!loaded) await loadAll();
    final entry =
        codes.where((x) => _norm(x.code) == c).firstOrNull;
    if (entry == null) {
      return 'الرمز غير صحيح (المتاح: ${codes.length})';
    }
    final tc = teachers.where((t) => t.id == entry.teacherId).firstOrNull;
    if (tc == null) return 'المدرس غير موجود';
    currentTeacher = tc;
    await AuthService.saveSession(tc.id);
    notifyListeners();
    return null;
  }

  /// محاولة دخول تلقائي من الجلسة المحفوظة.
  Future<bool> tryAutoLogin() async {
    final id = await AuthService.savedTeacherId();
    if (id == null) return false;
    if (!loaded) await loadAll();
    final tc = teachers.where((t) => t.id == id).firstOrNull;
    if (tc == null) return false;
    currentTeacher = tc;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await AuthService.clear();
    currentTeacher = null;
    notifyListeners();
  }

  // ── الحضور ──────────────────────────────────────────
  Future<void> reloadAttendance() async {
    if (_fs == null) return;
    final res = await _fs!.getAll('attendance');
    attendance =
        res.map((e) => AttendanceRecord.fromMap(e.id, e.data)).toList();
    notifyListeners();
  }

  /// طلاب صف معيّن ينتمون لمدرس معيّن (يعالج النظامين).
  List<Student> studentsFor(String classId, String teacherId, {String section = ''}) {
    var list = students
        .where((s) =>
            s.classId == classId &&
            studentHasTeacher(s, teacherId, subjectSettings))
        .toList();
    if (section.isNotEmpty) {
      list = list.where((s) => s.section == section).toList();
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// معرّفات المدرّسين الفعليين الموجودين في صف (للنظامين).
  Set<String> teacherIdsInClass(String classId) {
    final ids = <String>{};
    for (final s in students.where((s) => s.classId == classId)) {
      if (s.studyType == 'private') {
        for (final val in s.subjectValues) {
          final ss = subjectSettings.where((x) => x.id == val).firstOrNull;
          if (ss != null) {
            if (ss.teacherId.isNotEmpty) ids.add(ss.teacherId);
            if (ss.secondId.isNotEmpty && ss.secondId != 'inst') {
              ids.add(ss.secondId);
            }
          } else {
            ids.add(val); // مدرس المدرسة / توافق خلفي
          }
        }
      } else {
        ids.addAll(s.subjectValues);
      }
    }
    return ids;
  }

  /// الشعب الموجودة في صف.
  List<String> sectionsInClass(String classId) {
    final s = students
        .where((x) => x.classId == classId && x.section.isNotEmpty)
        .map((x) => x.section)
        .toSet()
        .toList();
    return s;
  }

  AttendanceRecord? existingRecord(
          String studentId, String teacherId, String classId, String date) =>
      attendance
          .where((a) =>
              a.studentId == studentId &&
              a.teacherId == teacherId &&
              a.classId == classId &&
              a.date == date)
          .firstOrNull;

  /// إرسال/تحديث حضور — يعيد عدد السجلات المعالجة.
  Future<int> submitAttendance({
    required String classId,
    required String teacherId,
    required String date,
    required Map<String, String> statuses, // studentId -> status
  }) async {
    if (_fs == null) return 0;
    final tc = teachers.where((t) => t.id == teacherId).firstOrNull;
    final cls = classes.where((c) => c.id == classId).firstOrNull;
    int count = 0;
    for (final entry in statuses.entries) {
      final sid = entry.key;
      final status = entry.value;
      final s = students.where((x) => x.id == sid).firstOrNull;
      final now = DateTime.now().toIso8601String();
      final ex = existingRecord(sid, teacherId, classId, date);
      if (ex != null) {
        await _fs!.update('attendance', ex.id, {
          'status': status,
          'submittedAt': now,
        });
        attendance = attendance
            .map((a) => a.id == ex.id
                ? a.copyWith(status: status, submittedAt: now)
                : a)
            .toList();
      } else {
        final rec = AttendanceRecord(
          id: '',
          studentId: sid,
          studentName: s?.name ?? '',
          studentPhone: s?.phone ?? '',
          classId: classId,
          className: cls?.name ?? '',
          section: s?.section ?? '',
          teacherId: teacherId,
          teacherName: tc?.name ?? '',
          date: date,
          status: status,
          submittedBy: currentTeacher?.name ?? '',
          submittedAt: now,
        );
        final id = await _fs!.add('attendance', rec.toMap());
        attendance.add(rec.copyWith(id: id));
      }
      count++;
    }
    notifyListeners();
    return count;
  }

  // ── نِسَب المدرس الحالي ──────────────────────────────
  TeacherStats? statsFor(String teacherId) => getTeacherStats(
        teacherId,
        teachers: teachers,
        students: students,
        receipts: receipts,
        teacherPays: teacherPays,
        subjectSettings: subjectSettings,
      );

  int studentCountFor(String teacherId) => students
      .where((s) => studentHasTeacher(s, teacherId, subjectSettings))
      .length;

  /// مواد المدرس المحددة ونسبته فيها.
  List<({String subject, num pct, bool isSecond})> privateSubjectsFor(
      String teacherId) {
    return subjectSettings
        .where((ss) => ss.teacherId == teacherId || ss.secondId == teacherId)
        .map((ss) {
      final isPrimary = ss.teacherId == teacherId;
      return (
        subject: ss.subject,
        pct: isPrimary ? ss.teacherPct : ss.instPct,
        isSecond: !isPrimary,
      );
    }).toList();
  }

  String money(num? n) => fmt(n);
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
