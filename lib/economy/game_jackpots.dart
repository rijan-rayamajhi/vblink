import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/lobby/data/games.dart';

/// Per-game jackpots in cents, keyed by game id. Each creeps up slowly.
final gameJackpotsProvider =
    NotifierProvider<GameJackpotsNotifier, Map<String, int>>(
      GameJackpotsNotifier.new,
    );

class GameJackpotsNotifier extends Notifier<Map<String, int>> {
  static const tick = Duration(milliseconds: 400);

  final _rng = Random();

  @override
  Map<String, int> build() {
    final timer = Timer.periodic(tick, (_) {
      state = {
        for (final MapEntry(:key, :value) in state.entries)
          key: value + _rng.nextInt(40),
      };
    });
    ref.onDispose(timer.cancel);
    return {for (final g in allGames) g.id: g.jackpotSeedCents};
  }
}
