extension DateTimeExtension on DateTime{
  String yyyyMMdd() {
    var mm = month<10? '0${month}':'${month}';
    var dd = day<10? '0${day}':'${day}';
    return '$this.year$mm$dd';
  }
}

RegExp singleHanziRegExp = RegExp(
    r'[\u4e00-\u9fa5]{1}',
    caseSensitive: false,
    multiLine: false,
    unicode: true
);

extension HanziUtil on String {
  bool get isSingleHanzi {
    assert(length == 1);
    return singleHanziRegExp.hasMatch(this);
  }
}
