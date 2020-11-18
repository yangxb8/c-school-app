import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spoken_chinese/service/api_service.dart';
import 'package:spoken_chinese/service/logger_service.dart';

class ReviewWordsController extends GetxController{
  final _mode = _WordsReviewModeWrapper().obs;
  final ApiService apiService = Get.find();
  final logger = Get.find<LoggerService>().logger;
  final searchBarController = FloatingSearchBarController();

  WordsReviewMode get mode => _mode.value.wordsReviewMode;

  void changeMode() {
    if(_mode.value.wordsReviewMode == WordsReviewMode.FLASH_CARD){
      _mode.update((mode)=> mode.wordsReviewMode = WordsReviewMode.LIST);
      logger.i('Change to List Mode');
    } else {
      _mode.update((mode)=> mode.wordsReviewMode = WordsReviewMode.FLASH_CARD);
      logger.i('Change to Card Mode');
    }
  }
}

class _WordsReviewModeWrapper{
  var wordsReviewMode = WordsReviewMode.LIST;
}

enum WordsReviewMode {LIST, FLASH_CARD}