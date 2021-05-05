// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';
import 'package:c_school_app/app/core/service/app_state_service.dart';
import 'package:pedantic/pedantic.dart';

// 📦 Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sound_lite/flutter_sound.dart' hide PlayerState;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioService extends GetxService {
  static const LAN_CODE_JP = 'ja';

  /// Key of client using this service, one can observe this key
  /// to know if they still connected to the service
  final RxString clientKey = ''.obs;

  /// State of main player
  late PlayerState _playerState;

  String? _lastRecordPath;

  /// Main audio player we use
  final _player = AudioPlayer();

  /// State indicate player is occupied
  final _playerOccupiedState = [
    ProcessingState.loading,
    ProcessingState.buffering,
    ProcessingState.ready
  ];

  /// Recorder
  final _recorder = FlutterSoundRecorder();

  /// System Tts as fallback if no audio file is available
  final _tts = FlutterTts();

  @override
  void onClose() {
    _player.dispose();
    _recorder.closeAudioSession();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _player.playerStateStream.listen((state) {
      _playerState = state;
      if (!_playerOccupiedState.contains(state.processingState)) {
        clientKey.value = '';
      }
    });
    ever<double>(Get.find<AppStateService>().audioSpeed,
        (speed) => _player.setSpeed(speed));
    // Set up tts
    _tts.setSpeechRate(0.5);
    _tts.setLanguage(LAN_CODE_JP);
  }

  /// Pre-loading audio
  void prepareAudio(String url) {
    // We don't wait for this
    DefaultCacheManager().getSingleFile(url);
  }

  /// Play [uri]provided, if other thing is playing, stop it and play the new audio.
  ///
  /// Either web url or file path can be used, the type will be inferred automatically
  /// by checking if the uri start with 'http' (network) or not (file)
  /// If void [callback] is provided, it will get called after play completed.
  ///
  /// Use [from] and [to] to specify a range to play, when [to] is hit, player will be PAUSED.
  /// This is ideal if you want to play a different range of the same audio, so we don't need the
  /// stop -> start cycle. In which case, remember to provide the same key for both call of this method.
  ///
  /// If speed is not specified, speed from AppStateService will be used.
  Future<void> startPlayer(
      {required String uri,
      Function? callback,
      String key = '',
      bool forceRestart = false,
      Duration? from,
      Duration? to}) async {
    // If stopped, not point to call stop again
    // If forceRestart, restart
    // If a new audio, restart
    // Event key is the same. If both are empty key, restart
    if (_playerState.processingState != ProcessingState.idle && forceRestart ||
        clientKey.value != key ||
        key != '') {
      await stopPlayer();
    }
    // Set clientKey to new key
    clientKey.value = key;
    // Always cache the audio
    final filePath = uri.startsWith('http')
        ? (await DefaultCacheManager().getSingleFile(uri)).path
        : uri;
    await _player.setFilePath(filePath);
    await _player.setClip(start: from, end: to);
    unawaited(_player.play().then((_) {
      if (callback != null) {
        callback();
      }
    }));
  }

  /// Pause the player
  void pausePlayer() {
    _player.pause();
  }

  /// Resume the player
  void resumePlayer() {
    _player.play();
  }

  /// Stop the player
  Future<void> stopPlayer() async {
    await _player.stop();
  }

  Future<Duration> durationOfAudio(String uri) async {
    if (uri.startsWith('http')) {
      await _player.setUrl(uri);
    } else {
      await _player.setFilePath(uri);
    }
    return _player.duration!;
  }

  /// Only used to play
  Future<void> speak(String text) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
  }

  Future<void> speakList(Iterable<String> texts) async {
    for (var text in texts) {
      await speak(text);
    }
  }

  /// Start recording
  Future<void> startRecorder() async {
    // Verify permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar('error.oops'.tr, 'error.permission.mic'.tr);
      return;
    }
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    } else {
      await _recorder.openAudioSession();
    }
    final tempDir = (await getTemporaryDirectory()).path;
    _lastRecordPath = '$tempDir/${Uuid().v1()}.wav';
    await _recorder.startRecorder(
        toFile: _lastRecordPath, codec: Codec.pcm16WAV);
  }

  /// Stop recording and return recorded file
  Future<File> stopRecorder() async {
    assert(_recorder.isRecording);
    await _recorder.stopRecorder();
    await _recorder.closeAudioSession();
    return File(_lastRecordPath!);
  }
}
