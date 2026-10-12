import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage.dart';

/// The four avatars cut from the character sheet, in picker order.
const avatars = {
  'prince': 'assets/images/avatar_prince.png',
  'diva': 'assets/images/avatar_diva.png',
  'tycoon': 'assets/images/avatar_tycoon.png',
  'cat': 'assets/images/avatar_cat.png',
};

class Player {
  const Player({
    required this.name,
    required this.avatarId,
    required this.level,
    required this.totalWonCents,
    required this.totalSpins,
  });

  final String name;
  final String avatarId;
  final int level;
  final int totalWonCents;
  final int totalSpins;

  String get avatarAsset => avatars[avatarId]!;

  Player copyWith({String? name, String? avatarId}) => Player(
    name: name ?? this.name,
    avatarId: avatarId ?? this.avatarId,
    level: level,
    totalWonCents: totalWonCents,
    totalSpins: totalSpins,
  );
}

/// Player profile, saved on every change. Level and stats only start moving
/// once the slot games exist.
final playerProvider = NotifierProvider<PlayerNotifier, Player>(
  PlayerNotifier.new,
);

class PlayerNotifier extends Notifier<Player> {
  static const defaultName = 'Player';
  static const maxNameLength = 14;

  Storage get _storage => ref.read(storageProvider);

  @override
  Player build() {
    final avatarId = _storage.readString(StorageKeys.playerAvatar, 'prince');
    final name = _storage.readString(StorageKeys.playerName, defaultName);
    return Player(
      name: _clean(name),
      avatarId: avatars.containsKey(avatarId) ? avatarId : 'prince',
      level: _storage.readInt(StorageKeys.playerLevel, 1).clamp(1, 999),
      totalWonCents: _storage.readInt(StorageKeys.totalWonCents, 0),
      totalSpins: _storage.readInt(StorageKeys.totalSpins, 0),
    );
  }

  static String _clean(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return defaultName;
    return t.length > maxNameLength ? t.substring(0, maxNameLength) : t;
  }

  void setName(String raw) {
    final name = _clean(raw);
    state = state.copyWith(name: name);
    _storage.writeString(StorageKeys.playerName, name);
  }

  void setAvatar(String id) {
    if (!avatars.containsKey(id)) return;
    state = state.copyWith(avatarId: id);
    _storage.writeString(StorageKeys.playerAvatar, id);
  }
}
