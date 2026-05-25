import 'package:flutter/material.dart';

import '../anniversary/anniversary_page.dart';
import '../growth/growth_page.dart';
import '../timeline/timeline_page.dart';
import 'home_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    TimelinePage(),
    GrowthPage(),
    AnniversaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首页'),
          NavigationDestination(icon: Icon(Icons.timeline), label: '时间轴'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: '成长'),
          NavigationDestination(icon: Icon(Icons.event), label: '纪念日'),
        ],
      ),
    );
  }
}
