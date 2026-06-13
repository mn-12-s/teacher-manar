class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String studentPhone;
  final String classId;
  final String className;
  final String section;
  final String teacherId;
  final String teacherName;
  final String date; // yyyy-MM-dd
  final String status; // present | absent | excused
  final String submittedBy;
  final String submittedAt;

  AttendanceRecord({
    required this.id,
    this.studentId = '',
    this.studentName = '',
    this.studentPhone = '',
    this.classId = '',
    this.className = '',
    this.section = '',
    this.teacherId = '',
    this.teacherName = '',
    this.date = '',
    this.status = 'present',
    this.submittedBy = '',
    this.submittedAt = '',
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> m) =>
      AttendanceRecord(
        id: id,
        studentId: (m['studentId'] ?? '').toString(),
        studentName: (m['studentName'] ?? '').toString(),
        studentPhone: (m['studentPhone'] ?? '').toString(),
        classId: (m['classId'] ?? '').toString(),
        className: (m['className'] ?? '').toString(),
        section: (m['section'] ?? '').toString(),
        teacherId: (m['teacherId'] ?? '').toString(),
        teacherName: (m['teacherName'] ?? '').toString(),
        date: (m['date'] ?? '').toString(),
        status: (m['status'] ?? 'present').toString(),
        submittedBy: (m['submittedBy'] ?? '').toString(),
        submittedAt: (m['submittedAt'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'studentName': studentName,
        'studentPhone': studentPhone,
        'classId': classId,
        'className': className,
        'section': section,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'date': date,
        'status': status,
        'submittedBy': submittedBy,
        'submittedAt': submittedAt,
      };

  AttendanceRecord copyWith({String? status, String? submittedAt, String? id}) =>
      AttendanceRecord(
        id: id ?? this.id,
        studentId: studentId,
        studentName: studentName,
        studentPhone: studentPhone,
        classId: classId,
        className: className,
        section: section,
        teacherId: teacherId,
        teacherName: teacherName,
        date: date,
        status: status ?? this.status,
        submittedBy: submittedBy,
        submittedAt: submittedAt ?? this.submittedAt,
      );
}
