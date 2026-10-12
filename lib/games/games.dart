import 'gold_rush_express/config.dart';
import 'lucky_dragon/config.dart';
import 'neon_7s/config.dart';
import 'slot_engine/slot_config.dart';

/// Playable games by lobby id. Games not listed here show "coming soon".
final playableGames = <String, SlotConfig>{
  goldRushConfig.id: goldRushConfig,
  neon7sConfig.id: neon7sConfig,
  luckyDragonConfig.id: luckyDragonConfig,
};
