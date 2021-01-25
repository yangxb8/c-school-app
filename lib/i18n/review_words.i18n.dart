import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': 'All Course',
        'ja_jp': 'クラスリスト',
      } +
      {
        'en': 'words',
        'ja_jp': '単語',
      } +
      {
        'en': 'Empty',
        'ja_jp': 'なし',
      } +
      {
        'en': 'My Words',
        'ja_jp': 'マイ単語',
      } +
      {
        'en': 'All words',
        'ja_jp': 'すべての単語',
      } +
      {
        'en': 'Liked words',
        'ja_jp': 'お気に入りの単語',
      } +
      {
        'en': 'Forgotten words',
        'ja_jp': '忘れた単語',
      }+
      {
        'en': 'Close',
        'ja_jp': '閉じる',
      }+
      {
        'en': 'Oops, No words here',
        'ja_jp': 'あら、ここに単語がないみたい',
      };

  String get i18n => localize(this, _t);
}
