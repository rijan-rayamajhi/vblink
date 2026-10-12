import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/core/storage.dart';
import 'package:vblink/features/profile/player.dart';
import 'package:vblink/main.dart';

import 'helpers/storage.dart';

ProviderContainer _open(Storage storage) {
  final c = ProviderContainer(
    overrides: [storageProvider.overrideWithValue(storage)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('avatar and name survive a restart', () async {
    final storage = await testStorage();
    final first = _open(storage);
    expect(first.read(playerProvider).avatarId, 'prince');
    expect(first.read(playerProvider).name, 'Player');

    first.read(playerProvider.notifier).setAvatar('cat');
    first.read(playerProvider.notifier).setName('  Rijan  ');

    final again = _open(storage).read(playerProvider);
    expect(again.avatarId, 'cat');
    expect(again.name, 'Rijan');
  });

  test('names are trimmed, capped and never empty', () async {
    final c = _open(await testStorage());
    final n = c.read(playerProvider.notifier);

    n.setName('   ');
    expect(c.read(playerProvider).name, 'Player');
    n.setName('A very long player name here');
    expect(c.read(playerProvider).name.length, PlayerNotifier.maxNameLength);
  });

  test('unknown saved avatar falls back to the default', () async {
    final storage = await testStorage({StorageKeys.playerAvatar: 'ghost'});
    expect(_open(storage).read(playerProvider).avatarId, 'prince');
    _open(storage).read(playerProvider.notifier).setAvatar('ghost');
    expect(_open(storage).read(playerProvider).avatarId, 'prince');
  });

  testWidgets('tapping the avatar opens the profile and picks avatars', (
    tester,
  ) async {
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
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.text('10,000.00'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Picker shows the 4 avatars; the cat is last.
    final cat = find.image(const AssetImage('assets/images/avatar_cat.png'));
    await tester.tap(cat.last);
    await tester.pump();
    expect(storage.readString(StorageKeys.playerAvatar, ''), 'cat');
  });
}
