import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool _initialized = false;
  static bool _bgmStarted = false;
  static bool _muted = false;
  static double _musicVolume = 0.6;
  static double _sfxVolume = 0.8;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setAudioContext(
      AudioContextConfig(
        route: AudioContextConfigRoute.system,
        focus: AudioContextConfigFocus.gain,
        respectSilence: false,
      ).build(),
    );
    await _bgmPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setAudioContext(
      AudioContextConfig(
        route: AudioContextConfigRoute.system,
        focus: AudioContextConfigFocus.gain,
        respectSilence: false,
      ).build(),
    );
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  static Future<void> playBgm() async {
    try {
      if (_muted || _musicVolume <= 0) return;
      if (_bgmStarted) {
        await _bgmPlayer.setVolume(_musicVolume);
        await _bgmPlayer.resume();
        return;
      }
      await _bgmPlayer.setSource(AssetSource('audio/bg_music.mp3'));
      await _bgmPlayer.setVolume(_musicVolume);
      await _bgmPlayer.resume();
      _bgmStarted = true;
    } catch (_) {}
  }

  static Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _bgmStarted = false;
    } catch (_) {}
  }

  static Future<void> playTap() async {
    await _playSfx('audio/tap.wav');
  }

  static Future<void> playCorrect() async {
    await _playSfx('audio/correct.wav');
  }

  static Future<void> playWrong() async {
    await _playSfx('audio/wrong.wav');
  }

  static Future<void> playLevelUp() async {
    await _playSfx('audio/level_up.wav');
  }

  static Future<void> _playSfx(String asset) async {
    try {
      if (_muted) return;
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  static bool get muted => _muted;
  static double get musicVolume => _musicVolume;
  static double get sfxVolume => _sfxVolume;

  static Future<void> setMuted(bool value) async {
    _muted = value;
    if (_muted) {
      await _bgmPlayer.pause();
    } else {
      await playBgm();
    }
  }

  static Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_musicVolume);
    if (_muted) return;

    if (_musicVolume == 0) {
      await _bgmPlayer.pause();
      return;
    }

    await playBgm();
  }

  static Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
  }
}
