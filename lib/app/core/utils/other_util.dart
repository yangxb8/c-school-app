extension DateTimeExtension on DateTime {
  String get yyyyMMdd {
    var mm = month.toString().padLeft(2, '0');
    var dd = day.toString().padLeft(2, '0');
    return '$year$mm$dd';
  }

  String get yyyy_MM_dd {
    var mm = month.toString().padLeft(2, '0');
    var dd = day.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }
}
