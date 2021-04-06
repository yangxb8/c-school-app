// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamingo/flamingo.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pedantic/pedantic.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/exam_base.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/soe_request.dart';
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/service/user_service.dart';
import '../model/user.dart';
import './logger_service.dart';
import 'tc3_service.dart';

final logger = LoggerService.logger;

class ApiService extends GetxService {
  static ApiService? _instance;
  static bool _isFirebaseInitialized = false;
  static late final _FirebaseAuthApi _firebaseAuthApi;
  static late final _FirestoreApi _firestoreApi;
  static late final _TencentApi _tencentApi;

  static Future<ApiService> getInstance() async {
    _instance ??= ApiService();

    if (!_isFirebaseInitialized) {
      await Firebase.initializeApp();
      _firebaseAuthApi = await _FirebaseAuthApi.getInstance();
      _firestoreApi = await _FirestoreApi.getInstance();
      _tencentApi = _TencentApi();
      _isFirebaseInitialized = true;
    }

    return _instance!;
  }

  _FirebaseAuthApi get firebaseAuthApi => _firebaseAuthApi;
  _FirestoreApi get firestoreApi => _firestoreApi;
  _TencentApi get tencentApi => _tencentApi;
}

class _FirebaseAuthApi {
  static _FirebaseAuthApi? _instance;
  static bool _isFirebaseAuthInitialized = false;
  static late final FirebaseAuth _firebaseAuth;
  static late final GoogleSignIn _googleSignIn;

  static Future<_FirebaseAuthApi> getInstance() async {
    _instance ??= _FirebaseAuthApi();

    if (!_isFirebaseAuthInitialized) {
      _firebaseAuth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/user.gender.read',
          'https://www.googleapis.com/auth/user.birthday.read',
          'https://www.googleapis.com/auth/user.organization.read'
        ],
      );
      _isFirebaseAuthInitialized = true;
    }

    return _instance!;
  }

  Future<User?> getCurrentUser() async => await _firebaseAuth.authStateChanges().first;

  void listenToFirebaseAuth(Function func) {
    _firebaseAuth.authStateChanges().listen((_) async => await func());
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> signUpWithEmail(String email, String password, String nickname) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // Email verify by showing popup on provided context
      Get.find<ApiService>()
          .firestoreApi
          ._registerAppUser(firebaseUser: userCredential.user!, nickname: nickname);
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
    await (await getCurrentUser())!.reload();
    await (await getCurrentUser())!.sendEmailVerification();
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> loginWithEmail(String email, String password) async {
    try {
      var userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (!userCredential.user!.emailVerified) {
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
      if (googleUser == null) {
        return 'abort';
      }
      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ) as GoogleAuthCredential;
      // Once signed in, return the UserCredential
      var userCredential = await _firebaseAuth.signInWithCredential(credential);
      // If the user is not in our DB, create it
      if (await Get.find<ApiService>()
              .firestoreApi
              .fetchAppUser(firebaseUser: userCredential.user) ==
          null) {
        Get.find<ApiService>().firestoreApi._registerAppUser(
            firebaseUser: userCredential.user!, nickname: googleUser.displayName!);
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
      final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
      final random = Random.secure();
      return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
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
      var userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      // If the user is not in our DB, create it
      if (await Get.find<ApiService>()
              .firestoreApi
              .fetchAppUser(firebaseUser: userCredential.user) ==
          null) {
        Get.find<ApiService>().firestoreApi._registerAppUser(
            firebaseUser: userCredential.user!, nickname: appleCredential.givenName!);
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
  static _FirestoreApi? _instance;
  static late final FirebaseFirestore _firestore;
  static late final DocumentAccessor _documentAccessor;
  static User? _currentUser;

  static Future<_FirestoreApi> getInstance() async {
    if (_instance == null) {
      _instance = _FirestoreApi();
      _firestore = FirebaseFirestore.instance;
      _documentAccessor = DocumentAccessor();
      _setupEmulator(); //TODO: Uncomment this to use firestore simulator
      _currentUser = await _FirebaseAuthApi().getCurrentUser();
    }

    return _instance!;
  }

  void _registerAppUser({required User firebaseUser, required String nickname}) {
    if (firebaseUser.isAnonymous) return;
    var appUser = AppUser(id: firebaseUser.uid);
    appUser.nickName = nickname;
    _documentAccessor.save(appUser).catchError((e) => logger.e(e.printError()));
  }

  Future<AppUser?> fetchAppUser({User? firebaseUser}) async {
    firebaseUser ??= _currentUser;
    if (firebaseUser == null) {
      logger.e('fetchAppUser was called on null firebaseUser');
      return null;
    }
    var user = await _documentAccessor.load<AppUser>(AppUser(id: firebaseUser.uid));
    if (user == null) {
      logger.e('user ${firebaseUser.uid} not found in firestore, return empty user');
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
      {required File speechData, required SentenceInfo sentenceInfo, SpeechExam? exam}) async {
    final storage = Storage()..fetch();
    final userId = UserService.user.userId;

    // Save speech data
    final speechDataPath = '/user_generated/speech_data';
    final uuid = Uuid().v1();
    final examId = exam?.examId ?? 'freeSpeech';
    final meta = {'newPost': 'true', 'userId': userId, 'examId': examId};
    final data = await storage.save(speechDataPath, speechData,
        filename: '$uuid.$extension_audio', mimeType: mimeTypeMpeg, metadata: meta);
    final result = SpeechEvaluationResult(
        userId: userId, examId: examId, speechDataPath: data.path, sentenceInfo: sentenceInfo);
    // Save evaluation result
    await storage.saveFromBytes(
        speechDataPath, utf8.encode(jsonEncode(result.toJson())) as Uint8List,
        filename: '$uuid.$extension_json', mimeType: 'application/json', metadata: meta);
  }

  Future<List<Word>> fetchWords({List<String>? tags}) async {
    final collectionPaging = CollectionPaging<Word>(
      query: Word().collectionRef.orderBy('wordId'),
      limit: 10000,
      decode: (snap) => Word(snapshot: snap),
    );
    return await collectionPaging.load();
  }

  /// Fetch all entities extends exam
  Future<List<Exam>> fetchExams({List<String>? tags}) async {
    final collectionPaging = CollectionPaging<Exam>(
      query: Exam().collectionRef.orderBy('examId'),
      limit: 10000,
      decode: (snap) => Exam.fromSnapshot(snap), // don't use Exam()
    );
    return await collectionPaging.load();
  }

  Future<List<Lecture>> fetchLectures({List<String>? tags}) async {
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

class _TencentApi {
  /// SoeRequest is used for making soe request, file is used for saving speech
  Future<SentenceInfo?> soe(SoeRequest request, File file) async {
    SentenceInfo? result;
    try {
      result = await TcService().sendSoeRequest(request);
      unawaited(Get.find<ApiService>()
          .firestoreApi
          .saveUserSpeech(speechData: file, sentenceInfo: result));
      logger.i('soe stop recording and get evaluation result succeed!');
    } on PlatformException catch (e, t) {
      logger.e('Error calling soe service', e, t);
    } finally {
      return result;
    }
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
    final settableMetadata = SettableMetadata(contentType: refMimeType, customMetadata: metadata);
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
