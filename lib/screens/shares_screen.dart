import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../utils/fmt.dart';

class SharesScreen extends StatelessWidget {
  const SharesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataProvider>();
    final t = p.currentTeacher;
    if (t == null) {
      return const Center(child: Text('سجّل الدخول أولاً'));
    }
    final st = p.statsFor(t.id);
    final count = p.studentCountFor(t.id);
    final priv = p.privateSubjectsFor(t.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('أ. ${t.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppColors.primary)),
                if (t.spec.isNotEmpty)
                  Text(t.spec,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _dash('$count', 'عدد الطلاب', AppColors.primaryLight),
            _dash(fmt(st?.totalPaid), 'إجمالي المدفوع', AppColors.ok),
            _dash(fmt(st?.share), 'مبلغ نسبته', AppColors.ok),
            _dash(fmt(st?.withdrawn), 'المصروف له', AppColors.no),
          ],
        ),
        const SizedBox(height: 10),
        // الباقي له (بطاقة بارزة)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(fmt(st?.remaining),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              const Text('الباقي له',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('📊 النِّسَب',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                _kv('نسبته في جميع المواد', '${t.percent}%'),
                const Divider(),
                const Text('نسبته في المواد المحددة:',
                    style: TextStyle(
                        color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 6),
                if (priv.isEmpty)
                  const Text('لا توجد مواد محددة',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 13))
                else
                  ...priv.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${e.subject}${e.isSecond ? ' (طرف ثانٍ)' : ''}'),
                            Text('${e.pct}%',
                                style: const TextStyle(
                                    color: AppColors.ok,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dash(String num, String lbl, Color color) => Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(num,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color)),
              Text(lbl,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k),
            Text(v,
                style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
