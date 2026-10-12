// Pure Dart (no Flutter imports) so the math can run in tools and tests.
import '../slot_engine/slot_config.dart';

const _dir = 'assets/images/gold_rush_express';

/// Gold Rush Express: 5x3, 20 lines, train wild, ticket scatter.
/// Tuned with tool/simulate.dart to roughly 95% return.
final goldRushConfig = SlotConfig(
  id: 'gold_rush_express',
  symbols: const [
    SlotSymbol(
      id: 'ten',
      kind: SymbolKind.low,
      label: '10',
      color: 0xFFE07A1F,
      pays: [10, 35, 120],
    ),
    SlotSymbol(
      id: 'j',
      kind: SymbolKind.low,
      label: 'J',
      color: 0xFF2FA84F,
      pays: [10, 35, 120],
    ),
    SlotSymbol(
      id: 'q',
      kind: SymbolKind.low,
      label: 'Q',
      color: 0xFF2F6FD6,
      pays: [10, 50, 145],
    ),
    SlotSymbol(
      id: 'k',
      kind: SymbolKind.low,
      label: 'K',
      color: 0xFF8E3FD6,
      pays: [25, 60, 180],
    ),
    SlotSymbol(
      id: 'a',
      kind: SymbolKind.low,
      label: 'A',
      color: 0xFFD6304A,
      pays: [25, 70, 240],
    ),
    SlotSymbol(
      id: 'pickaxe',
      kind: SymbolKind.high,
      label: '⛏️',
      color: 0xFF6B4A2E,
      pays: [35, 95, 360],
    ),
    SlotSymbol(
      id: 'lantern',
      kind: SymbolKind.high,
      label: '🏮',
      color: 0xFF7A3A1A,
      pays: [50, 120, 480],
    ),
    SlotSymbol(
      id: 'cart',
      kind: SymbolKind.high,
      label: '🛒',
      color: 0xFF5A3A2A,
      pays: [60, 180, 600],
    ),
    SlotSymbol(
      id: 'gem',
      kind: SymbolKind.high,
      label: '💎',
      color: 0xFF8A1030,
      asset: '$_dir/gre_gem.png',
      pays: [70, 240, 960],
    ),
    SlotSymbol(
      id: 'nugget',
      kind: SymbolKind.high,
      label: '🪙',
      color: 0xFF9A6A00,
      asset: '$_dir/gre_nugget.png',
      pays: [95, 360, 1200],
    ),
    SlotSymbol(
      id: 'wild',
      kind: SymbolKind.wild,
      label: '🚂\nWILD',
      color: 0xFFB0122A,
      asset: '$_dir/gre_wild.png',
      pays: [120, 600, 2400],
    ),
    SlotSymbol(
      id: 'ticket',
      kind: SymbolKind.scatter,
      label: '🎫\nFREE',
      color: 0xFF1F8A3A,
      asset: '$_dir/gre_scatter.png',
    ),
  ],
  strips: [
    for (var r = 0; r < 5; r++)
      SlotConfig.buildStrip({
        'ten': 7,
        'j': 7,
        'q': 6,
        'k': 6,
        'a': 5,
        'pickaxe': 4,
        'lantern': 4,
        'cart': 3,
        'gem': 3,
        'nugget': 2,
        'wild': r == 0 ? 1 : 2,
        'ticket': r.isEven ? 2 : 1,
      }, 1000 + r),
  ],
  scatterPays: const {3: 2, 4: 10, 5: 50},
  freeSpins: const {3: 10, 4: 15, 5: 25},
  freeSpinMultiplier: 3,
  retriggerSpins: 5,
  betStepsCents: const [2000, 5000, 10000, 20000, 50000, 100000, 200000],
);
