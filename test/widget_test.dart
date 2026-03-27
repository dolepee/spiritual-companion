import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_companion/main.dart';

void main() {
  testWidgets('main navigation is visible', (WidgetTester tester) async {
    await tester.pumpWidget(const SpiritualCompanionApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Prayer'), findsOneWidget);
    expect(find.text('Quran'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
