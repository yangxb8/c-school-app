// 📦 Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'app_state_service.dart';

class AudioService extends GetxService {
  static const LAN_CODE_JP = 'ja';

  /// Main audio player we use
  final AudioPlayer _audioPlayer = AudioPlayer();

  final FlutterTts _tts = FlutterTts();

  /// State of main player
  final Rx<AudioPlayerState> playerState = AudioPlayerState.STOPPED.obs;

  /// State indicate player is occupied
  final List<AudioPlayerState> _playerOccupiedState = [
    AudioPlayerState.PLAYING,
    AudioPlayerState.PAUSED
  ];

  /// If some worker is waiting for result of play
  Worker _playerListener;

  /// Key of client using this service, one can observe this key
  /// to know if they still connected to the service
  final RxString clientKey = ''.obs;

  @override
  Future<void> onInit() async {
    if (AppStateService.isDebug) {
      AudioPlayer.logEnabled = true;
    }
    // make playerState subscribe to AudioPlayerState change
    _audioPlayer.onPlayerStateChanged.listen((event) => playerState.value = event);
    ever(playerState, (state) {
      // If a play is stopped, related worker will be disposed.
      // Any callback it has will also be disposed
      if (state == AudioPlayerState.STOPPED) {
        _playerListener?.dispose();
      }
      // When play complete, clientKey is cleared
      if (!_playerOccupiedState.contains(state)) {
        clientKey.value = '';
      }
    });
    // Set up tts
    await _tts.setSpeechRate(0.5);
    await _tts.setLanguage(LAN_CODE_JP);
    super.onInit();
  }

  /// Pre-loading audio
  void prepareAudio(String url) {
    // We don't wait for this
    DefaultCacheManager().getSingleFile(url);
  }

  /// Play url provided, if other thing is playing, stop it and play the new audio.
  /// If void callback is provided, it will get called after play completed.
  ///
  /// WARN: If play was stopped (other audio want to play etc.), the callback will not be called.
  Future<void> play(String url, {Function callback, String key = ''}) async {
    clientKey.value = key;
    // Always cache the audio
    final localUri = (await DefaultCacheManager().getSingleFile(url)).path;
    await _audioPlayer.play(localUri, isLocal: true, position: 0.seconds);
    if (callback != null) {
      _playerListener = once(playerState, (_) async => await callback(),
          condition: () => playerState.value == AudioPlayerState.COMPLETED);
    }
  }

  Future<void> pause() async {
    if (playerState.value == AudioPlayerState.PLAYING) {
      await _audioPlayer.pause();
    }
  }

  Future<void> resume() async {
    if (playerState.value == AudioPlayerState.PAUSED) {
      await _audioPlayer.resume();
    }
  }

  Future<void> stop() async {
    if (_playerOccupiedState.contains(playerState.value)) {
      await _audioPlayer.stop();
    }
  }

  /// Only used to play
  Future<void> speak(String text, {Function callback}) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
    if (callback != null) {
      await callback();
    }
  }

  Future<void> speakList(Iterable<String> texts, {Function callback}) async {
    await Future.forEach(texts, (text) async {
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    });
    if (callback != null) {
      await callback();
    }
  }

  @override
  void onClose() {
    if (_audioPlayer != null) {
      _audioPlayer.dispose();
    }
    if (_playerListener != null) {
      _playerListener.dispose();
    }
    super.onClose();
  }
}
