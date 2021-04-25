import 'index.dart';

RegExp singleHanziRegExp = RegExp(r'[\u4e00-\u9fa5]{1}',
    caseSensitive: false, multiLine: false, unicode: true);

extension HanziUtil on String {
  bool get isSingleHanzi {
    assert(length == 1);
    return singleHanziRegExp.hasMatch(this);
  }
}

extension HanziListUtil on List<String> {
  /// Convert the index with punctuation to index without it.
  int indexWithoutPunctuation(index) {
    var indexCopy = index;
    final _punctuationPositions =
        allIndexWhere((e) => !(e as String).isSingleHanzi);
    for (var pIndex in _punctuationPositions) {
      if (indexCopy >= pIndex) {
        indexCopy++;
      } else {
        break;
      }
    }
    return indexCopy;
  }
}
