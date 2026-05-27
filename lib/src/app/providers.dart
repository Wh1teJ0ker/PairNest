import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pair_repository.dart';
import '../domain/models.dart';
import '../features/sync/nearby_sync_service.dart';

final pairRepositoryProvider = Provider<PairRepository>((ref) {
  return PairRepository();
});

final nearbySyncServiceProvider = Provider<NearbySyncService>((ref) {
  final service = NearbySyncService();
  ref.onDispose(service.dispose);
  return service;
});

final profileProvider =
    AsyncNotifierProvider<ProfileController, CoupleProfile?>(
      ProfileController.new,
    );

class ProfileController extends AsyncNotifier<CoupleProfile?> {
  @override
  Future<CoupleProfile?> build() async {
    return ref.read(pairRepositoryProvider).readProfile();
  }

  Future<CoupleProfile> bind({
    required String meName,
    required String partnerName,
    required DateTime startedAt,
  }) async {
    state = const AsyncLoading();
    final profile = await ref
        .read(pairRepositoryProvider)
        .bindCouple(
          meName: meName,
          partnerName: partnerName,
          startedAt: startedAt,
        );
    state = AsyncData(profile);
    return profile;
  }

  Future<CoupleProfile> joinByInvite({
    required String myName,
    required String pairId,
    required String partnerName,
    required DateTime startedAt,
  }) async {
    state = const AsyncLoading();
    final profile = await ref
        .read(pairRepositoryProvider)
        .joinCoupleByInvite(
          meName: myName,
          pairId: pairId,
          partnerName: partnerName,
          startedAt: startedAt,
        );
    state = AsyncData(profile);
    return profile;
  }
}

final timelineProvider = FutureProvider<List<TimelineEntry>>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return <TimelineEntry>[];
  }
  return ref.read(pairRepositoryProvider).timeline(profile);
});

final growthProvider = FutureProvider<GrowthScore>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return GrowthScore.zero;
  }
  return ref.read(pairRepositoryProvider).growthScore(profile);
});

final growthTaskHistoryProvider = FutureProvider<List<GrowthTaskRecord>>((
  ref,
) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return <GrowthTaskRecord>[];
  }
  return ref.read(pairRepositoryProvider).recentGrowthTasks(profile);
});

final partnerScoreHistoryProvider = FutureProvider<List<PartnerScoreRecord>>((
  ref,
) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return <PartnerScoreRecord>[];
  }
  return ref.read(pairRepositoryProvider).recentPartnerScoreRecords(profile);
});

final anniversaryProvider = FutureProvider<List<AnniversaryItem>>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return <AnniversaryItem>[];
  }
  return ref.read(pairRepositoryProvider).anniversaries(profile);
});

final todayStatusProvider = FutureProvider<TodayStatus>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return const TodayStatus(
      checkinDone: false,
      noteCount: 0,
      completedTaskCount: 0,
      latestMood: null,
    );
  }
  return ref.read(pairRepositoryProvider).todayStatus(profile);
});

final pairingStatusProvider = FutureProvider<PairingStatus?>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return null;
  }
  return ref.read(pairRepositoryProvider).pairingStatus(profile);
});
