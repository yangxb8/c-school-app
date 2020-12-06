extension DateTimeExtension on DateTime{
  String yyyyMMdd() {
    var mm = month<10? '0${month}':'${month}';
    var dd = day<10? '0${day}':'${day}';
    return '$this.year$mm$dd';
  }
}
