// Pure Dart (no Flutter imports) so the math can run in tools and tests.
import '../slot_engine/slot_config.dart';

const _dir = 'assets/images/fortune_mahjong';

/// Fortune Mahjong: mahjong-tile fortune slot. 5x3, 20 lines, fortune-god
/// WILD, gold tile scatter.
final fortuneMahjongConfig = SlotConfig(
  id: 'fortune_mahjong',
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
      pays: [10, 50, 155],
    ),
    SlotSymbol(
      id: 'k',
      kind: SymbolKind.low,
      label: 'K',
      color: 0xFF8E3FD6,
      pays: [25, 65, 190],
    ),
    SlotSymbol(
      id: 'a',
      kind: SymbolKind.low,
      label: 'A',
      color: 0xFFE0307A,
      pays: [25, 75, 255],
    ),
    SlotSymbol(
      id: 'wind',
      kind: SymbolKind.high,
      label: '🀀',
      color: 0xFF5A0A2A,
      pays: [40, 100, 385],
    ),
    SlotSymbol(
      id: 'characters',
      kind: SymbolKind.high,
      label: '萬',
      color: 0xFF6A4A00,
      pays: [50, 130, 515],
    ),
    SlotSymbol(
      id: 'circles',
      kind: SymbolKind.high,
      label: '🀙',
      color: 0xFF5A3A0A,
      pays: [65, 190, 640],
    ),
    SlotSymbol(
      id: 'bamboo',
      kind: SymbolKind.high,
      label: '🎋',
      color: 0xFF0A2A6A,
      pays: [75, 255, 1025],
    ),
    SlotSymbol(
      id: 'red_dragon',
      kind: SymbolKind.high,
      label: '🀄',
      color: 0xFFB0122A,
      pays: [100, 385, 1285],
    ),
    SlotSymbol(
      id: 'wild',
      kind: SymbolKind.wild,
      label: '🧧\nWILD',
      color: 0xFFD6127A,
      pays: [130, 640, 2570],
    ),
    SlotSymbol(
      id: 'bonus',
      kind: SymbolKind.scatter,
      label: '🀫\nFREE',
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
        'wind': 4,
        'characters': 4,
        'circles': 3,
        'bamboo': 3,
        'red_dragon': 2,
        'wild': r == 0 ? 1 : 2,
        'bonus': r.isOdd ? 2 : 1,
      }, 4000 + r),
  ],
  scatterPays: const {3: 2, 4: 10, 5: 50},
  freeSpins: const {3: 10, 4: 15, 5: 25},
  freeSpinMultiplier: 3,
  retriggerSpins: 5,
  betStepsCents: const [2000, 5000, 10000, 20000, 50000, 100000, 200000],
  background: '$_dir/fm_bg.jpg',
);
