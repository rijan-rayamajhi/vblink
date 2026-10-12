import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage.dart';
import 'wallet.dart';

/// Free-coin timer: counts down, then the player can collect a reward.
/// The ready time is saved as a wall-clock timestamp, so time keeps passing
/// while the app is closed.
final taskRewardProvider = NotifierProvider<TaskRewardNotifier, Duration>(
  TaskRewardNotifier.new,
);

class TaskRewardNotifier extends Notifier<Duration> {
  static const cooldown = Duration(hours: 8, minutes: 30);
  static const rewardCents = 500 * 100;

  /// Injectable clock for tests.
  static DateTime Function() now = DateTime.now;

  late DateTime _readyAt;

  @override
  Duration build() {
    final storage = ref.read(storageProvider);
    final savedMs = storage.readInt(StorageKeys.taskRewardReadyAtMs, -1);
    final latest = now().add(cooldown);
    if (savedMs < 0) {
      _setReadyAt(latest);
    } else {
      final saved = DateTime.fromMillisecondsSinceEpoch(savedMs);
      // A ready time beyond a full cooldown means the clock was changed.
      _readyAt = saved.isAfter(latest) ? latest : saved;
    }

    final timer = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
    ref.onDispose(timer.cancel);
    return _remaining();
  }

  void _setReadyAt(DateTime t) {
    _readyAt = t;
    ref
        .read(storageProvider)
        .writeInt(StorageKeys.taskRewardReadyAtMs, t.millisecondsSinceEpoch);
  }

  Duration _remaining() {
    final left = _readyAt.difference(now());
    return left.isNegative ? Duration.zero : left;
  }

  void _refresh() => state = _remaining();

  bool get isReady => _remaining() == Duration.zero;

  /// Pays out and restarts the timer. Returns false if not ready yet.
  bool collect() {
    if (!isReady) return false;
    ref.read(walletProvider.notifier).add(rewardCents);
    _setReadyAt(now().add(cooldown));
    _refresh();
    return true;
  }
}
