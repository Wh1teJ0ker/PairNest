import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/domain/models.dart';

void main() {
  test('AnniversaryItem shouldRemind follows daysLeft and remindDays', () {
    final now = DateTime.now();
    final soon = AnniversaryItem(
      id: 'a1',
      title: '纪念日',
      date: DateTime(now.year, now.month, now.day).add(const Duration(days: 3)),
      kind: '纪念日',
      remindDays: 7,
    );
    final later = AnniversaryItem(
      id: 'a2',
      title: '生日',
      date: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 20)),
      kind: '生日',
      remindDays: 7,
    );

    expect(soon.shouldRemind, isTrue);
    expect(later.shouldRemind, isFalse);
    expect(soon.daysLeft, lessThan(later.daysLeft));
  });

  test('Anniversary items can be sorted by daysLeft ascending', () {
    final now = DateTime.now();
    final items = <AnniversaryItem>[
      AnniversaryItem(
        id: 'a1',
        title: '远一点',
        date: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 30)),
        kind: '纪念日',
      ),
      AnniversaryItem(
        id: 'a2',
        title: '更近',
        date: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 2)),
        kind: '生日',
      ),
    ];

    items.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    expect(items.first.id, 'a2');
    expect(items.last.id, 'a1');
  });
}
