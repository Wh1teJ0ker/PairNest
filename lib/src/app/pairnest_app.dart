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
    final baseTheme = ThemeData.light(useMaterial3: true);
    final textTheme = baseTheme.textTheme;
    const ivory = Color(0xFFF5F0E9);
    const paper = Color(0xFFFDFBF7);
    const ink = Color(0xFF181413);
    const muted = Color(0xFF655C57);
    const bronze = Color(0xFF9B6A43);
    const graphite = Color(0xFF272120);
    const outline = Color(0xFFE4D9CD);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: bronze,
          brightness: Brightness.light,
          primary: graphite,
          onPrimary: Colors.white,
          secondary: bronze,
          onSecondary: Colors.white,
          surface: paper,
          onSurface: ink,
          error: const Color(0xFFB04B42),
          onError: Colors.white,
          outline: outline,
        ).copyWith(
          surfaceContainerHighest: const Color(0xFFF2E8DD),
          surfaceContainerHigh: const Color(0xFFF7F0E7),
          surfaceContainerLow: const Color(0xFFFFFCF8),
          onSurfaceVariant: muted,
        );

    return MaterialApp(
      title: 'PairNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'sans-serif',
        textTheme: textTheme.copyWith(
          headlineLarge: textTheme.headlineLarge?.copyWith(
            color: ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.3,
          ),
          headlineMedium: textTheme.headlineMedium?.copyWith(
            color: ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
          ),
          headlineSmall: textTheme.headlineSmall?.copyWith(
            color: ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
          titleLarge: textTheme.titleLarge?.copyWith(
            color: ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          titleMedium: textTheme.titleMedium?.copyWith(
            color: ink,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          bodyLarge: textTheme.bodyLarge?.copyWith(color: ink, height: 1.48),
          bodyMedium: textTheme.bodyMedium?.copyWith(
            color: muted,
            height: 1.52,
          ),
          labelLarge: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
          labelMedium: textTheme.labelMedium?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.12,
          ),
        ),
        scaffoldBackgroundColor: ivory,
        dividerColor: outline,
        splashFactory: NoSplash.splashFactory,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: graphite,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: ink,
          scrolledUnderElevation: 0,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -0.7,
          ),
        ),
        cardTheme: const CardThemeData(
          color: paper,
          shadowColor: Color(0x100F0B08),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(26)),
            side: BorderSide(color: outline),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 76,
          backgroundColor: paper.withValues(alpha: 0.96),
          indicatorColor: const Color(0xFF2D2726),
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x120F0B08),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected ? Colors.white : muted,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? graphite : muted,
            );
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: graphite,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE4DDD4),
            disabledForegroundColor: const Color(0xFF92857C),
            minimumSize: const Size.fromHeight(50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: graphite,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: graphite,
            side: const BorderSide(color: outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF1EBE2),
          disabledColor: const Color(0xFFE8E1D7),
          selectedColor: const Color(0xFFE4D6C7),
          secondarySelectedColor: const Color(0xFFE4D6C7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          labelStyle:
              textTheme.labelMedium?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
              ) ??
              const TextStyle(),
          secondaryLabelStyle:
              textTheme.labelMedium?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
              ) ??
              const TextStyle(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: outline),
          ),
          side: const BorderSide(color: outline),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F3EC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: bronze, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: const TextStyle(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(color: Color(0xFF9A8F87)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: paper,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
