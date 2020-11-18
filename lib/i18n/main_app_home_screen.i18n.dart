import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': 'Study',
        'ja_jp': '勉強',
      } +
      {
        'en': 'Discover',
        'ja_jp': '発現',
      } +
      {
        'en': 'Review',
        'ja_jp': '復習',
      } +
      {
        'en': 'Account',
        'ja_jp': '設定',
      };
  String get i18n => localize(this, _t);}