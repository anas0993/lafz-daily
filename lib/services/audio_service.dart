import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background music + short sound effects for Word Daily (v4.1).
///
/// All state is static and lazily initialized; [init] is safe to call
/// multiple times and is invoked automatically by every public entry point.
class AudioService {
  AudioService._();

  static const _musicPrefKey = 'wd_music_on';
  static const _sfxPrefKey = 'wd_sfx_on';

  static bool _initialized = false;
  static bool _musicOn = true;
  static bool _sfxOn = true;
  static bool _musicPlaying = false;

  static AudioPlayer? _music;
  static final List<AudioPlayer> _sfxPool = [];
  static int _sfxIndex = 0;

  static bool get musicOn => _musicOn;
  static bool get sfxOn => _sfxOn;

  static Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _musicOn = prefs.getBool(_musicPrefKey) ?? true;
    _sfxOn = prefs.getBool(_sfxPrefKey) ?? true;
    WidgetsBinding.instance.addObserver(_AudioLifecycle());
    _initialized = true;
  }

  static Future<void> setMusicOn(bool value) async {
    await init();
    _musicOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicPrefKey, value);
    if (value) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  static Future<void> setSfxOn(bool value) async {
    await init();
    _sfxOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxPrefKey, value);
  }

  /// Starts the looping background track. No-op when music is off or
  /// already playing.
  static Future<void> startMusic() async {
    await init();
    if (!_musicOn || _musicPlaying) return;
    try {
      _music ??= AudioPlayer();
      await _music!.setReleaseMode(ReleaseMode.loop);
      await _music!.setVolume(0.35);
      await _music!.play(AssetSource('audio/bg_music.wav'));
      _musicPlaying = true;
    } catch (_) {
      _musicPlaying = false;
    }
  }

  static Future<void> stopMusic() async {
    if (!_musicPlaying) return;
    try {
      await _music?.stop();
    } catch (_) {}
    _musicPlaying = false;
  }

  // ---------------------------------------------------------------- SFX --

  static AudioPlayer _nextSfxPlayer() {
    if (_sfxPool.length < 4) {
      for (var i = _sfxPool.length; i < 4; i++) {
        _sfxPool.add(AudioPlayer());
      }
    }
    final player = _sfxPool[_sfxIndex % _sfxPool.length];
    _sfxIndex++;
    return player;
  }

  static Future<void> _playSfx(String asset, {double volume = 0.7}) async {
    if (!_sfxOn) return;
    try {
      await init();
      await _nextSfxPlayer().play(AssetSource('audio/$asset'), volume: volume);
    } catch (_) {}
  }

  static Future<void> playClick() => _playSfx('sfx_click.wav', volume: 0.6);
  static Future<void> playDing() => _playSfx('sfx_ding.wav', volume: 0.8);
  static Future<void> playWin() => _playSfx('sfx_win.wav', volume: 0.8);
  static Future<void> playError() => _playSfx('sfx_error.wav', volume: 0.6);
  static Future<void> playHint() => _playSfx('sfx_hint.wav', volume: 0.8);

  // ------------------------------------------------------- app lifecycle --

  /// Pauses the music when the app leaves the foreground.
  static void _onBackground() {
    if (!_musicPlaying) return;
    try {
      _music?.pause();
    } catch (_) {}
    _musicPlaying = false;
  }

  /// Resumes the music when the app returns, if music is enabled.
  static void _onForeground() {
    if (_musicOn) {
      // Fire and forget — resume must not block the lifecycle callback.
      startMusic();
    }
  }
}

/// Routes app lifecycle events into [AudioService]'s background/foreground
/// pause-resume handling.
class _AudioLifecycle extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        AudioService._onBackground();
      case AppLifecycleState.resumed:
        AudioService._onForeground();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
