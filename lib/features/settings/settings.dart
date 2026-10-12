import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage.dart';

class Settings {
  const Settings({
    required this.music,
    required this.soundEffects,
    required this.vibration,
  });

  final bool music;
  final bool soundEffects;
  final bool vibration;

  Settings copyWith({bool? music, bool? soundEffects, bool? vibration}) =>
      Settings(
        music: music ?? this.music,
        soundEffects: soundEffects ?? this.soundEffects,
        vibration: vibration ?? this.vibration,
      );
}

/// Player preferences, saved the moment they change. All on by default.
final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<Settings> {
  Storage get _storage => ref.read(storageProvider);

  @override
  Settings build() => Settings(
    music: _storage.readBool(StorageKeys.music, true),
    soundEffects: _storage.readBool(StorageKeys.soundEffects, true),
    vibration: _storage.readBool(StorageKeys.vibration, true),
  );

  void setMusic(bool on) {
    state = state.copyWith(music: on);
    _storage.writeBool(StorageKeys.music, on);
  }

  void setSoundEffects(bool on) {
    state = state.copyWith(soundEffects: on);
    _storage.writeBool(StorageKeys.soundEffects, on);
  }

  void setVibration(bool on) {
    state = state.copyWith(vibration: on);
    _storage.writeBool(StorageKeys.vibration, on);
  }

  /// Light tap feedback, only when vibration is on.
  void tapFeedback() {
    if (state.vibration) HapticFeedback.selectionClick();
  }
}
