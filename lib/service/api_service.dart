import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:c_school_app/util/functions.dart';
import 'package:csv/csv.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/exams.dart';
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:c_school_app/app/model/user_speech.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/model/word_meaning.dart';
import '../model/user.dart';
import './logger_service.dart';
import '../i18n/api_service.i18n.dart';

final logger = LoggerService.logger;

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
    _firebaseAuth.authStateChanges().listen((User user) => func());
  }

  // Already return fromm every conditions
  // ignore: missing_return
  Future<String> signUpWithEmail(
      String email, String password, String nickname) async {
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
          == null) {
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
  static DocumentAccessor _documentAccessor;
  static CollectionReference _userSpeechCollection;
  static User _currentUser;

  static _FirestoreApi getInstance() {
    if (_instance == null) {
      _instance = _FirestoreApi();
      _firestore = FirebaseFirestore.instance;
      _documentAccessor = DocumentAccessor();
      _setupEmulator();
      _userSpeechCollection = _firestore.collection('user_speeches');
      _currentUser = _FirebaseAuthApi().currentUser;
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

  /// User can have many trial for same fingerprint
  Future<int> countUserSpeechByFingerprint(String fingerprint) async {
    return await _userSpeechCollection
        .where('fingerprint', isEqualTo: fingerprint)
        .get()
        .then((QuerySnapshot snapshot) => snapshot.size);
  }

  /// Update App User using flamingo, appUserForUpdate should contain
  /// only updated values
  void updateAppUser(AppUser appUserForUpdate, Function refreshAppUser) {
    _documentAccessor.update(appUserForUpdate).then((_) => refreshAppUser());
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

  /// Upload words to firestore and cloud storage
  void uploadWordsByCsv() async {
    final EXTENSION_AUDIO = 'mp3';
    final EXTENSION_IMAGE = 'jpg';
    final COLUMN_WORD_ID = 0;
    final COLUMN_WORD = 1;
    final COLUMN_PART_OF_SENTENCE = 2;
    final COLUMN_MEANING = 3;
    final COLUMN_PINYIN = 5;
    final COLUMN_HINT = 6;
    final COLUMN_OTHER_MEANING_ID = 7;
    final COLUMN_DETAIL = 8;
    final COLUMN_EXAMPLE = 9;
    final COLUMN_EXAMPLE_MEANING = 10;
    final COLUMN_EXAMPLE_PINYIN = 11;
    final COLUMN_RELATED_WORD_ID = 14;
    final COLUMN_WORD_PROCESS_STATUS = 18;
    final COLUMN_PIC_HASH = 19;
    final WORD_PROCESS_STATUS_NEW = 0;
    final SEPARATOR = '/';
    final PINYIN_SEPARATOR = '-';

    final storage = Storage()..fetch();
    final documentAccessor = DocumentAccessor();

    // Build Word from csv
    var csv;
    try {
      csv = CsvToListConverter()
          .convert(await rootBundle.loadString('assets/upload/words.csv'))
            ..removeWhere((w) =>
                WORD_PROCESS_STATUS_NEW != w[COLUMN_WORD_PROCESS_STATUS] ||
                w[COLUMN_WORD] == null);
    } catch (_) {
      print('No words.csv found, will skip!');
      return;
    }

    var words = csv
        .map((row) => Word(id: row[COLUMN_WORD_ID])
          ..word = row[COLUMN_WORD].trim().split('')
          ..pinyin = row[COLUMN_PINYIN].trim().split(PINYIN_SEPARATOR)
          ..partOfSentence = row[COLUMN_PART_OF_SENTENCE].trim()
          ..detail = row[COLUMN_DETAIL].trim()
          ..picHash = row[COLUMN_PIC_HASH].trim()
          ..wordMeanings = [
            WordMeaning(
                meaning: row[COLUMN_MEANING].trim().replaceAll(SEPARATOR, ','),
                examples: row[COLUMN_EXAMPLE].trim().split(SEPARATOR),
                exampleMeanings:
                    row[COLUMN_EXAMPLE_MEANING].trim().split(SEPARATOR),
                examplePinyins:
                    row[COLUMN_EXAMPLE_PINYIN].trim().split(SEPARATOR).toList())
          ]
          ..hint = row[COLUMN_HINT].trim()
          ..relatedWordIDs = row[COLUMN_RELATED_WORD_ID].trim().split(SEPARATOR)
          ..otherMeaningIds =
              row[COLUMN_OTHER_MEANING_ID].trim().split(SEPARATOR))
        .toList();

    // Checking status
    storage.uploader.listen((data) {
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });
    // Upload file to cloud storage and save reference
    await words.forEach((word) async {
      // Word image
      final pathWordPic =
          '${word.documentPath}/${EnumToString.convertToString(WordKey.pic)}';
      try {
        final wordPic =
            await getFileFromAssets('upload/${word.wordId}.${EXTENSION_IMAGE}');
        word.pic = await storage.save(pathWordPic, wordPic,
            filename: '${word.wordId}.${EXTENSION_IMAGE}',
            mimeType: mimeTypeJpeg,
            metadata: {'newPost': 'true'});
      } catch (e, _) {
        logger.i('Not image found for ${word.wordAsString}, will skip');
      }

      // Word Audio
      final pathWordAudioMale =
          '${word.documentPath}/${EnumToString.convertToString(WordKey.wordAudioMale)}';
      final pathWordAudioFemale =
          '${word.documentPath}/${EnumToString.convertToString(WordKey.wordAudioFemale)}';
      final wordAudioFileMale = await getFileFromAssets(
          'upload/${word.wordId}-W-M.${EXTENSION_AUDIO}');
      final wordAudioFileFemale = await getFileFromAssets(
          'upload/${word.wordId}-W-F.${EXTENSION_AUDIO}');
      word.wordAudioMale = await storage.save(
          pathWordAudioMale, wordAudioFileMale,
          filename: '${word.wordId}-W-M.${EXTENSION_AUDIO}',
          mimeType: mimeTypeMpeg,
          metadata: {'newPost': 'true'});
      word.wordAudioFemale = await storage.save(
          pathWordAudioFemale, wordAudioFileFemale,
          filename: '${word.wordId}-W-F.${EXTENSION_AUDIO}',
          mimeType: mimeTypeMpeg,
          metadata: {'newPost': 'true'});

      // Examples Audio
      // Each meaning
      await Future.forEach(word.wordMeanings, (meaning) async {
        var maleAudios = <StorageFile>[];
        var femaleAudios = <StorageFile>[];
        // Each example
        await Future.forEach(List.generate(meaning.exampleCount, (i) => i),
            (index) async {
          final pathExampleMaleAudio =
              '${word.documentPath}/${EnumToString.convertToString(WordMeaningKey.exampleMaleAudios)}';
          final pathExampleFemaleAudio =
              '${word.documentPath}/${EnumToString.convertToString(WordMeaningKey.exampleFemaleAudios)}';
          final exampleAudioFileMale = await getFileFromAssets(
              'upload/${word.wordId}-E${index}-M.${EXTENSION_AUDIO}');
          final exampleAudioFileFemale = await getFileFromAssets(
              'upload/${word.wordId}-E${index}-F.${EXTENSION_AUDIO}');
          final maleAudio = await storage.save(
              pathExampleMaleAudio, exampleAudioFileMale,
              filename: '${word.wordId}-E${index}-M.${EXTENSION_AUDIO}',
              mimeType: mimeTypeMpeg,
              metadata: {'newPost': 'true'});
          maleAudios.add(maleAudio);
          final femaleAudio = await storage.save(
              pathExampleFemaleAudio, exampleAudioFileFemale,
              filename: '${word.wordId}-E${index}-F.${EXTENSION_AUDIO}',
              mimeType: mimeTypeMpeg,
              metadata: {'newPost': 'true'});
          femaleAudios.add(femaleAudio);
        });
        meaning.exampleMaleAudios = maleAudios;
        meaning.exampleFemaleAudios = femaleAudios;
      });

      // Finally, save the word
      await documentAccessor.save(word);
    });

// Checking status
    storage.uploader.listen((data) {
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });

// Dispose uploader stream
    storage.dispose();
  }

  void uploadLecturesByCsv() async {
    final EXTENSION_IMAGE = 'jpg';
    final COLUMN_ID = 0;
    final COLUMN_LEVEL = 1;
    final COLUMN_TITLE = 2;
    final COLUMN_DESCRIPTION = 3;
    final COLUMN_PROCESS_STATUS = 5;
    final COLUMN_PIC_HASH = 6;
    final WORD_PROCESS_STATUS_NEW = 0;

    final storage = Storage()..fetch();
    final documentAccessor = DocumentAccessor();

    // Build Word from csv
    var csv;
    try {
      csv = CsvToListConverter()
          .convert(await rootBundle.loadString('assets/upload/lectures.csv'))
            ..removeWhere((w) =>
                WORD_PROCESS_STATUS_NEW != w[COLUMN_PROCESS_STATUS] ||
                w[COLUMN_TITLE] == null);
    } catch (_) {
      print('No lectures.csv found, will skip!');
      return;
    }

    var lectures =
        csv.map((row) => Lecture(id: row[COLUMN_ID], level: row[COLUMN_LEVEL])
          ..title = row[COLUMN_TITLE].trim() // Title should not be null
          ..description = row[COLUMN_DESCRIPTION]?.trim()
          ..picHash = row[COLUMN_PIC_HASH]?.trim());

    // Checking status
    storage.uploader.listen((data) {
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });
    // Upload file to cloud storage and save reference
    await lectures.forEach((lecture) async {
      // Word image
      final pathClassPic =
          '${lecture.documentPath}/${EnumToString.convertToString(LectureKey.pic)}';
      try {
        final lecturePic = await getFileFromAssets(
            'upload/${lecture.lectureId}.${EXTENSION_IMAGE}');
        lecture.pic = await storage.save(pathClassPic, lecturePic,
            filename: '${lecture.lectureId}.${EXTENSION_IMAGE}',
            mimeType: mimeTypeJpeg,
            metadata: {'newPost': 'true'});
      } catch (e, _) {
        logger.i('Not image found for ${lecture.title}, will skip');
      }

      // Finally, save the word
      await documentAccessor.save(lecture);
    });

// Checking status
    storage.uploader.listen((data) {
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });

// Dispose uploader stream
    storage.dispose();
  }

  Future<List<Word>> fetchWords({List<String> tags}) async {
    final collectionPaging = CollectionPaging<Word>(
      query: Word().collectionRef.orderBy('wordId'),
      limit: 10000,
      decode: (snap) => Word(snapshot: snap),
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

//TODO: implement this class
class _CloudStorageApi {
  static _CloudStorageApi _instance;
  static FirebaseStorage _firebaseStorage;

  static _CloudStorageApi getInstance(FirebaseApp firebaseApp) {
    if (_instance == null) {
      _instance = _CloudStorageApi();
      _firebaseStorage = FirebaseStorage.instanceFor(
          app: firebaseApp, bucket: 'gs://spoken-chinese.appspot.com');
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
    var result = {};
    try {
      result = await soeChannel.invokeMapMethod('soeStopRecordAndEvaluate');
      result['evaluationResult'] = SpeechEvaluationResult.fromJson(
          jsonDecode(result['evaluationResult']));
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
