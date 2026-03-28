import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_companion/app_theme.dart';
import 'package:spiritual_companion/screens/quran_screen.dart';
import 'package:spiritual_companion/services/quran_service.dart';
import 'package:spiritual_companion/widgets/quran_page_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await QuranService.initialize();
  });

  setUp(() {
    QuranService.setReaderChromeVisible(true);
  });

  testWidgets('Quran reader toggles chrome and opens the manage sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const QuranScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(QuranPageViewer), findsWidgets);
    expect(QuranService.isReaderChromeVisible, isTrue);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byType(QuranPageViewer).first));
    await tester.pumpAndSettle();

    expect(QuranService.isReaderChromeVisible, isFalse);

    await tester.tapAt(tester.getCenter(find.byType(QuranPageViewer).first));
    await tester.pumpAndSettle();

    expect(QuranService.isReaderChromeVisible, isTrue);
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Manage your reading'), findsOneWidget);
    expect(find.text('Last read'), findsOneWidget);

    await tester.tap(find.text('Reader'));
    await tester.pumpAndSettle();

    expect(find.text('Reader settings'), findsOneWidget);
  });
}
