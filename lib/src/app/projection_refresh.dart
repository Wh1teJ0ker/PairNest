import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

extension ProjectionRefreshX on WidgetRef {
  void invalidateAfterTimelineEntry() {
    invalidate(timelineProvider);
    invalidate(growthProvider);
    invalidate(todayStatusProvider);
  }

  void invalidateAfterPartnerScoreRecord() {
    invalidate(growthProvider);
    invalidate(partnerScoreHistoryProvider);
    invalidate(timelineProvider);
  }

  void invalidateAfterCheckin() {
    invalidate(growthProvider);
    invalidate(todayStatusProvider);
  }

  void invalidateAfterTaskCompletion() {
    invalidate(growthProvider);
    invalidate(growthTaskHistoryProvider);
    invalidate(todayStatusProvider);
  }

  void invalidateAfterAnniversary() {
    invalidate(anniversaryProvider);
    invalidate(timelineProvider);
  }

  void invalidateAfterInboundSyncImage() {
    invalidate(timelineProvider);
    invalidate(partnerScoreHistoryProvider);
    invalidate(pairingStatusProvider);
  }

  void invalidateAllPairScopedProjections() {
    invalidate(timelineProvider);
    invalidate(growthProvider);
    invalidate(growthTaskHistoryProvider);
    invalidate(partnerScoreHistoryProvider);
    invalidate(anniversaryProvider);
    invalidate(todayStatusProvider);
    invalidate(pairingStatusProvider);
  }
}
