// Pure Dart (no Flutter imports) so the math can run in tools and tests.
import '../slot_engine/slot_config.dart';

const _dir = 'assets/images/lucky_dragon';

/// Lucky Dragon: Chinese-fortune slot. 5x3, 20 lines, dragon WILD, gold
/// pearl scatter. Tuned with tool/simulate.dart to roughly 95% return.
final luckyDragonConfig = SlotConfig(
  id: 'lucky_dragon',
  symbols: const [
    SlotSymbol(
      id: 'ten',
      kind: SymbolKind.low,
      label: '10',
      color: 0xFFE07A1F,
      pays: [10, 35, 110],
    ),
    SlotSymbol(
      id: 'j',
      kind: SymbolKind.low,
      label: 'J',
      color: 0xFF2FA84F,
      pays: [10, 35, 110],
    ),
    SlotSymbol(
      id: 'q',
      kind: SymbolKind.low,
      label: 'Q',
      color: 0xFF2F6FD6,
      pays: [10, 45, 135],
    ),
    SlotSymbol(
      id: 'k',
      kind: SymbolKind.low,
      label: 'K',
      color: 0xFF8E3FD6,
      pays: [20, 55, 165],
    ),
    SlotSymbol(
      id: 'a',
      kind: SymbolKind.low,
      label: 'A',
      color: 0xFFE0307A,
      pays: [20, 65, 220],
    ),
    SlotSymbol(
      id: 'coins',
      kind: SymbolKind.high,
      label: '🪙',
      color: 0xFF5A0A2A,
      asset: '$_dir/ld_coins.png',
      pays: [35, 85, 330],
    ),
    SlotSymbol(
      id: 'lantern',
      kind: SymbolKind.high,
      label: '🏮',
      color: 0xFF6A4A00,
      asset: '$_dir/ld_lantern.png',
      pays: [45, 110, 440],
    ),
    SlotSymbol(
      id: 'koi',
      kind: SymbolKind.high,
      label: '🐟',
      color: 0xFF5A3A0A,
      asset: '$_dir/ld_koi.png',
      pays: [55, 165, 550],
    ),
    SlotSymbol(
      id: 'ingot',
      kind: SymbolKind.high,
      label: '💰',
      color: 0xFF0A2A6A,
      asset: '$_dir/ld_ingot.png',
      pays: [65, 220, 880],
    ),
    SlotSymbol(
      id: 'envelope',
      kind: SymbolKind.high,
      label: '🧧',
      color: 0xFFB0122A,
      asset: '$_dir/ld_envelope.png',
      pays: [85, 330, 1105],
    ),
    SlotSymbol(
      id: 'wild',
      kind: SymbolKind.wild,
      label: '🐉\nWILD',
      color: 0xFFD6127A,
      asset: '$_dir/ld_wild.png',
      pays: [110, 550, 2205],
    ),
    SlotSymbol(
      id: 'pearl',
      kind: SymbolKind.scatter,
      label: '🔮\nFREE',
      color: 0xFF3A0F7A,
      asset: '$_dir/ld_scatter.png',
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
        'coins': 4,
        'lantern': 4,
        'koi': 3,
        'ingot': 3,
        'envelope': 2,
        'wild': r == 0 ? 1 : 2,
        'pearl': r.isOdd ? 2 : 1,
      }, 3000 + r),
  ],
  scatterPays: const {3: 2, 4: 10, 5: 50},
  freeSpins: const {3: 10, 4: 15, 5: 25},
  freeSpinMultiplier: 3,
  retriggerSpins: 5,
  betStepsCents: const [2000, 5000, 10000, 20000, 50000, 100000, 200000],
  background: '$_dir/ld_bg.jpg',
  frame: '$_dir/ld_frame.png',
  logo: '$_dir/ld_logo.png',
  frameWindow: const [0.104, 0.276, 0.896, 0.796],
);
