import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/core/storage.dart';
import 'package:vblink/economy/game_jackpots.dart';
import 'package:vblink/economy/wallet.dart';
import 'package:vblink/features/profile/player.dart';
import 'package:vblink/games/gold_rush_express/config.dart';
import 'package:vblink/games/slot_engine/slot_session.dart';

import 'helpers/storage.dart';

Future<ProviderContainer> _open({int walletCents = 1000000}) async {
  final storage = await testStorage({StorageKeys.walletCents: walletCents});
  final c = ProviderContainer(
    overrides: [storageProvider.overrideWithValue(storage)],
  );
  addTearDown(c.dispose);
  // Keep the auto-dispose session alive for the whole test.
  c.listen(slotSessionProvider(goldRushConfig), (_, _) {});
  return c;
}

void main() {
  setUp(() => SlotSessionNotifier.rng = () => Random(42));
  tearDown(() => SlotSessionNotifier.rng = Random.secure);

  test('a paid spin charges the bet and credits the win at once', () async {
    final c = await _open();
    final n = c.read(slotSessionProvider(goldRushConfig).notifier);
    final bet = n.betCents;

    expect(n.spin(), SpinOutcome.started);
    final s = c.read(slotSessionProvider(goldRushConfig));
    expect(c.read(walletProvider), 1000000 - bet + s.pendingCents);
    expect(s.spinning, isTrue);

    // A second tap while spinning is ignored.
    expect(n.spin(), SpinOutcome.busy);

    n.reveal();
    final after = c.read(slotSessionProvider(goldRushConfig));
    expect(after.spinning, isFalse);
    expect(after.pendingCents, 0);
    expect(after.lastWinCents, s.pendingCents);
  });

  test('spins are refused when the balance is too low', () async {
    final c = await _open(walletCents: 500);
    final n = c.read(slotSessionProvider(goldRushConfig).notifier);
    expect(n.spin(), SpinOutcome.notEnoughCoins);
    expect(c.read(walletProvider), 500);
  });

  test('spins record stats, XP and feed the game jackpot', () async {
    final c = await _open();
    final n = c.read(slotSessionProvider(goldRushConfig).notifier);
    final jackpotBefore = c.read(gameJackpotsProvider)[goldRushConfig.id]!;

    n.spin();
    n.reveal();

    final p = c.read(playerProvider);
    expect(p.totalSpins, 1);
    expect(p.xp, n.betCents ~/ 100);
    expect(
      c.read(gameJackpotsProvider)[goldRushConfig.id]!,
      greaterThanOrEqualTo(jackpotBefore + n.betCents ~/ 100),
    );
  });

  test('free spins cost nothing and count down', () async {
    final c = await _open(walletCents: 100000000);
    final n = c.read(slotSessionProvider(goldRushConfig).notifier);

    // Play until the seeded generator triggers free spins.
    var guard = 0;
    while (!c.read(slotSessionProvider(goldRushConfig)).inFreeSpins) {
      n.spin();
      n.reveal();
      expect(++guard, lessThan(5000), reason: 'free spins never triggered');
    }
    final left = c.read(slotSessionProvider(goldRushConfig)).freeSpinsLeft;
    final walletBefore = c.read(walletProvider);

    n.spin();
    final s = c.read(slotSessionProvider(goldRushConfig));
    expect(c.read(walletProvider), walletBefore + s.pendingCents);
    expect(s.freeSpinsLeft, left - 1 + (s.result!.freeSpinsAwarded));
    // Bet can't change mid-feature.
    final bet = n.betCents;
    n.changeBet(1);
    expect(n.betCents, bet);
  });

  test('levels go up as XP crosses the threshold', () async {
    final c = await _open();
    final p = c.read(playerProvider.notifier);
    final gained = p.recordSpin(betCents: 150000, winCents: 0);
    expect(gained, 1);
    expect(c.read(playerProvider).level, 2);
    expect(c.read(playerProvider).xp, 500);
  });
}
