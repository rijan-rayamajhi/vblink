import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage.dart';

/// Player coin balance, stored in cents so amounts like 0.25 stay exact.
/// Saved on every change.
final walletProvider = NotifierProvider<WalletNotifier, int>(
  WalletNotifier.new,
);

class WalletNotifier extends Notifier<int> {
  static const startingCents = 10000 * 100;

  @override
  int build() {
    final saved = ref
        .read(storageProvider)
        .readInt(StorageKeys.walletCents, startingCents);
    return saved < 0 ? startingCents : saved;
  }

  void _set(int cents) {
    state = cents;
    ref.read(storageProvider).writeInt(StorageKeys.walletCents, cents);
  }

  void add(int cents) {
    if (cents <= 0) return;
    _set(state + cents);
  }

  /// Returns false (and changes nothing) if the balance is too low.
  bool spend(int cents) {
    if (cents <= 0 || cents > state) return false;
    _set(state - cents);
    return true;
  }
}
