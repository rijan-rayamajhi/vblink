import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wallet.dart';

/// Free-coin timer: counts down, then the player can collect a reward.
final taskRewardProvider = NotifierProvider<TaskRewardNotifier, Duration>(
  TaskRewardNotifier.new,
);

class TaskRewardNotifier extends Notifier<Duration> {
  static const cooldown = Duration(hours: 8, minutes: 30);
  static const rewardCents = 500 * 100;

  late DateTime _readyAt;

  @override
  Duration build() {
    _readyAt = DateTime.now().add(cooldown);
    final timer = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
    ref.onDispose(timer.cancel);
    return cooldown;
  }

  void _refresh() {
    final left = _readyAt.difference(DateTime.now());
    state = left.isNegative ? Duration.zero : left;
  }

  bool get isReady => state == Duration.zero;

  /// Pays out and restarts the timer. Returns false if not ready yet.
  bool collect() {
    if (!isReady) return false;
    ref.read(walletProvider.notifier).add(rewardCents);
    _readyAt = DateTime.now().add(cooldown);
    _refresh();
    return true;
  }
}
