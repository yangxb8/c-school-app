// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flamingo/flamingo.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pedantic/pedantic.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import '../../../data/model/api_request/soe_request.dart';
import '../../../data/model/api_request/tts_request.dart';
import '../../../data/model/exam/speech_evaluation_result.dart';
import '../../../data/model/exam/speech_exam.dart';
import '../../../data/model/user/user.dart';
import '../../../data/repository/user_repository.dart';
import '../../../data/service/logger_service.dart';
import '../index.dart';

// 🌎 Project imports:



// 🌎 Project imports:

final logger = LoggerService.logger;

class FirebaseAuthApiHelper {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/user.gender.read',
      'https://www.googleapis.com/auth/user.birthday.read',
      'https://www.googleapis.com/auth/user.organization.read'
    ],
  );
  final UserRepository _userRepository = Get.find<UserRepository>();

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> signUpWithEmail(
      String email, String password, String nickname) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await _userRepository
          .register(AppUser(id: userCredential.user!.uid)..nickName = nickname);
      if (!userCredential.user!.emailVerified) {
        await sendVerifyEmail();
        return 'need email verify';
      }
      logger.d(email, 'User registered:');
      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'login.register.error.registeredEmail'.tr;
      }
    } catch (e) {
      logger.e(e);
      return 'error.unknown.content'.tr;
    } finally {
      return 'error.unknown.content'.tr;
    }
  }

  Future<void> sendVerifyEmail() async {
    final firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
    await firebaseUser!.reload();
    await firebaseUser.sendEmailVerification();
  }

  // Already return from every conditions
  // ignore: missing_return
  Future<String> loginWithEmail(String email, String password) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!userCredential.user!.emailVerified) {
        return 'login.login.error.unverifiedEmail'.tr;
      }
      await _userRepository.refresh();
      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'login.login.error.unregisteredEmail'.tr;
      } else if (e.code == 'wrong-password') {
        return 'login.login.error.wrongPassword'.tr;
      } else {
        return 'error.unknown.content'.tr;
      }
    } catch (e) {
      logger.e(e.toString());
      return 'error.unknown.content'.tr;
    }
  }

  Future<String> loginWithGoogle() async {
    try {
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'abort';
      }
      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      var userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _userRepository.registerOrRefresh(
          AppUser(id: userCredential.user!.uid)
            ..nickName = googleUser.displayName!);
      return 'ok';
    } catch (e) {
      logger.e(e.toString());
      return 'error.unknown.content'.tr;
    }
  }

  //TODO: Twitter Developer Portal has a callback URL of twittersdk:// for Android, and twitterkit-CONSUMERKEY:// for iOS.
  Future<String> loginWithTwitter() async {
    throw UnimplementedError();
  }

  Future<String> loginWithApple() async {
    /// Generates a cryptographically secure random nonce, to be included in a
    /// credential request.
    String generateNonce([int length = 32]) {
      final charset =
          '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
      final random = Random.secure();
      return List.generate(
          length, (_) => charset[random.nextInt(charset.length)]).join();
    }

    /// Returns the sha256 hash of [input] in hex notation.
    String sha256ofString(String input) {
      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      var userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      // If the user is not in our DB, create it
      await _userRepository.registerOrRefresh(
          AppUser(id: userCredential.user!.uid)
            ..nickName = appleCredential.givenName!);
      return 'ok';
    } catch (e) {
      logger.e(e.toString());
      return 'error.unknown.content'.tr;
    }
  }

  //TODO: implement this
  Future<String> loginWithFacebook() async {
    throw UnimplementedError();
  }

  Future<String> logout() async {
    await FirebaseAuth.instance.signOut();
    //TODO: Login out from 3rd party OAuth
    return 'ok';
  }
}

class FirestoreApiHelper {
  static const extension_audio = 'mp3';
  static const extension_json = 'json';

  /// Save User speech, usually we won't await this.
  Future<void> saveUserSpeech(
      {required File speechData,
      required SentenceInfo sentenceInfo,
      SpeechExam? exam}) async {
    final storage = Storage()..fetch();
    final userId = Get.find<UserRepository>().currentUser.id;

    // Save speech data
    final speechDataPath = '/user_generated/speech_data';
    final uuid = Uuid().v1();
    final examId = exam?.examId ?? 'freeSpeech';
    final meta = {'newPost': 'true', 'userId': userId, 'examId': examId};
    final data = await storage.save(speechDataPath, speechData,
        filename: '$uuid.$extension_audio',
        mimeType: mimeTypeMpeg,
        metadata: meta);
    final result = SpeechEvaluationResult(
        userId: userId,
        examId: examId,
        speechDataPath: data.path,
        sentenceInfo: sentenceInfo);
    // Save evaluation result
    await storage.saveFromBytes(
        speechDataPath, utf8.encode(jsonEncode(result.toJson())) as Uint8List,
        filename: '$uuid.$extension_json',
        mimeType: 'application/json',
        metadata: meta);
  }

  // Setup emulator for firestore ONLY in debug mode
  // void _setupEmulator() {
  //   var debugMode = false;
  //   assert(debugMode = true);
  //   if (!debugMode) return;
  //   var host = GetPlatform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
  //   _firestore.settings = Settings(host: host, sslEnabled: false);
  // }
}

class TencentApiHelper {
  /// SoeRequest is used for making soe request, file is used for saving speech
  Future<SentenceInfo?> soe(SoeRequest request, File file) async {
    SentenceInfo? result;
    try {
      result = await TcApi().sendSoeRequest(request);
      unawaited(FirestoreApiHelper()
          .saveUserSpeech(speechData: file, sentenceInfo: result));
      logger.i('soe stop recording and get evaluation result succeed!');
    } on PlatformException catch (e, t) {
      logger.e('Error calling soe service', e, t);
    } finally {
      return result;
    }
  }
}

