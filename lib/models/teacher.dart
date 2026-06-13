class Teacher {
  final String id;
  final String name;
  final String phone;
  final num percent; // نسبته في "جميع المواد"
  final String spec;

  Teacher({
    required this.id,
    required this.name,
    this.phone = '',
    this.percent = 0,
    this.spec = '',
  });

  factory Teacher.fromMap(String id, Map<String, dynamic> m) => Teacher(
        id: id,
        name: (m['name'] ?? '').toString(),
        phone: (m['phone'] ?? '').toString(),
        percent: (m['percent'] is num) ? m['percent'] as num : num.tryParse('${m['percent']}') ?? 0,
        spec: (m['spec'] ?? '').toString(),
      );
}
