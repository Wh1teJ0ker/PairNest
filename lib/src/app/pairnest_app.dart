import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCF6A74),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansScTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8F3EE),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF312126),
          titleTextStyle: GoogleFonts.notoSansSc(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF312126),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFFDF8F4),
          shadowColor: Color(0x2AAE9A90),
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            side: BorderSide(color: Color(0xFFF0E6DD)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: const Color(0xFFFFF8F5),
          indicatorColor: const Color(0xFFF7D9DE),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.notoSansSc(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF8A3445)
                  : const Color(0xFF7B6A66),
            );
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE87C8A),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            foregroundColor: const Color(0xFF7D4453),
            side: const BorderSide(color: Color(0xFFE4C5CD)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFBF8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE9DDD5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE9DDD5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE26E81), width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          labelStyle: const TextStyle(color: Color(0xFF786965)),
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
