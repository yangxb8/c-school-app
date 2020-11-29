import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:spoken_chinese/app/models/word.dart';

Map<int, TableColumnWidth> calculateColumnWidthOfHanzi(Word word) {
  const HANZI_WIDTH = 50.0;
  const PINYIN_WIDTH = 30.0;
  return word.word.asMap().map((key, value) => MapEntry(
      key,
      FixedColumnWidth(
          max(HANZI_WIDTH, word.pinyin[key].length * PINYIN_WIDTH))));
}

Comparator<Timestamp> timestampComparator = (a, b) => a.compareTo(b);