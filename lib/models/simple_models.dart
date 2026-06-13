/// نماذج بسيطة: الصفوف، الشعب، رموز المدرسين.

class ClassModel {
  final String id;
  final String name;
  ClassModel({required this.id, required this.name});
  factory ClassModel.fromMap(String id, Map<String, dynamic> m) =>
      ClassModel(id: id, name: (m['name'] ?? '').toString());
}

class SectionModel {
  final String id;
  final String name;
  SectionModel({required this.id, required this.name});
  factory SectionModel.fromMap(String id, Map<String, dynamic> m) =>
      SectionModel(id: id, name: (m['name'] ?? '').toString());
}

class TeacherCode {
  final String id;
  final String teacherId;
  final String code;
  TeacherCode({required this.id, required this.teacherId, required this.code});
  factory TeacherCode.fromMap(String id, Map<String, dynamic> m) => TeacherCode(
        id: id,
        teacherId: (m['teacherId'] ?? '').toString(),
        code: (m['code'] ?? '').toString().trim(),
      );
}
