// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

// 📦 Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioService extends GetxService {
  static const LAN_CODE_JP = 'ja';

  /// Main audio player we use
  final _player = FlutterSoundPlayer();

  /// System Tts as fallback if no audio file is available
  final _tts = FlutterTts();

  /// Recorder
  final _recorder = FlutterSoundRecorder();

  /// State of main player
  final playerState = PlayerState.isStopped.obs;

  /// State indicate player is occupied
  final _playerOccupiedState = [PlayerState.isPlaying, PlayerState.isPaused];

  /// Key of client using this service, one can observe this key
  /// to know if they still connected to the service
  final RxString clientKey = ''.obs;

  /// Timer of last player
  Timer? currentTimer;

  String? _lastRecordPath;

  @override
  Future<void> onInit() async {
    // open audio session and keep it
    if (!_player.isOpen()) {
      await _player.openAudioSession();
    }
    await _recorder.openAudioSession();
    ever(playerState, (dynamic state) {
      // When play complete, clientKey is cleared
      if (!_playerOccupiedState.contains(state)) {
        clientKey.value = '';
        // If there is a timer, stop it
        currentTimer?.cancel();
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

  /// Play [uri] or [bytes] provided, if other thing is playing, stop it and play the new audio.
  ///
  /// Either web url or file path can be used, the type will be inferred automatically.
  /// If void [callback] is provided, it will get called after play completed.
  ///
  /// Use [from] and [to] to specify a range to play, when [to] is hit, player will be PAUSED.
  /// This is ideal if you want to play a different range of the same audio, so we don't need the
  /// stop -> start cycle. In which case, remember to provide the same key for both call of this method.
  Future<void> startPlayer(
      {String? uri,
      Uint8List? bytes,
      Function? callback,
      String key = '',
      bool forceRestart = false,
      Duration? from,
      Duration? to}) async {
    assert(uri != null || bytes != null);
    if (playerState.value !=
                PlayerState
                    .isStopped && // If stopped, not point to call stop again
            forceRestart || // If forceRestart, restart
        clientKey.value != key || // If a new audio, restart
        key != '') {
      // Event key is the same. If both are empty key, restart
      await stopPlayer();
    }
    // Set clientKey to new key
    clientKey.value = key;
    // Always cache the audio
    final data = bytes ??
        (await DefaultCacheManager().getSingleFile(uri!)).readAsBytesSync();
    // If Player is stopped, start it
    if (playerState.value == PlayerState.isStopped) {
      await _player.startPlayer(
          fromDataBuffer: data,
          whenFinished: () {
            if (callback != null) {
              callback();
            }
            refreshPlayerState();
          });
    }
    if (from != null) {
      await _player.seekToPlayer(from);
      await resumePlayer(); // Resume play if it was paused before
    }
    if (to != null) {
      var start = from ?? 0.seconds;
      var duration = to - start;
      Timer(duration, () => _player.pausePlayer());
    }
    refreshPlayerState();
  }

  /// Pause the player
  Future<void> pausePlayer() async {
    if (playerState.value == PlayerState.isPlaying) {
      await _player.pausePlayer();
      refreshPlayerState();
    }
  }

  /// Resume the player
  Future<void> resumePlayer() async {
    if (playerState.value == PlayerState.isPaused) {
      await _player.resumePlayer();
      refreshPlayerState();
    }
  }

  /// Stop the player
  Future<void> stopPlayer() async {
    await _player.stopPlayer();
    refreshPlayerState();
  }

  /// Only used to play
  Future<void> speak(String text, {Function? callback}) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
    if (callback != null) {
      await callback();
    }
  }

  Future<void> speakList(Iterable<String> texts, {Function? callback}) async {
    await Future.forEach(texts, (dynamic text) async {
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    });
    if (callback != null) {
      await callback();
    }
  }

  /// Start recording
  Future<void> startRecorder() async {
    // Verify permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar('error.oops'.tr, 'error.permission.mic'.tr);
    }
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    final tempDir = (await getTemporaryDirectory()).path;
    _lastRecordPath = '$tempDir/${Uuid().v1()}';
    await _recorder.startRecorder(
        toFile: _lastRecordPath, codec: Codec.pcm16WAV);
  }

  /// Stop recording and return recorded file
  Future<File> stopRecorder() async {
    assert(_recorder.isRecording);
    await _recorder.stopRecorder();
    return File(_lastRecordPath!);
  }

  void refreshPlayerState() => playerState.value = _player.playerState;

  @override
  void onClose() {
    _player.closeAudioSession();
    _recorder.closeAudioSession();
    super.onClose();
  }
}
