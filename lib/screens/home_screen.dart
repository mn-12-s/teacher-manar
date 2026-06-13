import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'attendance_screen.dart';
import 'reports_screen.dart';
import 'shares_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    AttendanceScreen(),
    ReportsScreen(),
    SharesScreen(),
  ];

  Future<void> _logout() async {
    await context.read<DataProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataProvider>();
    final tName = p.currentTeacher?.name ?? '';
    final tSpec = p.currentTeacher?.spec ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أ. $tName',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 16)),
            if (tSpec.isNotEmpty)
              Text(tSpec,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          // شريط اسم المعهد + خروج
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(p.instName,
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'الحضور'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'التقارير'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'النسب'),
        ],
      ),
    );
  }
}
