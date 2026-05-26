import 'dart:convert';

enum EventType {
  bindPair,
  addNote,
  addImage,
  addMood,
  addScore,
  completeTask,
  addAnniversary,
  dailyCheckin,
}

extension EventTypeValue on EventType {
  String get value {
    switch (this) {
      case EventType.bindPair:
        return 'BIND_PAIR';
      case EventType.addNote:
        return 'ADD_NOTE';
      case EventType.addImage:
        return 'ADD_IMAGE';
      case EventType.addMood:
        return 'ADD_MOOD';
      case EventType.addScore:
        return 'ADD_SCORE';
      case EventType.completeTask:
        return 'COMPLETE_TASK';
      case EventType.addAnniversary:
        return 'ADD_ANNIVERSARY';
      case EventType.dailyCheckin:
        return 'DAILY_CHECKIN';
    }
  }

  static EventType fromValue(String raw) {
    return EventType.values.firstWhere(
      (type) => type.value == raw,
      orElse: () => EventType.addNote,
    );
  }
}

class PairEvent {
  const PairEvent({
    required this.eventId,
    required this.pairId,
    required this.deviceId,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final String eventId;
  final String pairId;
  final String deviceId;
  final EventType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toDb() {
    return {
      'event_id': eventId,
      'pair_id': pairId,
      'device_id': deviceId,
      'event_type': type.value,
      'payload': jsonEncode(payload),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PairEvent.fromDb(Map<String, Object?> row) {
    return PairEvent(
      eventId: row['event_id'] as String,
      pairId: row['pair_id'] as String,
      deviceId: row['device_id'] as String,
      type: EventTypeValue.fromValue(row['event_type'] as String),
      payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

class CoupleProfile {
  const CoupleProfile({
    required this.pairId,
    required this.myDeviceId,
    required this.meName,
    required this.partnerName,
    required this.startedAt,
  });

  final String pairId;
  final String myDeviceId;
  final String meName;
  final String partnerName;
  final DateTime startedAt;

  int get loveDays => DateTime.now().difference(startedAt).inDays + 1;

  Map<String, dynamic> toJson() {
    return {
      'pairId': pairId,
      'myDeviceId': myDeviceId,
      'meName': meName,
      'partnerName': partnerName,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory CoupleProfile.fromJson(Map<String, dynamic> map) {
    return CoupleProfile(
      pairId: map['pairId'] as String,
      myDeviceId: map['myDeviceId'] as String,
      meName: map['meName'] as String,
      partnerName: map['partnerName'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
    );
  }
}

class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.date,
    required this.text,
    this.imagePath,
    this.mood,
    this.tags = const <String>[],
  });

  final String id;
  final DateTime date;
  final String text;
  final String? imagePath;
  final String? mood;
  final List<String> tags;
}

class GrowthScore {
  const GrowthScore({
    required this.intimacy,
    required this.activity,
    required this.chemistry,
  });

  final int intimacy;
  final int activity;
  final int chemistry;

  int get total => intimacy + activity + chemistry;

  GrowthScore add({int intimacy = 0, int activity = 0, int chemistry = 0}) {
    return GrowthScore(
      intimacy: this.intimacy + intimacy,
      activity: this.activity + activity,
      chemistry: this.chemistry + chemistry,
    );
  }

  static const zero = GrowthScore(intimacy: 0, activity: 0, chemistry: 0);
}

class GrowthTaskRecord {
  const GrowthTaskRecord({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.deviceId,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final String deviceId;
}

class AnniversaryItem {
  const AnniversaryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.kind,
    this.remindDays = 7,
  });

  final String id;
  final String title;
  final DateTime date;
  final String kind;
  final int remindDays;

  int get daysLeft {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, date.month, date.day);
    final target = thisYear.isBefore(DateTime(now.year, now.month, now.day))
        ? DateTime(now.year + 1, date.month, date.day)
        : thisYear;
    return target.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  bool get shouldRemind => daysLeft <= remindDays;
}

class TodayStatus {
  const TodayStatus({
    required this.checkinDone,
    required this.noteCount,
    required this.completedTaskCount,
    required this.latestMood,
  });

  final bool checkinDone;
  final int noteCount;
  final int completedTaskCount;
  final String? latestMood;
}
