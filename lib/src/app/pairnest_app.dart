import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/bonding/bonding_page.dart';
import '../features/home/home_shell.dart';
import 'providers.dart';

class PairNestApp extends ConsumerWidget {
  const PairNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return MaterialApp(
      title: 'PairNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB78D8D),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F3F0),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: profile.when(
        data: (value) =>
            value == null ? const BondingPage() : const HomeShell(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) =>
            Scaffold(body: Center(child: Text('启动失败: $error'))),
      ),
    );
  }
}
