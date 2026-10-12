import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player coin balance, stored in cents so amounts like 0.25 stay exact.
final walletProvider = NotifierProvider<WalletNotifier, int>(
  WalletNotifier.new,
);

class WalletNotifier extends Notifier<int> {
  static const startingCents = 10000 * 100;

  @override
  int build() => startingCents;

  void add(int cents) {
    if (cents <= 0) return;
    state += cents;
  }

  /// Returns false (and changes nothing) if the balance is too low.
  bool spend(int cents) {
    if (cents <= 0 || cents > state) return false;
    state -= cents;
    return true;
  }
}
