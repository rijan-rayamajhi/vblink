import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage.dart';
import '../features/lobby/data/games.dart';

/// Per-game jackpots in cents, keyed by game id. Each creeps up slowly and
/// resumes from its saved value after a restart.
final gameJackpotsProvider =
    NotifierProvider<GameJackpotsNotifier, Map<String, int>>(
      GameJackpotsNotifier.new,
    );

class GameJackpotsNotifier extends Notifier<Map<String, int>> {
  static const tick = Duration(milliseconds: 400);
  static const saveEvery = Duration(seconds: 1);

  final _rng = Random();

  @override
  Map<String, int> build() {
    final storage = ref.read(storageProvider);
    // Tracked locally so the final save on dispose never reads `state`.
    var current = {
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
      for (final MapEntry(:key, :value) in current.entries) {
        storage.writeInt(StorageKeys.gameJackpotCents(key), value);
      }
    }

    final ticker = Timer.periodic(tick, (_) {
      current = {
        for (final MapEntry(:key, :value) in current.entries)
          key: value + _rng.nextInt(40),
      };
      state = current;
    });
    final saver = Timer.periodic(saveEvery, (_) => save());
    ref.onDispose(() {
      ticker.cancel();
      saver.cancel();
      save();
    });

    return current;
  }
}
