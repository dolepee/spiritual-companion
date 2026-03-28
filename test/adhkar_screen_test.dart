import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_companion/screens/adhkar_screen.dart';

class _TestAdhkarAssetBundle extends CachingAssetBundle {
  _TestAdhkarAssetBundle(this.adhkarJson);

  final String adhkarJson;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key != 'assets/adhkar_data.json') {
      throw FlutterError('Unexpected asset request: $key');
    }

    return adhkarJson;
  }

  @override
  Future<ByteData> load(String key) async {
    if (key != 'assets/adhkar_data.json') {
      throw FlutterError('Unexpected asset request: $key');
    }

    final bytes = Uint8List.fromList(utf8.encode(adhkarJson));
    return ByteData.sublistView(bytes);
  }
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 30,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Timed out waiting for $finder to appear.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String assetJson;
  String? copiedText;

  setUpAll(() async {
    final assetFile = File('${Directory.current.path}/assets/adhkar_data.json');
    assetJson = await assetFile.readAsString();
  });

  setUp(() {
    copiedText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText =
            (call.arguments as Map<dynamic, dynamic>)['text'] as String?;
        return null;
      }
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': copiedText};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('Adhkar screen renders tabs, metadata, and copy output', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdhkarScreen(
          assetBundle: _TestAdhkarAssetBundle(assetJson),
        ),
      ),
    );

    await _pumpUntilVisible(tester, find.text('Morning Adhkar'));

    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Evening'), findsOneWidget);
    expect(find.text('Morning Adhkar'), findsOneWidget);

    final dua76Title = find.text(
      'Recite Surah Al-Ikhlas, Surah Al-Falaq and Surah An-Nas',
    );
    await tester.ensureVisible(dua76Title);
    await tester.pump(const Duration(milliseconds: 200));

    final dua76Card = find.ancestor(
      of: dua76Title,
      matching: find.byType(Card),
    );

    expect(dua76Title, findsOneWidget);
    expect(
      find.descendant(
        of: dua76Card,
        matching: find.text('Repeat: 3x each'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dua76Card,
        matching: find.text('Needs review'),
      ),
      findsNothing,
    );

    final copyButton = find.byKey(const ValueKey<String>('adhkar-copy-Dua 76'));

    await tester.ensureVisible(copyButton);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(copyButton);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Adhkar copied to clipboard'), findsOneWidget);
    expect(
      copiedText,
      contains('Recite Surah Al-Ikhlas, Surah Al-Falaq and Surah An-Nas'),
    );
    expect(copiedText, isNot(contains('Dua 76')));
    expect(copiedText, contains('Repeat: 3x each'));
    expect(copiedText, isNot(contains('Review note:')));

    expect(find.text('Salawat upon the Prophet ﷺ'), findsOneWidget);

    await tester.tap(find.text('Evening'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Evening Adhkar'), findsOneWidget);
    expect(find.text('Morning Adhkar'), findsNothing);

    final eveningTitle = find.text(
      'Recite Surah Al-Ikhlas, Surah Al-Falaq and Surah An-Nas',
    );
    await tester.ensureVisible(eveningTitle);
    await tester.pump(const Duration(milliseconds: 200));

    final eveningCard = find.ancestor(
      of: eveningTitle,
      matching: find.byType(Card),
    );

    expect(eveningTitle, findsOneWidget);
    expect(
      find.descendant(
        of: eveningCard,
        matching: find.text('Repeat: 3x each'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: eveningCard,
        matching: find.text('Needs review'),
      ),
      findsNothing,
    );
    expect(find.text('Salawat upon the Prophet ﷺ'), findsOneWidget);
  });
}
