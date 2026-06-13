class Receipt {
  final String id;
  final String studentId;
  final num amount;
  final String date;

  Receipt({
    required this.id,
    this.studentId = '',
    this.amount = 0,
    this.date = '',
  });

  static num _n(dynamic v) => (v is num) ? v : num.tryParse('${v ?? ''}') ?? 0;

  factory Receipt.fromMap(String id, Map<String, dynamic> m) => Receipt(
        id: id,
        studentId: (m['studentId'] ?? '').toString(),
        amount: _n(m['amount']),
        date: (m['date'] ?? '').toString(),
      );
}

class TeacherPay {
  final String id;
  final String teacherId;
  final num amount;
  final String date;

  TeacherPay({
    required this.id,
    this.teacherId = '',
    this.amount = 0,
    this.date = '',
  });

  static num _n(dynamic v) => (v is num) ? v : num.tryParse('${v ?? ''}') ?? 0;

  factory TeacherPay.fromMap(String id, Map<String, dynamic> m) => TeacherPay(
        id: id,
        teacherId: (m['teacherId'] ?? '').toString(),
        amount: _n(m['amount']),
        date: (m['date'] ?? '').toString(),
      );
}
