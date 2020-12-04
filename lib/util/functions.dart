import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:c_school_app/app/models/word.dart';

Map<int, TableColumnWidth> calculateColumnWidthOfHanzi(Word word) {
  const HANZI_WIDTH = 50.0;
  const PINYIN_WIDTH = 30.0;
  return word.word.asMap().map((key, value) => MapEntry(
      key,
      FixedColumnWidth(
          max(HANZI_WIDTH, word.pinyin[key].length * PINYIN_WIDTH))));
}
