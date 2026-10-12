// Pure Dart (no Flutter imports) so the math can run in tools and tests.
import 'dart:math';

enum SymbolKind { low, high, wild, scatter }

class SlotSymbol {
  const SlotSymbol({
    required this.id,
    required this.kind,
    required this.label,
    required this.color,
    this.pays = const [0, 0, 0],
    this.asset,
  });

  final String id;
  final SymbolKind kind;

  /// Line-bet multipliers for 3, 4 and 5 of a kind.
  final List<int> pays;

  /// Placeholder text/emoji and ARGB tile color until [asset] exists.
  final String label;
  final int color;
  final String? asset;

  bool get isWild => kind == SymbolKind.wild;
  bool get isScatter => kind == SymbolKind.scatter;
}

/// Everything that makes one slot game different from another.
class SlotConfig {
  SlotConfig({
    required this.id,
    required this.symbols,
    required this.strips,
    required this.scatterPays,
    required this.freeSpins,
    required this.freeSpinMultiplier,
    required this.retriggerSpins,
    required this.betStepsCents,
    this.lines = standardLines,
  }) : _byId = {for (final s in symbols) s.id: s};

  final String id;
  final List<SlotSymbol> symbols;

  /// One looping strip of symbol ids per reel.
  final List<List<String>> strips;

  /// Row index (0 = top) per reel for each win line.
  final List<List<int>> lines;

  /// Scatter count -> total-bet multiplier, paid anywhere on screen.
  final Map<int, int> scatterPays;

  /// Scatter count -> free spins awarded in the base game.
  final Map<int, int> freeSpins;
  final int freeSpinMultiplier;
  final int retriggerSpins;
  final List<int> betStepsCents;

  final Map<String, SlotSymbol> _byId;

  static const rows = 3;
  int get reels => strips.length;
  int get maxBetCents => betStepsCents.last;

  SlotSymbol symbol(String id) => _byId[id]!;

  SlotSymbol get wild => symbols.firstWhere((s) => s.isWild);

  /// The classic 20 lines for a 5x3 grid.
  static const standardLines = [
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0],
    [2, 2, 2, 2, 2],
    [0, 1, 2, 1, 0],
    [2, 1, 0, 1, 2],
    [0, 0, 1, 2, 2],
    [2, 2, 1, 0, 0],
    [1, 0, 0, 0, 1],
    [1, 2, 2, 2, 1],
    [1, 0, 1, 2, 1],
    [1, 2, 1, 0, 1],
    [0, 1, 1, 1, 0],
    [2, 1, 1, 1, 2],
    [0, 1, 0, 1, 0],
    [2, 1, 2, 1, 2],
    [1, 1, 0, 1, 1],
    [1, 1, 2, 1, 1],
    [0, 0, 2, 0, 0],
    [2, 2, 0, 2, 2],
    [0, 2, 0, 2, 0],
  ];

  /// Builds a strip from symbol weights, shuffled with a fixed seed so the
  /// reels (and therefore the math) are identical on every device.
  static List<String> buildStrip(Map<String, int> weights, int seed) {
    final strip = [
      for (final MapEntry(:key, :value) in weights.entries)
        for (var i = 0; i < value; i++) key,
    ]..shuffle(Random(seed));
    return strip;
  }
}
