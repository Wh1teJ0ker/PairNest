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
    final isCompact = MediaQuery.of(context).size.width < 380;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.035, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
      ),
      bottomNavigationBar: NavigationBar(
        height: isCompact ? 64 : 72,
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_filled),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_rounded),
            selectedIcon: Icon(Icons.auto_stories),
            label: '时间轴',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_rounded),
            selectedIcon: Icon(Icons.self_improvement),
            label: '成长',
          ),
          NavigationDestination(
            icon: Icon(Icons.celebration_outlined),
            selectedIcon: Icon(Icons.celebration),
            label: '纪念日',
          ),
        ],
      ),
    );
  }
}
