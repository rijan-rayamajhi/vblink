// Pure Dart (no Flutter imports) so the math can run in tools and tests.
import 'dart:math';

import 'slot_config.dart';

class LineWin {
  const LineWin({
    required this.line,
    required this.symbolId,
    required this.count,
    required this.payCents,
  });

  final int line;
  final String symbolId;
  final int count;
  final int payCents;
}

class SpinResult {
  const SpinResult({
    required this.stops,
    required this.grid,
    required this.lineWins,
    required this.scatterCount,
    required this.scatterPayCents,
    required this.freeSpinsAwarded,
    required this.jackpotHit,
  });

  /// Strip index shown in the top row, per reel.
  final List<int> stops;

  /// grid[reel][row] symbol ids.
  final List<List<String>> grid;
  final List<LineWin> lineWins;
  final int scatterCount;
  final int scatterPayCents;
  final int freeSpinsAwarded;

  /// Five wilds on a line.
  final bool jackpotHit;

  int get totalCents =>
      lineWins.fold(scatterPayCents, (sum, w) => sum + w.payCents);
}

class SlotMath {
  SlotMath(this.config);

  final SlotConfig config;

  /// Random reel stops using [rng]; pass `Random.secure()` in the app.
  SpinResult spin(
    Random rng, {
    required int totalBetCents,
    bool freeSpin = false,
  }) {
    final stops = [for (final s in config.strips) rng.nextInt(s.length)];
    return evaluate(stops, totalBetCents: totalBetCents, freeSpin: freeSpin);
  }

  List<List<String>> gridFor(List<int> stops) => [
    for (var r = 0; r < config.reels; r++)
      [
        for (var row = 0; row < SlotConfig.rows; row++)
          config.strips[r][(stops[r] + row) % config.strips[r].length],
      ],
  ];

  SpinResult evaluate(
    List<int> stops, {
    required int totalBetCents,
    bool freeSpin = false,
  }) {
    final grid = gridFor(stops);
    final lineBet = totalBetCents ~/ config.lines.length;
    final mult = freeSpin ? config.freeSpinMultiplier : 1;

    final wins = <LineWin>[];
    var jackpot = false;
    for (var i = 0; i < config.lines.length; i++) {
      final line = config.lines[i];
      final syms = [
        for (var r = 0; r < config.reels; r++) config.symbol(grid[r][line[r]]),
      ];
      final win = _lineWin(syms);
      if (win == null) continue;
      if (win.$1.isWild && win.$2 == config.reels) jackpot = true;
      final pay = win.$1.pays[win.$2 - 3] * lineBet * mult;
      wins.add(
        LineWin(line: i, symbolId: win.$1.id, count: win.$2, payCents: pay),
      );
    }

    final scatters = grid.expand((c) => c).where((id) {
      return config.symbol(id).isScatter;
    }).length;
    final capped = min(scatters, 5);
    final scatterPay = (config.scatterPays[capped] ?? 0) * totalBetCents * mult;
    final spins = scatters < 3
        ? 0
        : freeSpin
        ? config.retriggerSpins
        : config.freeSpins[capped]!;

    return SpinResult(
      stops: stops,
      grid: grid,
      lineWins: wins,
      scatterCount: scatters,
      scatterPayCents: scatterPay,
      freeSpinsAwarded: spins,
      jackpotHit: jackpot,
    );
  }

  /// Best left-to-right win on one line as (symbol, count), or null.
  /// Wilds substitute for everything except scatters; a pure-wild run is
  /// compared against the substituted run and the bigger pay wins.
  (SlotSymbol, int)? _lineWin(List<SlotSymbol> syms) {
    if (syms.first.isScatter) return null;

    var wildRun = 0;
    while (wildRun < syms.length && syms[wildRun].isWild) {
      wildRun++;
    }
    final wild = syms.firstWhere((s) => s.isWild, orElse: () => config.wild);
    if (wildRun == syms.length) return (wild, wildRun);

    final target = syms[wildRun];
    var run = 0;
    if (!target.isScatter) {
      while (run < syms.length &&
          (syms[run].id == target.id || syms[run].isWild)) {
        run++;
      }
    }

    int pay(SlotSymbol s, int n) => n >= 3 ? s.pays[n - 3] : 0;
    final targetPay = pay(target, run);
    final wildPay = pay(wild, wildRun);
    if (targetPay == 0 && wildPay == 0) return null;
    return wildPay > targetPay ? (wild, wildRun) : (target, run);
  }
}
