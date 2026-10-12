import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On-device key/value store. Loaded once in main() and injected via
/// `storageProvider.overrideWithValue(...)` so reads are synchronous.
final storageProvider = Provider<Storage>(
  (ref) => throw UnimplementedError('storageProvider must be overridden'),
);

class Storage {
  Storage(this._prefs);

  final SharedPreferences _prefs;

  static Future<Storage> load() async =>
      Storage(await SharedPreferences.getInstance());

  /// Returns [fallback] if the key is missing or holds a value of another
  /// type (e.g. corrupted data), instead of throwing.
  int readInt(String key, int fallback) {
    try {
      return _prefs.getInt(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  void writeInt(String key, int value) => _prefs.setInt(key, value);

  bool readBool(String key, bool fallback) {
    try {
      return _prefs.getBool(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  void writeBool(String key, bool value) => _prefs.setBool(key, value);

  String readString(String key, String fallback) {
    try {
      return _prefs.getString(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  void writeString(String key, String value) => _prefs.setString(key, value);
}

/// Storage keys in one place so they never collide.
class StorageKeys {
  static const walletCents = 'wallet_cents';
  static const grandJackpotCents = 'grand_jackpot_cents';
  static String gameJackpotCents(String gameId) => 'jackpot_$gameId';
  static const taskRewardReadyAtMs = 'task_reward_ready_at_ms';
  static const music = 'settings_music';
  static const soundEffects = 'settings_sound_effects';
  static const vibration = 'settings_vibration';
  static const playerName = 'player_name';
  static const playerAvatar = 'player_avatar';
  static const playerLevel = 'player_level';
  static const totalWonCents = 'stats_total_won_cents';
  static const totalSpins = 'stats_total_spins';
}
