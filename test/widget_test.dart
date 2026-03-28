import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_companion/main.dart';
import 'package:spiritual_companion/services/quran_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await QuranService.initialize();
  });

  testWidgets('main navigation is visible', (WidgetTester tester) async {
    await tester.pumpWidget(const SpiritualCompanionApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Prayer'), findsOneWidget);
    expect(find.text('Quran'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Quran tab hides main navigation and exits back to the last tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpiritualCompanionApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('main-nav-hidden')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('quran-reader-back')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('quran-reader-back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('main-nav-visible')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
