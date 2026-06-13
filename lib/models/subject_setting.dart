class SubjectSetting {
  final String id;
  final String subject; // اسم المادة
  final String teacherId; // المدرس الأساسي
  final String teacherName;
  final num price;
  final num teacherPct; // نسبة المدرس الأساسي
  final num instPct; // نسبة الطرف الثاني (مدرس آخر أو المعهد)
  final String secondId; // معرّف الطرف الثاني أو 'inst'
  final String secondName;

  SubjectSetting({
    required this.id,
    this.subject = '',
    this.teacherId = '',
    this.teacherName = '',
    this.price = 0,
    this.teacherPct = 0,
    this.instPct = 0,
    this.secondId = 'inst',
    this.secondName = '',
  });

  static num _n(dynamic v) => (v is num) ? v : num.tryParse('${v ?? ''}') ?? 0;

  factory SubjectSetting.fromMap(String id, Map<String, dynamic> m) =>
      SubjectSetting(
        id: id,
        subject: (m['subject'] ?? '').toString(),
        teacherId: (m['teacherId'] ?? '').toString(),
        teacherName: (m['teacherName'] ?? '').toString(),
        price: _n(m['price']),
        teacherPct: _n(m['teacherPct']),
        instPct: _n(m['instPct']),
        secondId: (m['secondId'] ?? 'inst').toString(),
        secondName: (m['secondName'] ?? '').toString(),
      );
}
