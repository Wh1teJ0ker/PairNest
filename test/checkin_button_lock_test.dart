import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/app/providers.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';
import 'package:pairnest/src/features/growth/growth_page.dart';

class _TestProfileController extends ProfileController {
  _TestProfileController(this.profile);

  final CoupleProfile? profile;

  @override
  Future<CoupleProfile?> build() async => profile;
}

class _RecordingPairRepository extends PairRepository {
  _RecordingPairRepository(this.onCheckin);

  final Future<void> Function(CoupleProfile profile) onCheckin;

  @override
  Future<void> checkinTogether(CoupleProfile profile) => onCheckin(profile);
}

void main() {
  testWidgets('checkin button only submits once while request is in flight', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final completer = Completer<void>();
    var checkinCalls = 0;
    final profile = CoupleProfile(
      pairId: 'pair-1',
      myDeviceId: 'device-a',
      meName: 'A',
      partnerName: 'B',
      startedAt: DateTime(2026, 5, 1),
    );

    final repository = _RecordingPairRepository((_) async {
      checkinCalls += 1;
      return completer.future;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pairRepositoryProvider.overrideWithValue(repository),
          profileProvider.overrideWith(() => _TestProfileController(profile)),
          growthProvider.overrideWith((ref) async {
            return const GrowthScore(intimacy: 10, activity: 8, chemistry: 9);
          }),
          growthTaskHistoryProvider.overrideWith((ref) async {
            return const <GrowthTaskRecord>[];
          }),
          partnerScoreHistoryProvider.overrideWith((ref) async {
            return const <PartnerScoreRecord>[];
          }),
          todayStatusProvider.overrideWith((ref) async {
            return const TodayStatus(
              checkinDone: false,
              noteCount: 0,
              completedTaskCount: 0,
              latestMood: null,
            );
          }),
        ],
        child: const MaterialApp(home: GrowthPage()),
      ),
    );

    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(FilledButton, '一起签到');
    expect(buttonFinder, findsOneWidget);
    await tester.ensureVisible(buttonFinder);

    await tester.tap(buttonFinder);
    await tester.pump();

    expect(checkinCalls, 1);
    expect(find.text('签到中...'), findsOneWidget);

    final loadingButtonFinder = find.widgetWithText(FilledButton, '签到中...');
    await tester.ensureVisible(loadingButtonFinder);
    await tester.tap(loadingButtonFinder, warnIfMissed: false);
    await tester.pump();

    expect(checkinCalls, 1);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.text('今天已签到'), findsOneWidget);
  });
}
