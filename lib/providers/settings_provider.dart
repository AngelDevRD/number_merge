import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

class SettingsState {
  final AppThemeMode themeMode;
  final bool soundOn;
  final bool vibrationOn;
  final bool onboardingShown;
  final bool loaded;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.soundOn = true,
    this.vibrationOn = true,
    this.onboardingShown = false,
    this.loaded = false,
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    bool? soundOn,
    bool? vibrationOn,
    bool? onboardingShown,
    bool? loaded,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      soundOn: soundOn ?? this.soundOn,
      vibrationOn: vibrationOn ?? this.vibrationOn,
      onboardingShown: onboardingShown ?? this.onboardingShown,
      loaded: loaded ?? this.loaded,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final themeMode = await _repo.getThemeMode();
    final soundOn = await _repo.getSoundOn();
    final vibrationOn = await _repo.getVibrationOn();
    final onboardingShown = await _repo.getOnboardingShown();
    state = state.copyWith(
      themeMode: themeMode,
      soundOn: soundOn,
      vibrationOn: vibrationOn,
      onboardingShown: onboardingShown,
      loaded: true,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.setThemeMode(mode);
  }

  Future<void> setSoundOn(bool value) async {
    state = state.copyWith(soundOn: value);
    await _repo.setSoundOn(value);
  }

  Future<void> setVibrationOn(bool value) async {
    state = state.copyWith(vibrationOn: value);
    await _repo.setVibrationOn(value);
  }

  Future<void> setOnboardingShown(bool value) async {
    state = state.copyWith(onboardingShown: value);
    await _repo.setOnboardingShown(value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref.watch(settingsRepositoryProvider));
  },
);
