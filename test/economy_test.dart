import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/core/format.dart';
import 'package:vblink/core/storage.dart';
import 'package:vblink/economy/game_jackpots.dart';
import 'package:vblink/economy/jackpot.dart';
import 'package:vblink/economy/task_reward.dart';
import 'package:vblink/economy/wallet.dart';

import 'helpers/storage.dart';

ProviderContainer _container(Storage storage) {
  final c = ProviderContainer(
    overrides: [storageProvider.overrideWithValue(storage)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  tearDown(() => TaskRewardNotifier.now = DateTime.now);

  test('formatCents groups thousands and keeps two decimals', () {
    expect(formatCents(0), '0.00');
    expect(formatCents(5), '0.05');
    expect(formatCents(100000), '1,000.00');
    expect(formatCents(1509678161), '15,096,781.61');
    expect(formatCents(-123456), '-1,234.56');
  });

  test('wallet starts at 10,000 and never goes below zero', () async {
    final c = _container(await testStorage());
    final wallet = c.read(walletProvider.notifier);

    expect(c.read(walletProvider), 1000000);
    expect(wallet.spend(400000), isTrue);
    expect(c.read(walletProvider), 600000);
    expect(wallet.spend(700000), isFalse);
    expect(wallet.spend(-1), isFalse);
    wallet.add(150);
    expect(c.read(walletProvider), 600150);
  });

  test('wallet balance survives an app restart', () async {
    final storage = await testStorage();
    _container(storage).read(walletProvider.notifier).spend(250000);

    // A new container is what a relaunch looks like.
    expect(_container(storage).read(walletProvider), 750000);
  });

  test('corrupted wallet data falls back to the starting balance', () async {
    final storage = await testStorage({StorageKeys.walletCents: 'garbage'});
    expect(_container(storage).read(walletProvider), 1000000);
  });

  test('grand jackpot only ever goes up', () async {
    final c = _container(await testStorage());
    final sub = c.listen(grandJackpotProvider, (_, _) {});
    final start = sub.read();

    await Future<void>.delayed(GrandJackpotNotifier.tick * 4);
    expect(sub.read(), greaterThan(start));
  });

  test('jackpots resume from their saved values', () async {
    final storage = await testStorage({
      StorageKeys.grandJackpotCents: 2000000000,
      StorageKeys.gameJackpotCents('neon_7s'): 99999999,
    });
    final c = _container(storage);

    expect(c.read(grandJackpotProvider), 2000000000);
    expect(c.read(gameJackpotsProvider)['neon_7s'], 99999999);
  });

  test('jackpots are saved when the app closes', () async {
    final storage = await testStorage();
    final c = ProviderContainer(
      overrides: [storageProvider.overrideWithValue(storage)],
    );
    final sub = c.listen(grandJackpotProvider, (_, _) {});
    await Future<void>.delayed(GrandJackpotNotifier.tick * 3);
    final last = sub.read();
    c.dispose();

    expect(
      storage.readInt(StorageKeys.grandJackpotCents, 0),
      greaterThanOrEqualTo(last),
    );
  });

  test('task reward keeps counting while the app is closed', () async {
    final start = DateTime(2026, 10, 12, 9);
    TaskRewardNotifier.now = () => start;
    final storage = await testStorage();
    expect(
      _container(storage).read(taskRewardProvider),
      TaskRewardNotifier.cooldown,
    );

    // Reopen 3 hours later: 5h30m left.
    TaskRewardNotifier.now = () => start.add(const Duration(hours: 3));
    expect(
      _container(storage).read(taskRewardProvider),
      const Duration(hours: 5, minutes: 30),
    );

    // Reopen after the cooldown: ready, and collecting pays 500 coins.
    TaskRewardNotifier.now = () => start.add(const Duration(hours: 9));
    final c = _container(storage);
    expect(c.read(taskRewardProvider), Duration.zero);
    expect(c.read(taskRewardProvider.notifier).collect(), isTrue);
    expect(c.read(walletProvider), 1000000 + TaskRewardNotifier.rewardCents);
    expect(c.read(taskRewardProvider.notifier).collect(), isFalse);
  });
}
