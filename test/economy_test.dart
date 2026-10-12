import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/core/format.dart';
import 'package:vblink/economy/jackpot.dart';
import 'package:vblink/economy/wallet.dart';

void main() {
  test('formatCents groups thousands and keeps two decimals', () {
    expect(formatCents(0), '0.00');
    expect(formatCents(5), '0.05');
    expect(formatCents(100000), '1,000.00');
    expect(formatCents(1509678161), '15,096,781.61');
    expect(formatCents(-123456), '-1,234.56');
  });

  test('wallet starts at 10,000 and never goes below zero', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final wallet = container.read(walletProvider.notifier);

    expect(container.read(walletProvider), 1000000);
    expect(wallet.spend(400000), isTrue);
    expect(container.read(walletProvider), 600000);
    expect(wallet.spend(700000), isFalse);
    expect(wallet.spend(-1), isFalse);
    expect(container.read(walletProvider), 600000);
    wallet.add(150);
    expect(container.read(walletProvider), 600150);
  });

  test('grand jackpot only ever goes up', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final sub = container.listen(grandJackpotProvider, (_, _) {});
    final start = sub.read();

    await Future<void>.delayed(GrandJackpotNotifier.tick * 4);
    expect(sub.read(), greaterThan(start));
  });
}
