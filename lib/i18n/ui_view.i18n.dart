// 📦 Package imports:
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': 'Summary',
        'ja_jp': '総評',
      }+
      {
        'en': 'Empty',
        'ja_jp': 'なし',
      };

  String get i18n => localize(this, _t);
}
