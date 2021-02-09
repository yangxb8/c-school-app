// 📦 Package imports:
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': 'Existing',
        'ja_jp': 'ログイン',
      } +
      {
        'en': 'New',
        'ja_jp': '登録',
      } +
      {
        'en': 'Email Address',
        'ja_jp': 'メールアドレス',
      } +
      {
        'en': 'Password',
        'ja_jp': 'パスワード',
      } +
      {
        'en': 'LOGIN',
        'ja_jp': 'ログイン',
      } +
      {
        'en': 'Forgot Password?',
        'ja_jp': 'パスワードを忘れた？',
      } +
      {
        'en': 'Name',
        'ja_jp': 'ID',
      } +
      {
        'en': 'Confirmation',
        'ja_jp': 'パスワード（確認用）',
      } +
      {
        'en': 'SIGN UP',
        'ja_jp': '登録',
      } +
      {'en': "That doesn't looks like an Email", 'ja_jp': '正しいメールを入力してください'} +
      {'en': 'Required', 'ja_jp': '必要項目です'} +
      {'en': '6 digits or more', 'ja_jp': '6位以上設定してください'} +
      {'en': 'Too long', 'ja_jp': '長すぎます'}+
      {'en': 'Passwords do not match', 'ja_jp': 'パスワードは一致しません'}+
      {'en': 'Oops?', 'ja_jp': 'あら？'}+
      {'en': 'Resend email', 'ja_jp': 'メールを再送'}+
      {
        'en': 'Close',
        'ja_jp': '閉じる',
      }+
      {
        'en': 'Welcome Back!',
        'ja_jp': 'お帰りなさい！',
      }+
      {
        'en': 'You have study for %d times!',
        'ja_jp': '%d回目の勉強を頑張りましょう！',
      };

  String get i18n => localize(this, _t);

}
