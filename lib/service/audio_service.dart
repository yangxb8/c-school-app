// 🎯 Dart imports:
import 'dart:io';

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
  final clientKey = ''.obs;

  String? _lastRecordPath;

  @override
  Future<void> onInit() async {
    // open audio session and keep it
    if(!_player.isOpen()){
      await _player.openAudioSession();
    }
    await _recorder.openAudioSession();
    ever(playerState, (dynamic state) {
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

  /// Play uri provided, if other thing is playing, stop it and play the new audio.
  /// Either web url or file path can be used, the type will be inferred automatically.
  /// If void callback is provided, it will get called after play completed.
  Future<void> startPlayer(String uri, {Function? callback, String? key = ''}) async {
    // If there is another file been played, stop it
    await stopPlayer();
    // Set clientKey to new key
    clientKey.value = key;
    // Always cache the audio
    final bytes = (await DefaultCacheManager().getSingleFile(uri)).readAsBytesSync();
    await _player.startPlayer(
        fromDataBuffer: bytes,
        whenFinished: () {
          if (callback != null) {
            callback();
          }
          refreshPlayerState();
        });
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
    await _recorder.startRecorder(toFile: _lastRecordPath, codec: Codec.pcm16WAV);
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
