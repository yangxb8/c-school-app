import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': 'All Course',
        'ja_jp': 'クラス',
      } +
      {
        'en': 'words',
        'ja_jp': '単語',
      } ;

  String get i18n => localize(this, _t);

}
