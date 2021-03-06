// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamingo/flamingo.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/exam_base.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:c_school_app/util/functions.dart';
import '../model/user.dart';
import './logger_service.dart';

final logger = LoggerService.logger;

class ApiService extends GetxService {
  static ApiService _instance;
  static bool _isFirebaseInitilized = false;
  static _FirebaseAuthApi _firebaseAuthApi;
  static _FirestoreApi _firestoreApi;
  static _TencentApi _tencentApi;

  static Future<ApiService> getInstance() async {
    _instance ??= ApiService();

    if (!_isFirebaseInitilized) {
      await Firebase.initializeApp();
      _firebaseAuthApi = await _FirebaseAuthApi.getInstance();
      _firestoreApi = await _FirestoreApi.getInstance();
      _tencentApi = _TencentApi.getInstance();
      _isFirebaseInitilized = true;
    }

    return _instance;
  }

  _FirebaseAuthApi get firebaseAuthApi => _firebaseAuthApi;
  _FirestoreApi get firestoreApi => _firestoreApi;
  _TencentApi get tencentApi => _tencentApi;
}

class _FirebaseAuthApi {
  static _FirebaseAuthApi _instance;
  static bool _isFirebaseAuthInitilized = false;
  static FirebaseAuth _firebaseAuth;
  static GoogleSignIn _googleSignIn;

  static Future<_FirebaseAuthApi> getInstance() async{
    _instance ??= _FirebaseAuthApi();

    if (!_isFirebaseAuthInitilized) {
      _firebaseAuth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/user.gender.read',
          'https://www.googleapis.com/auth/user.birthday.read',
          'https://www.googleapis.com/auth/user.organization.read'
        ],
      );
      _isFirebaseAuthInitilized = true;
    }

    return _instance;
  }

  Future<User> getCurrentUser() async => await _firebaseAuth.authStateChanges().first;

  void listenToFirebaseAuth(Function func) {
    _firebaseAuth.authStateChanges().listen((_) async => await func());
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> signUpWithEmail(
      String email, String password, String nickname) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // Email verify by showing popup on provided context
      Get.find<ApiService>().firestoreApi._registerAppUser(
          firebaseUser: userCredential.user, nickname: nickname);
      if (!userCredential.user.emailVerified) {
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
    }
  }

  Future<void> sendVerifyEmail() async {
    await (await getCurrentUser()).reload();
    await (await getCurrentUser()).sendEmailVerification();
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> loginWithEmail(String email, String password) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!userCredential.user.emailVerified) {
        return 'login.login.error.unverifiedEmail'.tr;
      }
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
      if(googleUser==null){
        return 'abort';
      }
      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      var userCredential = await _firebaseAuth.signInWithCredential(credential);
      // If the user is not in our DB, create it
      if (Get.find<ApiService>().firestoreApi.fetchAppUser(firebaseUser: userCredential.user) ==
          null) {
        Get.find<ApiService>().firestoreApi._registerAppUser(
            firebaseUser: userCredential.user,
            nickname: googleUser.displayName);
      }
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
      return List.generate(length, (_) => charset[random.nextInt(charset.length)])
          .join();
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
      if (Get.find<ApiService>().firestoreApi.fetchAppUser(firebaseUser: userCredential.user) ==
          null) {
        Get.find<ApiService>().firestoreApi._registerAppUser(
            firebaseUser: userCredential.user,
            nickname: appleCredential.givenName);
      }
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

class _FirestoreApi {
  static const extension_audio = 'mp3';
  static const extension_json = 'json';
  static _FirestoreApi _instance;
  static FirebaseFirestore _firestore;
  static DocumentAccessor _documentAccessor;
  static User _currentUser;

  static Future<_FirestoreApi> getInstance() async{
    if (_instance == null) {
      _instance = _FirestoreApi();
      _firestore = FirebaseFirestore.instance;
      _documentAccessor = DocumentAccessor();
      // _setupEmulator(); //TODO: Uncomment this to use firestore simulator
      _currentUser = await _FirebaseAuthApi().getCurrentUser();
    }

    return _instance;
  }

  void _registerAppUser(
      {@required User firebaseUser, @required String nickname}) {
    if (firebaseUser.isAnonymous) return;
    var appUser = AppUser(id: firebaseUser.uid);
    appUser.nickName = nickname;
    _documentAccessor.save(appUser).catchError((e) => logger.e(e.printError()));
  }

  Future<AppUser> fetchAppUser({User firebaseUser}) async {
    firebaseUser ??= _currentUser;
    if (firebaseUser == null) {
      logger.e('fetchAppUser was called on null firebaseUser');
      return null;
    }
    var user =
        await _documentAccessor.load<AppUser>(AppUser(id: firebaseUser.uid));
    if (user == null) {
      logger.e(
          'user ${firebaseUser.uid} not found in firestore, return empty user');
      return AppUser();
    } else {
      user.firebaseUser = firebaseUser;
      return user;
    }
  }

