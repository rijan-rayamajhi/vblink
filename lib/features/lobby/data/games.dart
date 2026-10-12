import 'dart:ui';

enum GameBadge { hot, isNew }

/// One lobby game. [art] is null until its cover image arrives.
class GameInfo {
  const GameInfo({
    required this.id,
    required this.title,
    required this.badge,
    required this.jackpotSeedCents,
    required this.colors,
    this.art,
    this.unlockLevel = 1,
  });

  final String id;
  final String title;
  final GameBadge badge;
  final int jackpotSeedCents;

  /// Placeholder gradient shown while [art] is missing.
  final List<Color> colors;
  final String? art;
  final int unlockLevel;
}

/// The featured game gets the big portrait tile.
const featuredGame = GameInfo(
  id: 'gold_rush_express',
  title: 'GOLD RUSH EXPRESS',
  badge: GameBadge.hot,
  jackpotSeedCents: 155619426,
  colors: [Color(0xFFFFB238), Color(0xFFB0127A)],
  art: 'assets/images/game_gold_rush_express.jpg',
);

/// The four games in the 2x2 grid, in reading order.
const gridGames = [
  GameInfo(
    id: 'neon_7s',
    title: 'NEON 7s',
    badge: GameBadge.hot,
    jackpotSeedCents: 29575291,
    colors: [Color(0xFFFF3D9A), Color(0xFF3A0F7A)],
    art: 'assets/images/game_neon_7s.jpg',
  ),
  GameInfo(
    id: 'lucky_dragon',
    title: 'LUCKY DRAGON',
    badge: GameBadge.isNew,
    jackpotSeedCents: 15228725,
    colors: [Color(0xFFE5322B), Color(0xFF5A0A1E)],
    art: 'assets/images/game_lucky_dragon.jpg',
  ),
  GameInfo(
    id: 'fortune_mahjong',
    title: 'FORTUNE MAHJONG',
    badge: GameBadge.isNew,
    jackpotSeedCents: 1044783,
    colors: [Color(0xFF1FAF6B), Color(0xFF0B3B2A)],
    art: 'assets/images/game_fortune_mahjong.jpg',
  ),
  GameInfo(
    id: 'olympus_riches',
    title: 'OLYMPUS RICHES',
    badge: GameBadge.hot,
    jackpotSeedCents: 22619671,
    colors: [Color(0xFF3FA0FF), Color(0xFF1A2A7A)],
    art: 'assets/images/game_olympus_riches.jpg',
  ),
];

const allGames = [featuredGame, ...gridGames];
