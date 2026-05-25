import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pairnest/src/app/pairnest_app.dart';

void main() {
  testWidgets('PairNest app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PairNestApp()));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(PairNestApp), findsOneWidget);
  });
}
