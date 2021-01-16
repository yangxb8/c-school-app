import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:c_school_app/app/model/exam_base.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:c_school_app/util/functions.dart';
import 'package:csv/csv.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:pedantic/pedantic.dart';
import 'package:path_provider/path_provider.dart';

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
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/model/word_meaning.dart';
import 'package:uuid/uuid.dart';
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
      if (_firestoreApi.fetchAppUser(firebaseUser: userCredential.user) ==
          null) {
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
  static const extension_audio = 'mp3';
  static const extension_image = 'jpg';
  static const extension_json = 'json';
  static _FirestoreApi _instance;
  static FirebaseFirestore _firestore;
  static DocumentAccessor _documentAccessor;
  static User _currentUser;

  static _FirestoreApi getInstance() {
    if (_instance == null) {
      _instance = _FirestoreApi();
      _firestore = FirebaseFirestore.instance;
      _documentAccessor = DocumentAccessor();
      _setupEmulator();
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

  /// Upload words to firestore and cloud storage
  void uploadWordsByCsv() async {
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
        final wordPic = await createFileFromAssets(
            'upload/${word.wordId}.${extension_image}');
        word.pic = await storage.save(pathWordPic, wordPic,
            filename: '${word.wordId}.${extension_image}',
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
      final wordAudioFileMale = await createFileFromAssets(
          'upload/${word.wordId}-W-M.${extension_audio}');
      final wordAudioFileFemale = await createFileFromAssets(
          'upload/${word.wordId}-W-F.${extension_audio}');
      word.wordAudioMale = await storage.save(
          pathWordAudioMale, wordAudioFileMale,
          filename: '${word.wordId}-W-M.${extension_audio}',
          mimeType: mimeTypeMpeg,
          metadata: {'newPost': 'true'});
      word.wordAudioFemale = await storage.save(
          pathWordAudioFemale, wordAudioFileFemale,
          filename: '${word.wordId}-W-F.${extension_audio}',
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
          final exampleAudioFileMale = await createFileFromAssets(
              'upload/${word.wordId}-E${index}-M.${extension_audio}');
          final exampleAudioFileFemale = await createFileFromAssets(
              'upload/${word.wordId}-E${index}-F.${extension_audio}');
          final maleAudio = await storage.save(
              pathExampleMaleAudio, exampleAudioFileMale,
              filename: '${word.wordId}-E${index}-M.${extension_audio}',
              mimeType: mimeTypeMpeg,
              metadata: {'newPost': 'true'});
          maleAudios.add(maleAudio);
          final femaleAudio = await storage.save(
              pathExampleFemaleAudio, exampleAudioFileFemale,
              filename: '${word.wordId}-E${index}-F.${extension_audio}',
              mimeType: mimeTypeMpeg,
              metadata: {'newPost': 'true'});
          femaleAudios.add(femaleAudio);
        });
        meaning.exampleMaleAudios = maleAudios;
        meaning.exampleFemaleAudios = femaleAudios;
      });

      // Finally, save the word
      await _documentAccessor.save(word);
    });

// Checking status
    storage.uploader.listen((data) {
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });

// Dispose uploader stream
    storage.dispose();
  }

  void uploadLecturesByCsv() async {
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
        final lecturePic = await createFileFromAssets(
            'upload/${lecture.lectureId}.${extension_image}');
        lecture.pic = await storage.save(pathClassPic, lecturePic,
            filename: '${lecture.lectureId}.${extension_image}',
            mimeType: mimeTypeJpeg,
            metadata: {'newPost': 'true'});
      } catch (e, _) {
        logger.i('Not image found for ${lecture.title}, will skip');
      }

      // Finally, save the word
      await documentAccessor.save(lecture);
    });

// Dispose uploader stream
    storage.dispose();
  }

  void uploadSpeechExamsByCsv() async {
    final column_id = 0;
    final column_title = 2;
    final column_question = 3;
    final column_ref_text = 4;
    final column_process_statue = 5;
    final process_status_new = 0;

    final storage = Storage()..fetch();
    final documentAccessor = DocumentAccessor();

    // Build Word from csv
    var csv;
    try {
      csv = CsvToListConverter()
          .convert(await rootBundle.loadString('assets/upload/speechExams.csv'))
            ..removeWhere((w) =>
                process_status_new != w[column_process_statue] ||
                w[column_title] == null);
    } catch (_) {
      print('No speechExams.csv found, will skip!');
      return;
    }

    var exams = csv.map((row) => SpeechExam(id: row[column_id])
      ..title = row[column_title].trim() // Title should not be null
      ..question = row[column_question]?.trim()
      ..refText = row[column_ref_text]?.trim());

    // Checking status
    storage.uploader.listen((data) {
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });
    // Upload file to cloud storage and save reference
    await exams.forEach((exam) async {
      // Word image
      final pathRefAudio =
          '${exam.documentPath}/${EnumToString.convertToString(SpeechExamKey.refAudio)}';
      try {
        final refAudio =
            await createFileFromAssets('upload/${exam.id}.${extension_audio}');
        exam.pic = await storage.save(pathRefAudio, refAudio,
            filename: '${exam.id}.${extension_audio}',
            mimeType: mimeTypeMpeg,
            metadata: {'newPost': 'true'});
      } catch (e, _) {
        logger.i('Not image found for ${exam.title}, will skip');
      }

      // Finally, save the word
      await documentAccessor.save(exam);
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
    final audioPath = '${(await getTemporaryDirectory()).path}/${Uuid().v1()}.mp3';
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
      result['evaluationResult'] =
          SentenceInfo.fromJson(jsonDecode(resultRaw['evaluationResult']).single);
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
