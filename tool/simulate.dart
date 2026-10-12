// Plays millions of spins and reports the return-to-player and hit rates.
// Run: dart run tool/simulate.dart [spins]
// ignore_for_file: avoid_print
import 'dart:math';

import 'package:vblink/games/gold_rush_express/config.dart';
import 'package:vblink/games/slot_engine/slot_math.dart';

void main(List<String> args) {
  final spins = args.isEmpty ? 2000000 : int.parse(args.first);
  final math = SlotMath(goldRushConfig);
  final rng = Random(7);
  const bet = 10000;

  var totalBet = 0, won = 0, baseWon = 0, freeWon = 0;
  var hits = 0, triggers = 0, jackpots = 0, biggest = 0;
  for (var i = 0; i < spins; i++) {
    totalBet += bet;
    final r = math.spin(rng, totalBetCents: bet);
    var spinWin = r.totalCents;
    baseWon += r.totalCents;
    if (r.totalCents > 0) hits++;
    if (r.jackpotHit) jackpots++;
    var left = r.freeSpinsAwarded;
    if (left > 0) triggers++;
    while (left > 0) {
      left--;
      final f = math.spin(rng, totalBetCents: bet, freeSpin: true);
      spinWin += f.totalCents;
      freeWon += f.totalCents;
      left += f.freeSpinsAwarded;
      if (f.jackpotHit) jackpots++;
    }
    won += spinWin;
    biggest = max(biggest, spinWin);
  }
  String pct(num a, num b) => '${(100 * a / b).toStringAsFixed(2)}%';
  print('spins            $spins');
  print('RTP              ${pct(won, totalBet)}');
  print('  base game      ${pct(baseWon, totalBet)}');
  print('  free spins     ${pct(freeWon, totalBet)}');
  print('hit rate         ${pct(hits, spins)}');
  print(
    'free spins every ${(spins / max(triggers, 1)).toStringAsFixed(0)} spins',
  );
  print(
    'jackpot every    ${jackpots == 0 ? '-' : (spins / jackpots).toStringAsFixed(0)} spins',
  );
  print('biggest win      ${(biggest / bet).toStringAsFixed(0)}x bet');
}
