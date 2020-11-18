import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spoken_chinese/app/models/exams.dart';
import 'package:spoken_chinese/app/models/speech_evaluation_result.dart';
import 'package:spoken_chinese/app/models/user_speech.dart';
import '../model/user.dart';
import './logger_service.dart';
import '../i18n/api_service.i18n.dart';
import 'package:enum_to_string/enum_to_string.dart';

final logger = Get.find<LoggerService>().logger;

class ApiService extends GetxService {
  static ApiService _instance;
  static FirebaseApp _firebaseApp;
  static bool _isFirebaseInitilized = false;
  static _FirebaseAuthApi _firebaseAuthApi;
  static _FirestoreApi _firestoreApi;
  static _CloudStorageApi _cloudStorageApi;
  static _TencentApi _tencentApi;

  static Future<ApiService> getInstance() async {
    _instance ??= ApiService();

    if (!_isFirebaseInitilized) {
      _firebaseApp = await Firebase.initializeApp();
      _firebaseAuthApi = _FirebaseAuthApi.getInstance();
      _firestoreApi = _FirestoreApi.getInstance();
      _cloudStorageApi = _CloudStorageApi.getInstance(_firebaseApp);
      _tencentApi = _TencentApi.getInstance();
      _isFirebaseInitilized = true;
    }

    return _instance;
  }

  _FirebaseAuthApi get firebaseAuthApi => _firebaseAuthApi;
  _FirestoreApi get firestoreApi => _firestoreApi;
  _CloudStorageApi get cloudStorageApi => _cloudStorageApi;
  _TencentApi get tencentApi => _tencentApi;
}

class _FirebaseAuthApi {
  static _FirebaseAuthApi _instance;
  static bool _isFirebaseAuthInitilized = false;
  static FirebaseAuth _firebaseAuth;
  static GoogleSignIn _googleSignIn;
  static final _FirestoreApi _firestoreApi = _FirestoreApi.getInstance();

  static _FirebaseAuthApi getInstance() {
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

  User get currentUser => _firebaseAuth.currentUser;

  void listenToFirebaseAuth(Function func) {
    _firebaseAuth.authStateChanges().listen((User user) => func(user));
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> signUpWithEmail(
      String email, String password, String nickname) async {
    //TODO: Several accounts per email is allowed for debug, disable it on firebase
    try {
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // Email verify by showing popup on provided context
      _firestoreApi._registerAppUser(
          firebaseUser: userCredential.user, nickname: nickname);
      if (!userCredential.user.emailVerified) {
        await sendVerifyEmail();
        return 'need email verify';
      }
      logger.d(email, 'User registered:');
      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.'.i18nApi;
      }
    } catch (e) {
      logger.e(e);
      return 'Unexpected internal error occurs'.i18nApi;
    }
  }

  Future<void> sendVerifyEmail() async {
    await currentUser.reload();
    await currentUser.sendEmailVerification();
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> loginWithEmail(String email, String password) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!userCredential.user.emailVerified) {
        return 'Please verify your email.'.i18nApi;
      }
      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.'.i18nApi;
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.'.i18nApi;
      }
    } catch (e) {
      logger.e(e.toString());
      return 'Unexpected internal error occurs'.i18nApi;
    }
  }

  Future<String> loginWithGoogle() async {
    try {
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
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
      if (_firestoreApi
          .fetchAppUser(firebaseUser: userCredential.user)
          .isNull) {
        _firestoreApi._registerAppUser(
            firebaseUser: userCredential.user,
            nickname: googleUser.displayName);
      }
      return 'ok';
    } catch (e) {
      logger.e(e.toString());
      return 'Unexpected internal error occurs'.i18nApi;
    }
  }

  //TODO: Twitter Developer Portal has a callback URL of twittersdk:// for Android, and twitterkit-CONSUMERKEY:// for iOS.
  Future<String> loginWithTwitter() async {
    try {
      // Create a TwitterLogin instance
      final twitterLogin = TwitterLogin(
        consumerKey: 'HIsHd3qBoTLk3pUa9METOl17N',
        consumerSecret: 'M9SFMqNzo9p2OfBpnNeiOvlf0b8rufL9P2CDXOwnTUmHFWFiiR',
      );

      // Trigger the sign-in flow
      final loginResult = await twitterLogin.authorize();

      // Get the Logged In session
      final twitterSession = loginResult.session;

      // Create a credential from the access token
      final AuthCredential twitterAuthCredential =
          TwitterAuthProvider.credential(
              accessToken: twitterSession.token, secret: twitterSession.secret);

      // Once signed in, return the UserCredential
      await _firebaseAuth.signInWithCredential(twitterAuthCredential);
    } catch (e) {
      logger.e(e.toString());
      return 'Unexpected internal error occurs'.i18nApi;
    }
    return 'ok';
  }

  //TODO: implement this
  Future<String> loginWithApple() async {
    throw UnimplementedError();
  }

  //TODO: implement this
  Future<String> loginWithFacebook() async {
    throw UnimplementedError();
  }

  //TODO: implement this, after logout, login as anonymous.
  Future<String> logout() async {
    throw UnimplementedError();
    await loginAnonymous();
  }

  Future<String> loginAnonymous() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      return 'ok';
    } catch (e) {
      logger.e(e.toString());
      return 'Unexpected internal error occurs'.i18nApi;
    }
  }
}

