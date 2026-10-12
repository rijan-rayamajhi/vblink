// Pure Dart (no Flutter imports) so the math can run in tools and tests.
import '../slot_engine/slot_config.dart';

const _dir = 'assets/images/neon_7s';

/// Neon 7s: classic Vegas neon slot. 5x3, 20 lines, neon WILD sign, star
/// scatter. Tuned with tool/simulate.dart to roughly 95% return.
final neon7sConfig = SlotConfig(
  id: 'neon_7s',
  symbols: const [
    SlotSymbol(
      id: 'ten',
      kind: SymbolKind.low,
      label: '10',
      color: 0xFFE07A1F,
      pays: [10, 40, 130],
    ),
    SlotSymbol(
      id: 'j',
      kind: SymbolKind.low,
      label: 'J',
      color: 0xFF2FA84F,
      pays: [10, 40, 130],
    ),
    SlotSymbol(
      id: 'q',
      kind: SymbolKind.low,
      label: 'Q',
      color: 0xFF2F6FD6,
      pays: [10, 55, 155],
    ),
    SlotSymbol(
      id: 'k',
      kind: SymbolKind.low,
      label: 'K',
      color: 0xFF8E3FD6,
      pays: [25, 65, 195],
    ),
    SlotSymbol(
      id: 'a',
      kind: SymbolKind.low,
      label: 'A',
      color: 0xFFE0307A,
      pays: [25, 75, 260],
    ),
    SlotSymbol(
      id: 'cherry',
      kind: SymbolKind.high,
      label: '🍒',
      color: 0xFF5A0A2A,
      pays: [40, 100, 385],
    ),
    SlotSymbol(
      id: 'bar',
      kind: SymbolKind.high,
      label: 'BAR',
      color: 0xFF6A4A00,
      pays: [55, 130, 515],
    ),
    SlotSymbol(
      id: 'bell',
      kind: SymbolKind.high,
      label: '🔔',
      color: 0xFF5A3A0A,
      pays: [65, 195, 645],
    ),
    SlotSymbol(
      id: 'diamond',
      kind: SymbolKind.high,
      label: '💎',
      color: 0xFF0A2A6A,
      pays: [75, 260, 1030],
    ),
    SlotSymbol(
      id: 'seven',
      kind: SymbolKind.high,
      label: '7',
      color: 0xFFB0122A,
      pays: [100, 385, 1290],
    ),
    SlotSymbol(
      id: 'wild',
      kind: SymbolKind.wild,
      label: 'WILD',
      color: 0xFFD6127A,
      asset: '$_dir/n7_wild.png',
      pays: [130, 645, 2580],
    ),
    SlotSymbol(
      id: 'star',
      kind: SymbolKind.scatter,
      label: '⭐\nFREE',
      color: 0xFF3A0F7A,
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
        'cherry': 4,
        'bar': 4,
        'bell': 3,
        'diamond': 3,
        'seven': 2,
        'wild': r == 0 ? 1 : 2,
        'star': r.isOdd ? 2 : 1,
      }, 2000 + r),
  ],
  scatterPays: const {3: 2, 4: 10, 5: 50},
  freeSpins: const {3: 10, 4: 15, 5: 25},
  freeSpinMultiplier: 3,
  retriggerSpins: 5,
  betStepsCents: const [2000, 5000, 10000, 20000, 50000, 100000, 200000],
  background: '$_dir/n7_bg.jpg',
  frame: '$_dir/n7_frame.png',
  frameWindow: const [0.108, 0.235, 0.893, 0.782],
  logo: '$_dir/n7_logo.png',
);
