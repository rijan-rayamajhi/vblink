import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/core/storage.dart';
import 'package:vblink/features/settings/settings.dart';
import 'package:vblink/main.dart';

import 'helpers/storage.dart';

void main() {
  test('settings default to on and survive a restart', () async {
    final storage = await testStorage();
    ProviderContainer open() {
      final c = ProviderContainer(
        overrides: [storageProvider.overrideWithValue(storage)],
      );
      addTearDown(c.dispose);
      return c;
    }

    final first = open();
    final s = first.read(settingsProvider);
    expect([s.music, s.soundEffects, s.vibration], [true, true, true]);
    first.read(settingsProvider.notifier).setMusic(false);
    first.read(settingsProvider.notifier).setVibration(false);

    final again = open().read(settingsProvider);
    expect(
      [again.music, again.soundEffects, again.vibration],
      [false, true, false],
    );
  });

  testWidgets('menu button opens settings and toggles save', (tester) async {
    tester.view.physicalSize = const Size(874, 402);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final storage = await testStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        child: const MyApp(),
      ),
    );
    await tester.tap(find.byIcon(Icons.menu_rounded));
    // First pump pushes the route, second runs the slide-in to the end.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Music'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(storage.readBool(StorageKeys.music, true), isFalse);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SETTINGS'), findsNothing);
  });
}
