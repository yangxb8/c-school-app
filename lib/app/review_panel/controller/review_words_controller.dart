import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/models/class.dart';
import 'package:c_school_app/model/user_word_history.dart';
import 'package:c_school_app/service/class_service.dart';
import 'package:c_school_app/app/review_panel/review_words_screen//ui_view/words_list.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/logger_service.dart';

const LAN_CODE_CN = 'zh-cn';
const LAN_CODE_JP = 'ja';

class ReviewWordsController extends GetxController {
  final ClassService classService = Get.find();
  final logger = Get.find<LoggerService>().logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();

  /// Current primary word ordinal in _wordList
  final primaryWordOrdinal = 0.obs;

  /// List or card
  final _mode = _WordsReviewModeWrapper().obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Words user favorite
  RxList<String> _userLikedWordIds;

  /// WordsHistory of this user
  RxList<WordHistory> _userWordsHistory;

  /// If all words mode, there will be multiple classes associated
  List<CSchoolClass> classes;

  /// WordsList for this class(es)
  List<Word> wordsList = [];

  Rx<WordMemoryStatus> wordMemoryStatus = WordMemoryStatus.NOT_REVIEWED.obs;

  /// Used to controller pagination of card
  RxDouble pageFraction;

  /// Null Timer means we are not in autoPlay mode
  Timer autoPlayTimer;

  RxString searchQuery = ''.obs;

  RxList<Word> searchResult = [].obs;

  @override
  Future<void> onInit() async {
    // As our cards are stack from bottom to top, reverse the words order
    // wordsList = List.from(classService.findWordsByTags(tags).reversed);
    _userLikedWordIds = ClassService.userLikedWordIds_Rx;
    _userWordsHistory = ClassService.userWordsHistory_Rx;
    classes = classService.findClassesById(Get.parameters['classId']);
    wordsList = classes.length == 1
        ? List.from(classes.single.words.reversed)
        : ClassService.allWords;
    pageFraction = (wordsList.length - 1.0).obs;
    await tts.setLanguage('zh-cn');
    await tts.setSpeechRate(0.5);
    // worker to monitor search query change and fire search function
    debounce(searchQuery, (_) => search(), time: Duration(seconds: 1));
    super.onInit();
  }

  /// Flashcard or List mode
  WordsReviewMode get mode => _mode.value.wordsReviewMode;

  /// PrimaryWord associated with primaryWordOrdinal
  Word get primaryWord => wordsList[primaryWordOrdinal.value];

  /// PrimaryWord.word to String for display
  String get primaryWordString => primaryWord.word.join();

  bool isWordLiked(Word word) => _userLikedWordIds.contains(word.wordId);

  bool get isAutoPlayMode => !autoPlayTimer.isNull;

  void toggleFavoriteCard(int cardOrdinal) =>
      classService.toggleWordLiked(wordsList[cardOrdinal]);

  int countWordMemoryStatusOfWordByStatus(
          {@required WordMemoryStatus status}) =>
      _userWordsHistory
          .filter((history) =>
              history.wordId == primaryWord.wordId &&
              history.wordMemoryStatus == status)
          .length;

  void handWordMemoryStatusPressed(WordMemoryStatus status) {
    if (wordMemoryStatus.value == status) {
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    } else {
      wordMemoryStatus.value = status;
    }
  }

  /// If nothing is pressed, default to NORMAL
  void saveAndResetWordHistory(Word word) {
    if (wordMemoryStatus.value == WordMemoryStatus.NOT_REVIEWED) {
      wordMemoryStatus.value = WordMemoryStatus.NORMAL;
    }
    classService.addWordReviewedHistory(word, status: wordMemoryStatus.value);
    wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
  }

  /// Sections for words list
  List<WordsSection> get sectionList {
    var sectionList_ = <WordsSection>[];
    // Get class id from wordId, and use classId to group words
    classes.forEach((cschoolClass) {
      var section = WordsSection();
      section
        ..expanded = true
        ..header = cschoolClass.title
        ..items = cschoolClass.words;
      sectionList_.add(section);
    });
    return sectionList_;
  }

  /// In autoPlay, user is restricted to card mode, this might need to be changed for better UX
  void changeMode() {
    if(isAutoPlayMode) return;
    if (_mode.value.wordsReviewMode == WordsReviewMode.FLASH_CARD) {
      _mode.update((mode) => mode.wordsReviewMode = WordsReviewMode.LIST);
      logger.i('Change to List Mode');
    } else {
      _mode.update((mode) => mode.wordsReviewMode = WordsReviewMode.FLASH_CARD);
      logger.i('Change to Card Mode');
    }
  }

  /// Play audio of the word
  Future<void> playWord({Word word}) async {
    if (word.isNull) word = primaryWord;
    var wordAudio = word.wordAudio;
    if (wordAudio.isNull) {
      await tts.speak(word.word.join());
    } else {
      await audioPlayer.play(wordAudio.url);
    }
  }

  /// Play audio of the examples
  Future<void> playExample(
      {@required String string, @required StorageFile audio}) async {
    if (audio.isNull) {
      await tts.speak(string);
    } else {
      await audioPlayer.play(audio.url);
    }
  }

  @override
  void onClose() {
    classService.commitChange();
    super.onClose();
  }

  //TODO: implement this
  void autoPlayPressed({@required PageController pageController, @required FlipController flipController}) async{
    // If already in autoPlay mode
    if(isAutoPlayMode){
      autoPlayTimer.cancel();
      autoPlayTimer = null;
    
    } else {
      // Force using card mode
      if(_mode.value.wordsReviewMode == WordsReviewMode.LIST){
        changeMode();
      }
      autoPlayTimer = Timer.periodic(2.seconds,()=>{
        
      });
    }
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    showDialog<void>(context: Get.context, builder: (context) => SimpleDialog(
      children: [WordCard(word: word)]));
  }

  /// Search card content, consider a match if word or meaning contains query
  void search() {
    var containKeyWord = (Word word) {
     return word.wordAsString.contains(searchQuery.value) || word.wordMeanings.has(m=>m.meaning.contains(searchQuery.value));
    }
    searchResult.clear();
    searchResult.addAll(wordsList.filter((word)=>containKeyWord(word)));
  }

}

class _WordsReviewModeWrapper {
  var wordsReviewMode = WordsReviewMode.LIST;
}

enum WordsReviewMode { LIST, FLASH_CARD }
