import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage.dart';

/// Grand Jackpot in cents. Creeps upward on its own so the lobby feels live,
/// and resumes from its saved value after a restart.
final grandJackpotProvider = NotifierProvider<GrandJackpotNotifier, int>(
  GrandJackpotNotifier.new,
);

class GrandJackpotNotifier extends Notifier<int> {
  static const seedCents = 1509678161; // 15,096,781.61
  static const tick = Duration(milliseconds: 150);
  static const saveEvery = Duration(seconds: 1);

  final _rng = Random();

  /// Tracked outside `state` so the final save on dispose never reads it.
  late int _current;

  @override
  int build() {
    final storage = ref.read(storageProvider);
    final saved = storage.readInt(StorageKeys.grandJackpotCents, seedCents);
    _current = max(saved, seedCents);
    void save() => storage.writeInt(StorageKeys.grandJackpotCents, _current);

    final ticker = Timer.periodic(tick, (_) {
      _current += 1 + _rng.nextInt(250);
      state = _current;
    });
    final saver = Timer.periodic(saveEvery, (_) => save());
    ref.onDispose(() {
      ticker.cancel();
      saver.cancel();
      save();
    });

    return _current;
  }

  /// Adds part of a bet to the Grand Jackpot.
  void contribute(int cents) {
    if (cents <= 0) return;
    _current += cents;
    state = _current;
  }
}
