import 'package:flutter_test/flutter_test.dart';
import 'package:check_park_mobile/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ALPRApp());
    expect(find.byType(ALPRApp), findsOneWidget);
  });
}
