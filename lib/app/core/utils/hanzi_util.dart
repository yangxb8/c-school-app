import 'index.dart';

RegExp singleHanziRegExp = RegExp(r'^[\u4e00-\u9fa5]$',
    caseSensitive: false, multiLine: false, unicode: true);

extension HanziUtil on String {
  bool get isSingleHanzi {
    return singleHanziRegExp.hasMatch(this);
  }
}
