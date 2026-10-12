import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage.dart';
import '../features/lobby/data/games.dart';

/// Per-game jackpots in cents, keyed by game id. Each creeps up slowly,
/// grows with every bet, and resumes from its saved value after a restart.
final gameJackpotsProvider =
    NotifierProvider<GameJackpotsNotifier, Map<String, int>>(
      GameJackpotsNotifier.new,
    );

class GameJackpotsNotifier extends Notifier<Map<String, int>> {
  static const tick = Duration(milliseconds: 400);
  static const saveEvery = Duration(seconds: 1);

  final _rng = Random();

  /// Tracked outside `state` so the final save on dispose never reads it.
  late Map<String, int> _current;

  @override
  Map<String, int> build() {
    final storage = ref.read(storageProvider);
    _current = {
      for (final g in allGames)
        g.id: max(
          storage.readInt(
            StorageKeys.gameJackpotCents(g.id),
            g.jackpotSeedCents,
          ),
          g.jackpotSeedCents,
        ),
    };
    void save() {
      for (final MapEntry(:key, :value) in _current.entries) {
        storage.writeInt(StorageKeys.gameJackpotCents(key), value);
      }
    }

    final ticker = Timer.periodic(tick, (_) {
      _set({
        for (final MapEntry(:key, :value) in _current.entries)
          key: value + _rng.nextInt(40),
      });
    });
    final saver = Timer.periodic(saveEvery, (_) => save());
    ref.onDispose(() {
      ticker.cancel();
      saver.cancel();
      save();
    });

    return _current;
  }

  void _set(Map<String, int> next) {
    _current = next;
    state = next;
  }

  /// Adds part of a bet to a game's jackpot.
  void contribute(String gameId, int cents) {
    if (cents <= 0) return;
    _set({..._current, gameId: _current[gameId]! + cents});
  }

  /// Pays out [share] (0..1) of a game's jackpot. A full claim resets it to
  /// its seed; a partial claim just deducts what was paid.
  int claim(String gameId, double share) {
    final value = _current[gameId]!;
    final paid = (value * share.clamp(0, 1)).round();
    final seed = allGames.firstWhere((g) => g.id == gameId).jackpotSeedCents;
    _set({..._current, gameId: max(seed, value - paid)});
    return paid;
  }
}
