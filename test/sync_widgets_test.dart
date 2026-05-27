import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/domain/models.dart';
import 'package:pairnest/src/features/home/widgets/recent_entries_card.dart';
import 'package:pairnest/src/features/home/widgets/today_status_card.dart';
import 'package:pairnest/src/features/sync/widgets/discovered_endpoints_list.dart';
import 'package:pairnest/src/features/sync/widgets/pairing_status_card.dart';

void main() {
  testWidgets(
    'DiscoveredEndpointsList marks selected endpoint and handles tap',
    (WidgetTester tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveredEndpointsList(
              endpoints: const [
                'Joker Phone (endpoint-a)',
                'Partner Phone (endpoint-b)',
              ],
              selectedEndpointId: 'endpoint-a',
              onSelect: (endpointId) => selected = endpointId,
            ),
          ),
        ),
      );

      expect(
        find.textContaining('Joker Phone (endpoint-a)（已选择）'),
        findsOneWidget,
      );
      expect(find.textContaining('Partner Phone (endpoint-b)'), findsOneWidget);

      await tester.tap(find.textContaining('Partner Phone (endpoint-b)'));
      await tester.pump();

      expect(selected, 'endpoint-b');
    },
  );

  testWidgets('PairingStatusCard renders paired state details', (
    WidgetTester tester,
  ) async {
    final status = PairingStatus(
      pairId: 'pair-12345678',
      myDeviceId: 'device-a',
      meName: '小王',
      expectedPartnerName: '小李',
      startedAt: DateTime(2026, 5, 1),
      participantNames: ['小李', '小王'],
      remoteParticipantNames: ['小李'],
      remoteDeviceIds: ['device-b'],
      syncedDeviceCount: 2,
      hasLocalBinding: true,
      hasRemoteBinding: true,
      lastRemoteBoundAt: DateTime(2026, 5, 27, 20, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PairingStatusCard(status: status)),
      ),
    );

    expect(find.text('双端配对已完成'), findsOneWidget);
    expect(find.textContaining('空间 PAIR-123'), findsOneWidget);
    expect(find.textContaining('本机 小王'), findsOneWidget);
    expect(find.textContaining('匹配对象: 小李'), findsOneWidget);
    expect(find.textContaining('设备 2'), findsOneWidget);
  });

  testWidgets('home summary cards render current status and recent entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const TodayStatusCard(
                status: TodayStatus(
                  checkinDone: true,
                  noteCount: 2,
                  completedTaskCount: 1,
                  latestMood: '放松',
                ),
              ),
              RecentEntriesCard(
                entries: [
                  TimelineEntry(
                    id: 'entry-1',
                    date: DateTime(2026, 5, 27, 21),
                    text: '一起散步回家',
                    tags: const ['生活', '散步'],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('今日状态'), findsOneWidget);
    expect(find.textContaining('已签到'), findsOneWidget);
    expect(find.textContaining('记录 2 条'), findsOneWidget);
    expect(find.text('最近记录'), findsOneWidget);
    expect(find.textContaining('一起散步回家'), findsOneWidget);
    expect(find.text('生活'), findsOneWidget);
  });
}