class _FirestoreApi {
  static _FirestoreApi _instance;
  static FirebaseFirestore _firestore;
  static CollectionReference _appUsersCollection;
  static CollectionReference _userSpeechCollection;

  static _FirestoreApi getInstance() {
    if (_instance == null) {
      _instance = _FirestoreApi();
      _firestore = FirebaseFirestore.instance;
      _setupEmulator();
      _appUsersCollection = _firestore.collection('app_users');
      _userSpeechCollection = _firestore.collection('user_speeches');
    }

    return _instance;
  }

  void _registerAppUser(
      {@required User firebaseUser, @required String nickname}) {
    var userCollection = {
      'nickname': nickname,
      'membershipType': [EnumToString.convertToString(MembershipType.FREE)],
      'membershipEndAt': null,
      'rankHistory': [],
      'progress': {'learnedLectures': {}, 'history': {}},
      'userGeneratedData': {'savedLecturesID': [], 'memo': []}
    };
    _appUsersCollection
        .doc(firebaseUser.uid)
        .set(userCollection)
        .then((value) =>
            logger.d(userCollection, 'User added: ${firebaseUser.uid}'))
        .catchError((e) => logger.e(e.printError()));
  }

  /// User can have many trial for same fingerprint
  Future<int> countUserSpeechByFingerprint(String fingerprint) async {
    return await _userSpeechCollection
        .where('fingerprint', isEqualTo: fingerprint)
        .get()
        .then((QuerySnapshot snapshot) => snapshot.size);
  }

  /// Return the specific speech data as Uint8List
  Future<Uint8List> getUserSpeechByFingerprintAndTrial(
      {@required String fingerPrint, @required int trial}) async {
    return await _userSpeechCollection
        .where('fingerprint', isEqualTo: fingerPrint)
        .where('trial', isEqualTo: trial)
        .get()
        .then(
            (QuerySnapshot snapshot) => snapshot.docs.first.get('speechData'));
  }

  /// Save speech data. We won't wait for this
  void saveUserSpeechResult(UserSpeech speech) {
    _userSpeechCollection.add({
      'fingerprint': speech.speechFingerprint,
      'userId': speech.userId,
      'lectureId': speech.lectureId,
      'examId': speech.examId,
      'trial': speech.trial,
      'speechData': speech.speechData,
      'evaluationResult': jsonEncode(speech.evaluationResult.toJson())
    });
  }

  Future<Map<String, dynamic>> fetchAppUser(
      {@required User firebaseUser}) async {
    if (firebaseUser.isNull) return null;
    var snapshot = await _appUsersCollection.doc(firebaseUser.uid).get();
    return snapshot.exists
        ? snapshot.data()
        : null; // If user login anonymously, this will be null
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

//TODO: implement this class
class _CloudStorageApi {
  static _CloudStorageApi _instance;
  static FirebaseStorage _firebaseStorage;

  static _CloudStorageApi getInstance(FirebaseApp firebaseApp) {
    if (_instance == null) {
      _instance = _CloudStorageApi();
      _firebaseStorage = FirebaseStorage(
          app: firebaseApp, storageBucket: 'gs://spoken-chinese.appspot.com');
    }

    return _instance;
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
    try {
      // await soeChannel.invokeMethod('soeStartRecord',<String, dynamic>{
      //   'refText': exam.refText,
      //   'scoreCoeff': Get.find<AppStateService>().user.userScoreCoeff,
      //   'mode': exam.mode.toString()// WORD, SENTENCE(default), PARAGRAPH, FREE
      // });
      //TODO: for debug, delete me!!!
      await soeChannel.invokeMethod('soeStartRecord', <String, dynamic>{
        'refText': '大家好才是真的好',
        'scoreCoeff': 4.0,
        'mode': 'SENTENCE' // WORD, SENTENCE(default), PARAGRAPH, FREE
      });
      logger.i('soe start recording!');
    } on PlatformException catch (e, t) {
      logger.e('Error calling native soe start method', e, t);
    }
  }

  /// Return speech data in Uint8List and evaluation result as SpeechEvaluationResult
  Future<Map<String, dynamic>> soeStopRecordAndEvaluate() async {
    var result={};
    try {
      result = await soeChannel.invokeMapMethod('soeStopRecordAndEvaluate');
      result['evaluationResult'] =
          SpeechEvaluationResult.fromJson(jsonDecode(result['evaluationResult']));
      logger.i('soe stop recording and get evaluation result succeed!');
    } on PlatformException catch (e, t) {
      logger.e('Error calling native soe stop method', e, t);
      result['speechData'] = null;
      result['evaluationResult'] = null;
    } finally {
      return result;
    }
  }
}
