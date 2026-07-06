import 'package:fishing_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱 시작 smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FishingApp()));
    await tester.pumpAndSettle();
    expect(find.byType(FishingApp), findsOneWidget);
  });
}
