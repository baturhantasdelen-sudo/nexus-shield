import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexusshield_mobile/main.dart';

void main() {
  testWidgets('Live shield shell renders active protection UI', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NexusShieldApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Personal Guard'), findsOneWidget);
    expect(find.textContaining('Kalkanı Devreye Al'), findsOneWidget);
    expect(find.text('Komuta modülleri'), findsOneWidget);
    expect(find.text('Otomatik Tam Koruma'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Canlı müdahale günlüğü'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Canlı müdahale günlüğü'), findsOneWidget);
  });
}
