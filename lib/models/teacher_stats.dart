/// نتيجة حساب إحصاءات المدرس المالية (مطابقة لـ getTeacherStats في الأصل).
class TeacherStats {
  final String name;
  final num percent; // نسبة "جميع المواد"
  final num totalPaid; // إجمالي المدفوع من طلابه
  final num share; // مبلغ نسبته
  final num withdrawn; // المصروف له
  final num remaining; // الباقي له

  TeacherStats({
    this.name = '',
    this.percent = 0,
    this.totalPaid = 0,
    this.share = 0,
    this.withdrawn = 0,
    this.remaining = 0,
  });
}
