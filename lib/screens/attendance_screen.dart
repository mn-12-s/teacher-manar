import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../models/teacher.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../utils/fmt.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _classId;
  String? _teacherId;
  String _section = '';
  String _date = todayStr();
  final Map<String, String> _statuses = {}; // studentId -> status
  bool _busy = false;

  static const _statusLabels = {
    'present': '✅ حاضر',
    'absent': '❌ غائب',
    'excused': '📋 مجاز',
  };

  List<Teacher> _teachersInClass(DataProvider p) {
    if (_classId == null) return [];
    final ids = p.teacherIdsInClass(_classId!);
    return p.teachers.where((t) => ids.contains(t.id)).toList();
  }

  List<Student> _list(DataProvider p) {
    if (_classId == null || _teacherId == null) return [];
    return p.studentsFor(_classId!, _teacherId!, section: _section);
  }

  void _initStatuses(DataProvider p) {
    _statuses.clear();
    for (final s in _list(p)) {
      final ex =
          p.existingRecord(s.id, _teacherId!, _classId!, _date);
      _statuses[s.id] = ex?.status ?? 'present';
    }
  }

  Future<void> _submit() async {
    final p = context.read<DataProvider>();
    if (_classId == null || _teacherId == null) return;
    setState(() => _busy = true);
    try {
      final n = await p.submitAttendance(
        classId: _classId!,
        teacherId: _teacherId!,
        date: _date,
        statuses: Map.of(_statuses),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم إرسال حضور $n طالب')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataProvider>();
    final teachers = _teachersInClass(p);
    final list = _list(p);
    final hasExisting = list.isNotEmpty &&
        list.any((s) =>
            p.existingRecord(s.id, _teacherId ?? '', _classId ?? '', _date) !=
            null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // الصف
                  DropdownButtonFormField<String>(
                    value: _classId,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: '📚 الصف'),
                    items: p.classes
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _classId = v;
                        _teacherId = null;
                        _section = '';
                        // تحديد المدرس الحالي تلقائياً إن كان ضمن الصف.
                        final ids = v == null
                            ? <String>{}
                            : p.teacherIdsInClass(v);
                        final me = p.currentTeacher?.id;
                        if (me != null && ids.contains(me)) {
                          _teacherId = me;
                          _initStatuses(p);
                        }
                        _statuses.clear();
                        if (_teacherId != null) _initStatuses(p);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // المدرس
                  DropdownButtonFormField<String>(
                    value: _teacherId,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: '👤 المدرس'),
                    items: teachers
                        .map((t) => DropdownMenuItem(
                            value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: _classId == null
                        ? null
                        : (v) => setState(() {
                              _teacherId = v;
                              _section = '';
                              if (v != null) _initStatuses(p);
                            }),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _section.isEmpty ? null : _section,
                          isExpanded: true,
                          decoration: const InputDecoration(
                              labelText: '🏫 الشعبة'),
                          items: [
                            const DropdownMenuItem(
                                value: '', child: Text('كل الشعب')),
                            if (_classId != null)
                              ...p
                                  .sectionsInClass(_classId!)
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s))),
                          ],
                          onChanged: (v) => setState(() {
                            _section = v ?? '';
                            if (_teacherId != null) _initStatuses(p);
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.tryParse(_date) ??
                                  DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _date = dateStr(picked);
                                if (_teacherId != null) _initStatuses(p);
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: '📅 التاريخ'),
                            child: Text(_date,
                                textDirection: TextDirection.ltr),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                    child: Text('اختر الصف والمدرس لعرض الطلاب',
                        style: TextStyle(color: AppColors.muted))),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    for (int i = 0; i < list.length; i++)
                      _row(i + 1, list[i]),
                  ],
                ),
              ),
            ),
          if (list.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ok),
                child: Text(_busy
                    ? '⏳ جاري الإرسال...'
                    : '${hasExisting ? '🔄 تحديث' : '✅ إرسال'} الحضور (${list.length} طالب)'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(int n, Student s) {
    final status = _statuses[s.id] ?? 'present';
    Color c() {
      switch (status) {
        case 'absent':
          return AppColors.no;
        case 'excused':
          return AppColors.warn;
        default:
          return AppColors.ok;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryLight,
            child: Text('$n',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (s.section.isNotEmpty)
                  Text('الشعبة: ${s.section}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: c(), width: 1.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: status,
              underline: const SizedBox.shrink(),
              style: TextStyle(color: c(), fontWeight: FontWeight.w700),
              items: _statusLabels.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _statuses[s.id] = v ?? 'present'),
            ),
          ),
        ],
      ),
    );
  }
}