  /// Update App User using flamingo, appUserForUpdate should contain
  /// only updated values
  void updateAppUser(AppUser appUserForUpdate, Function refreshAppUser) {
    _documentAccessor.update(appUserForUpdate).then((_) => refreshAppUser());
  }

  /// Save User speech, usually we won't await this.
  Future<void> saveUserSpeech(
      {@required File speechData,
      @required String sentenceInfo,
      SpeechExam exam}) async {
    final storage = Storage()..fetch();
    final userId = UserService.user.userId;

    // Save speech data
    final speechDataPath = '/user_generated/speech_data';
    final data = await storage.save(speechDataPath, speechData,
        filename: '${userId}_${exam.examId}.${extension_audio}',
        mimeType: mimeTypeMpeg,
        metadata: {'newPost': 'true'});
    final result = SpeechEvaluationResult(
        userId: userId,
        examId: exam.examId ?? 'freeSpeech',
        speechDataPath: data.path,
        sentenceInfo: SentenceInfo.fromJson(jsonDecode(sentenceInfo)));
    // Save evaluation result
    await storage.save(
        speechDataPath, await createFileFromString(jsonEncode(result.toJson())),
        filename: '${userId}_${exam.examId}.${extension_json}',
        mimeType: 'application/json',
        metadata: {'newPost': 'true'});
  }

  Future<List<Word>> fetchWords({List<String> tags}) async {
    final collectionPaging = CollectionPaging<Word>(
      query: Word().collectionRef.orderBy('wordId'),
      limit: 10000,
      decode: (snap) => Word(snapshot: snap),
    );
    return await collectionPaging.load();
  }

  /// Fetch all entities extends exam
  Future<List<Exam>> fetchExams({List<String> tags}) async {
    final collectionPaging = CollectionPaging<Exam>(
      query: Exam().collectionRef.orderBy('examId'),
      limit: 10000,
      decode: (snap) => Exam.fromSnapshot(snap), // don't use Exam()
    );
    return await collectionPaging.load();
  }

  Future<List<Lecture>> fetchLectures({List<String> tags}) async {
    final collectionPaging = CollectionPaging<Lecture>(
      query: Lecture().collectionRef.orderBy('lectureId'),
      limit: 10000,
      decode: (snap) => Lecture(snapshot: snap),
    );
    return await collectionPaging.load();
  }

  // Setup emulator for firestore ONLY in debug mode
  static void _setupEmulator() {
    var debugMode = false;
    assert(debugMode = true);
    if (!debugMode) return;
    var host = GetPlatform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
    _firestore.settings = Settings(host: host, sslEnabled: false);
  }
}

/// This API only have native method
class _TencentApi {
  static _TencentApi _instance;

  /// Smart Oral Evaluation native channel
  static const soeChannel = MethodChannel('soe');

  /// Natural Language Processing native channel
  static const nlpChannel = MethodChannel('nlp');

  static _TencentApi getInstance() {
    _instance ??= _TencentApi();
    return _instance;
  }

  Future<void> soeStartRecord(SpeechExam exam) async {
    final audioPath =
        '${(await getTemporaryDirectory()).path}/${Uuid().v1()}.mp3';
    try {
      // await soeChannel.invokeMethod('soeStartRecord',<String, dynamic>{
      //   'refText': exam.refText,
      //   'scoreCoeff': Get.find<AppStateService>().user.userScoreCoeff,
      //   'mode': exam.mode.toString(),// WORD, SENTENCE(default), PARAGRAPH, FREE
      //   'audioPath': audioPath
      // });
      //TODO: for debug, delete me!!!
      await soeChannel.invokeMethod('soeStartRecord', <String, dynamic>{
        'refText': '大家好才是真的好',
        'scoreCoeff': 4.0,
        'mode': 'SENTENCE', // WORD, SENTENCE(default), PARAGRAPH, FREE
        'audioPath': audioPath
      });
      logger.i('soe start recording!');
    } on PlatformException catch (e, t) {
      logger.e('Error calling native soe start method', e, t);
    }
  }

  /// Return speech data in Uint8List and evaluation result as SpeechEvaluationResult
  Future<Map<String, dynamic>> soeStopRecordAndEvaluate() async {
    var result = <String, dynamic>{};
    try {
      final resultRaw =
          await soeChannel.invokeMapMethod('soeStopRecordAndEvaluate');
      result['evaluationResult'] = SentenceInfo.fromJson(
          jsonDecode(resultRaw['evaluationResult']).single);
      result['audioPath'] = resultRaw['audioPath'];
      // Save result to cloud storage, but won't await it
      unawaited(Get.find<ApiService>().firestoreApi.saveUserSpeech(
          speechData: File(result['dataPath']),
          sentenceInfo: jsonEncode(result['evaluationResult'])));
      logger.i('soe stop recording and get evaluation result succeed!');
    } on PlatformException catch (e, t) {
      logger.e('Error calling native soe stop method', e, t);
      result['evaluationResult'] = null;
      result['data'] = null;
    } finally {
      return result;
    }
  }
}
