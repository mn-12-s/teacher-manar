class Student {
  final String id;
  final String name;
  final String classId;
  final String className;
  final String section;
  final String phone;
  final String address;
  final String prevSchool;
  final String studyType; // 'gold' | 'private'
  final bool deleted;

  /// خريطة المواد {"0".."7"} → معرّف المدرس (gold) أو معرّف سجل subject_settings (private).
  final Map<String, dynamic> subjects;

  Student({
    required this.id,
    required this.name,
    this.classId = '',
    this.className = '',
    this.section = '',
    this.phone = '',
    this.address = '',
    this.prevSchool = '',
    this.studyType = 'gold',
    this.deleted = false,
    this.subjects = const {},
  });

  /// قيم المواد غير الفارغة (مثل Object.values(s.subjects).filter(Boolean) في الأصل).
  List<String> get subjectValues => subjects.values
      .where((v) => v != null && v.toString().isNotEmpty)
      .map((v) => v.toString())
      .toList();

  factory Student.fromMap(String id, Map<String, dynamic> m) {
    final rawSubjects = m['subjects'];
    final subjects = <String, dynamic>{};
    if (rawSubjects is Map) {
      rawSubjects.forEach((k, v) => subjects[k.toString()] = v);
    }
    return Student(
      id: id,
      name: (m['name'] ?? '').toString(),
      classId: (m['classId'] ?? '').toString(),
      className: (m['className'] ?? '').toString(),
      section: (m['section'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      address: (m['address'] ?? '').toString(),
      prevSchool: (m['prevSchool'] ?? '').toString(),
      studyType: (m['studyType'] ?? 'gold').toString(),
      deleted: m['deleted'] == true,
      subjects: subjects,
    );
  }
}