class TcApi extends GetConnect {
  static const SECRET_ID = 'AKIDorfD1yrBxYu3w2zWGj0aAXpzqPib3yKP';
  static const SECRET_KEY = 'rSqCKqlO6cz5wRWKGdoNaY6SaR0PhtgF';

  Future<SentenceInfo> sendSoeRequest(SoeRequest request) async {
    const action = 'TransmitOralProcessWithInit';
    const version = '2018-07-24';
    const endpoint = 'soe.tencentcloudapi.com';
    const service = 'soe';
    final now = DateTime.now();
    final timestamp = (now.millisecondsSinceEpoch / 1000).floor().toString();
    final payload = request.toString();
    final sign = _generateAuth(
        endpoint: endpoint, service: service, payload: payload, now: now);
    final response = await post('https://$endpoint', payload, headers: {
      'Host': endpoint,
      'X-TC-Action': action,
      'X-TC-RequestClient':
      GetPlatform.isIOS ? 'cschool_ios' : 'cschool_android',
      'X-TC-Timestamp': timestamp,
      'X-TC-Version': version,
      'X-TC-Language': 'zh-CN',
      'Content-Type': 'application/json',
      'Authorization': sign,
    });
    // This is stupid but GetConnect doesn't allow to change default charset [latin1]
    final content = utf8.decode(latin1.encode(response.bodyString!));
    return SentenceInfo.fromJson(jsonDecode(content)['Response']);
  }

  Future<Uint8List> sendTtsRequest(TtsRequest request) async {
    const region = 'ap-shanghai';
    const action = 'TextToVoice';
    const version = '2019-08-23';
    const endpoint = 'tts.tencentcloudapi.com';
    const service = 'tts';
    final now = DateTime.now();
    final timestamp = (now.millisecondsSinceEpoch / 1000).floor().toString();
    final payload = request.toString();
    final sign = _generateAuth(
        endpoint: endpoint, service: service, payload: payload, now: now);
    final response = await post('https://$endpoint', payload, headers: {
      'Host': endpoint,
      'X-TC-Region': region,
      'X-TC-Action': action,
      'X-TC-RequestClient':
      GetPlatform.isIOS ? 'cschool_ios' : 'cschool_android',
      'X-TC-Timestamp': timestamp,
      'X-TC-Version': version,
      'X-TC-Language': 'zh-CN',
      'Content-Type': 'application/json',
      'Authorization': sign,
    });
    return base64Decode(response.body['Response']['Audio']);
  }

  String _generateAuth(
      {required String endpoint,
        required String service,
        required String payload,
        required DateTime now}) {
    // 时间处理, 获取世界时间日期
    final utc = now.toUtc();
    final timestamp = (now.millisecondsSinceEpoch / 1000).floor().toString();
    final date = utc.yyyy_MM_dd;
    // ************* 步骤 1：拼接规范请求串 *************
    final signedHeaders = 'content-type;host';

    final hashedRequestPayload =
    sha256.convert(utf8.encode(payload)).toString();
    final httpRequestMethod = 'POST';
    final canonicalUri = '/';
    final canonicalQueryString = '';
    final canonicalHeaders =
        'content-type:application/json\n' 'host:' + endpoint + '\n';

    final canonicalRequest = httpRequestMethod +
        '\n' +
        canonicalUri +
        '\n' +
        canonicalQueryString +
        '\n' +
        canonicalHeaders +
        '\n' +
        signedHeaders +
        '\n' +
        hashedRequestPayload;
    // ************* 步骤 2：拼接待签名字符串 *************
    final algorithm = 'TC3-HMAC-SHA256';
    final hashedCanonicalRequest =
    sha256.convert(utf8.encode(canonicalRequest)).toString();
    final credentialScope = date + '/' + service + '/' + 'tc3_request';
    final stringToSign = algorithm +
        '\n' +
        timestamp +
        '\n' +
        credentialScope +
        '\n' +
        hashedCanonicalRequest;
    // ************* 步骤 3：计算签名 *************
    final kDate = _hmac256(date, 'TC3' + SECRET_KEY).bytes;
    final kService = _hmac256(service, kDate).bytes;
    final kSigning = _hmac256('tc3_request', kService).bytes;
    final signature = _hmac256(stringToSign, kSigning).toString();
    // ************* 步骤 4：拼接 Authorization *************
    final sign = algorithm +
        ' ' +
        'Credential=' +
        SECRET_ID +
        '/' +
        credentialScope +
        ', ' +
        'SignedHeaders=' +
        signedHeaders +
        ', ' +
        'Signature=' +
        signature;
    return sign;
  }

  Digest _hmac256(String message, dynamic secret) {
    final List<int> key = (secret is String) ? utf8.encode(secret) : secret;
    return Hmac(sha256, key).convert(utf8.encode(message));
  }
}


extension StorageExtension on Storage {
  Future<StorageFile> saveFromBytes(
    String folderPath,
    Uint8List data, {
    String? filename,
    String? mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final refFilename = filename ?? Storage.fileName();
    final refMimeType = mimeType ?? '';
    final path = '$folderPath/$refFilename';
    final ref = storage.ref().child(path);
    final settableMetadata =
        SettableMetadata(contentType: refMimeType, customMetadata: metadata);
    UploadTask uploadTask;
    uploadTask = ref.putData(data, settableMetadata);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return StorageFile(
      name: refFilename,
      url: downloadUrl,
      path: path,
      mimeType: refMimeType,
      metadata: metadata,
      additionalData: additionalData,
    );
  }
}
