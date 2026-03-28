import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_companion/app_theme.dart';
import 'package:spiritual_companion/screens/tasbih_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'tasbih_count': 0,
      'tasbih_total_count': 0,
      'tasbih_target_count': 1,
      'tasbih_completed_rounds': 0,
      'tasbih_daily_completed_rounds': 0,
      'tasbih_current_streak': 0,
      'tasbih_last_completion_date': '',
    });
  });

  testWidgets(
    'long-press undo does not reduce lifetime totals after a completed round',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const TasbihScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lifetime 0'), findsOneWidget);

      final counterButton = find.byKey(
        const ValueKey<String>('tasbih-counter-button'),
      );

      await tester.tap(counterButton);
      await tester.pumpAndSettle();

      expect(find.text('Lifetime 1'), findsOneWidget);
      expect(find.text('Today 1/3'), findsOneWidget);

      await tester.longPress(counterButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Lifetime 1'), findsOneWidget);
      expect(find.text('Lifetime 0'), findsNothing);
      expect(find.text('Today 1/3'), findsOneWidget);
    },
  );
}
