import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/games/slot_engine/slot_config.dart';
import 'package:vblink/games/slot_engine/slot_math.dart';

/// Tiny hand-made game so every grid in these tests is exact.
/// Strip rows: index i shows strip[i], strip[i+1], strip[i+2].
SlotConfig _config(List<List<String>> strips) => SlotConfig(
  id: 'test',
  symbols: const [
    SlotSymbol(
      id: 'a',
      kind: SymbolKind.low,
      label: 'A',
      color: 0,
      pays: [5, 10, 20],
    ),
    SlotSymbol(
      id: 'b',
      kind: SymbolKind.low,
      label: 'B',
      color: 0,
      pays: [2, 4, 8],
    ),
    SlotSymbol(
      id: 'h',
      kind: SymbolKind.high,
      label: 'H',
      color: 0,
      pays: [50, 100, 200],
    ),
    SlotSymbol(
      id: 'w',
      kind: SymbolKind.wild,
      label: 'W',
      color: 0,
      pays: [10, 30, 500],
    ),
    SlotSymbol(id: 's', kind: SymbolKind.scatter, label: 'S', color: 0),
  ],
  strips: strips,
  scatterPays: const {3: 2, 4: 10, 5: 50},
  freeSpins: const {3: 10, 4: 15, 5: 25},
  freeSpinMultiplier: 3,
  retriggerSpins: 5,
  betStepsCents: const [2000, 200000],
);

/// Builds strips so that stop 0 shows exactly [top, mid, bot] per reel.
List<List<String>> _grid(
  List<String> top,
  List<String> mid,
  List<String> bot,
) => [
  for (var r = 0; r < 5; r++) [top[r], mid[r], bot[r]],
];

const _bet = 2000; // 20 coins -> line bet 1 coin (100 cents)

void main() {
  test('the 20 standard lines are valid for a 5x3 grid', () {
    expect(SlotConfig.standardLines, hasLength(20));
    for (final line in SlotConfig.standardLines) {
      expect(line, hasLength(5));
      expect(line.every((row) => row >= 0 && row < 3), isTrue);
    }
  });

  test('three of a kind on the middle line pays left to right', () {
    final math = SlotMath(
      _config(
        _grid(['b', 'h', 'b', 'h', 'b'], ['a', 'a', 'a', 'b', 'h'], [
          'h',
          'b',
          'h',
          'b',
          'h',
        ]),
      ),
    );
    final r = math.evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);

    final mid = r.lineWins.where((w) => w.line == 0).single;
    expect(mid.symbolId, 'a');
    expect(mid.count, 3);
    expect(mid.payCents, 5 * 100);
  });

  test('a win must start on reel 1', () {
    final math = SlotMath(
      _config(
        _grid(['h', 'b', 'h', 'b', 'h'], ['b', 'a', 'a', 'a', 'a'], [
          'h',
          'b',
          'h',
          'b',
          'h',
        ]),
      ),
    );
    final r = math.evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);
    expect(r.lineWins.where((w) => w.line == 0), isEmpty);
  });

  test('wild substitutes and the bigger of wild-run and symbol-run pays', () {
    final math = SlotMath(
      _config(
        _grid(['b', 'b', 'h', 'b', 'h'], ['w', 'w', 'a', 'a', 'b'], [
          'h',
          'h',
          'b',
          'h',
          'b',
        ]),
      ),
    );
    final r = math.evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);

    // W W A A = four A (10) beats two wilds (no pay).
    final mid = r.lineWins.where((w) => w.line == 0).single;
    expect(mid.symbolId, 'a');
    expect(mid.count, 4);
    expect(mid.payCents, 10 * 100);
  });

  test('a pure wild run can beat the substituted symbol', () {
    final math = SlotMath(
      _config(
        _grid(['b', 'b', 'b', 'h', 'h'], ['w', 'w', 'w', 'b', 'a'], [
          'h',
          'h',
          'h',
          'b',
          'b',
        ]),
      ),
    );
    final r = math.evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);

    // W W W B = four B (4) vs three wilds (10): wilds win.
    final mid = r.lineWins.where((w) => w.line == 0).single;
    expect(mid.symbolId, 'w');
    expect(mid.count, 3);
  });

  test('five wilds on a line hit the jackpot', () {
    final math = SlotMath(
      _config(
        _grid(['b', 'h', 'b', 'h', 'b'], ['w', 'w', 'w', 'w', 'w'], [
          'h',
          'b',
          'h',
          'b',
          'h',
        ]),
      ),
    );
    final r = math.evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);
    expect(r.jackpotHit, isTrue);
  });

  test('scatters pay anywhere, never on lines, and award free spins', () {
    final math = SlotMath(
      _config(
        _grid(['s', 'b', 'h', 'b', 's'], ['b', 'h', 's', 'h', 'b'], [
          'h',
          'b',
          'b',
          'h',
          'h',
        ]),
      ),
    );
    final r = math.evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);

    expect(r.scatterCount, 3);
    expect(r.scatterPayCents, 2 * _bet);
    expect(r.freeSpinsAwarded, 10);
    expect(r.lineWins.any((w) => w.symbolId == 's'), isFalse);
  });

  test('free spins triple wins and retrigger for +5', () {
    final cfg = _config(
      _grid(['s', 'b', 'h', 'b', 's'], ['a', 'a', 'a', 'h', 'b'], [
        'h',
        'b',
        's',
        'h',
        'h',
      ]),
    );
    final base = SlotMath(cfg).evaluate([0, 0, 0, 0, 0], totalBetCents: _bet);
    final free = SlotMath(cfg)
        .evaluate([0, 0, 0, 0, 0], totalBetCents: _bet, freeSpin: true);

    expect(free.totalCents, base.totalCents * 3);
    expect(free.freeSpinsAwarded, 5);
  });

  test('gridFor wraps around the end of the strip', () {
    final math = SlotMath(
      _config([
        for (var r = 0; r < 5; r++) ['a', 'b', 'h', 'w', 's'],
      ]),
    );
    expect(math.gridFor([4, 4, 4, 4, 4]).first, ['s', 'a', 'b']);
  });
}
