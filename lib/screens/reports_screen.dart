import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/attendance.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../utils/fmt.dart';
import '../utils/whatsapp.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _repTab = 'all';
  final _search = TextEditingController();
  String _fTeacher = '';
  String _fClass = '';
  String _fSection = '';
  String _from = '';
  String _to = '';

  List<AttendanceRecord> _filtered(DataProvider p) {
    var list = [...p.attendance];
    final q = _search.text.trim();
    if (q.isNotEmpty) {
      list = list.where((a) => a.studentName.contains(q)).toList();
    }
    if (_fTeacher.isNotEmpty) {
      list = list.where((a) => a.teacherId == _fTeacher).toList();
    }
    if (_fClass.isNotEmpty) {
      list = list.where((a) => a.classId == _fClass).toList();
    }
    if (_fSection.isNotEmpty) {
      list = list.where((a) => a.section == _fSection).toList();
    }
    if (_from.isNotEmpty) {
      list = list.where((a) => a.date.compareTo(_from) >= 0).toList();
    }
    if (_to.isNotEmpty) {
      list = list.where((a) => a.date.compareTo(_to) <= 0).toList();
    }
    if (_repTab == 'present') {
      list = list.where((a) => a.status == 'present').toList();
    } else if (_repTab == 'absent') {
      list = list.where((a) => a.status == 'absent').toList();
    } else if (_repTab == 'excused') {
      list = list.where((a) => a.status == 'excused').toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataProvider>();
    final today = todayStr();
    final tr = p.attendance.where((a) => a.date == today).toList();
    int cnt(String s) => tr.where((a) => a.status == s).length;
    final list = _filtered(p);

    return RefreshIndicator(
      onRefresh: () => p.reloadAttendance(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // لوحة اليوم
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _dash('${cnt('present')}', 'حاضر اليوم', AppColors.ok),
              _dash('${cnt('absent')}', 'غائب اليوم', AppColors.no),
              _dash('${cnt('excused')}', 'مجاز اليوم', AppColors.warn),
              _dash('${tr.length}', 'إجمالي اليوم', AppColors.muted),
            ],
          ),
          const SizedBox(height: 12),
          // تبويبات الفلترة
          Wrap(
            spacing: 6,
            children: [
              _tab('all', '📊 عام'),
              _tab('present', '✅ الحضور'),
              _tab('absent', '❌ الغياب'),
              _tab('excused', '📋 المجازون'),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                        hintText: '🔍 بحث باسم الطالب...'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _fTeacher.isEmpty ? null : _fTeacher,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'المدرس'),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('كل المدرسين')),
                          ...p.teachers.map((t) => DropdownMenuItem(
                              value: t.id, child: Text(t.name))),
                        ],
                        onChanged: (v) =>
                            setState(() => _fTeacher = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _fClass.isEmpty ? null : _fClass,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'الصف'),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('كل الصفوف')),
                          ...p.classes.map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _fClass = v ?? ''),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _dateField('من', _from, (d) => _from = d)),
                    const SizedBox(width: 8),
                    Expanded(child: _dateField('إلى', _to, (d) => _to = d)),
                  ]),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                  child: Text('لا توجد سجلات',
                      style: TextStyle(color: AppColors.muted))),
            )
          else
            ...list.map((a) => _recordTile(a, p.instName)),
        ],
      ),
    );
  }

  Widget _dash(String num, String lbl, Color color) => Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(num,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color)),
              Text(lbl,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
      );

  Widget _tab(String key, String label) {
    final active = _repTab == key;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => setState(() => _repTab = key),
      selectedColor: AppColors.primary,
      labelStyle:
          TextStyle(color: active ? Colors.white : AppColors.muted),
    );
  }

  Widget _dateField(String label, String value, void Function(String) onSet) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(value) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => onSet(dateStr(picked)));
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value.isEmpty ? '—' : value,
            textDirection: TextDirection.ltr),
      ),
    );
  }

  Widget _recordTile(AttendanceRecord a, String instName) {
    Widget badge() {
      switch (a.status) {
        case 'present':
          return _b('✅ حاضر', const Color(0xFFDCFCE7), const Color(0xFF166534));
        case 'absent':
          return _b('❌ غائب', const Color(0xFFFEE2E2), const Color(0xFF991B1B));
        case 'excused':
          return _b('📋 مجاز', const Color(0xFFFEF9C3), const Color(0xFF854D0E));
        default:
          return _b('⏳ غير مكتمل', const Color(0xFFF1F5F9),
              const Color(0xFF475569));
      }
    }

    final canWhatsApp = a.status == 'absent' && a.studentPhone.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.studentName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      'أ. ${a.teacherName} | ${a.className}${a.section.isNotEmpty ? ' | ${a.section}' : ''}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  Text(a.date,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                badge(),
                if (canWhatsApp) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _sendWhatsApp(a, instName),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text('📱 واتساب',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _b(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(t,
            style: TextStyle(
                color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
      );

  Future<void> _sendWhatsApp(AttendanceRecord a, String instName) async {
    final msg = WhatsApp.buildAbsenceMessage(
      studentName: a.studentName,
      className: a.className,
      teacherName: a.teacherName,
      date: a.date,
      instName: instName,
    );
    final uri = WhatsApp.buildUri(phone: a.studentPhone, message: msg);
    if (uri == null) return;
    final ok = await WhatsApp.open(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر فتح واتساب')));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}
