import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Grand Jackpot in cents. Creeps upward on its own so the lobby feels live.
final grandJackpotProvider = NotifierProvider<GrandJackpotNotifier, int>(
  GrandJackpotNotifier.new,
);

class GrandJackpotNotifier extends Notifier<int> {
  static const seedCents = 1509678161; // 15,096,781.61
  static const tick = Duration(milliseconds: 150);

  final _rng = Random();

  @override
  int build() {
    final timer = Timer.periodic(tick, (_) => state += 1 + _rng.nextInt(250));
    ref.onDispose(timer.cancel);
    return seedCents;
  }
}
