import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': 'Almost there',
        'ja_jp': 'あと一歩',
      } +
      {
        'en': 'Close',
        'ja_jp': '閉じる',
      } +
      {
        'en':
            'We have sent your an Email at %s, follow the link there to verify your account!',
        'ja_jp': '検証用のメールを%sへ送信しました。メールのリンクを沿ってアカウントをアクティブしてください。',
      } +
      {
        'en': 'The account already exists for that email.',
        'ja_jp': 'このメールアドレスは既に他のアカウントと関連しています。',
      } +
      {
        'en': 'No user found for that email.',
        'ja_jp': '登録されていないメールアドレスです。',
      } +
      {
        'en': 'Wrong password provided for that user.',
        'ja_jp': 'パスワードが間違えました。',
      } +
      {
        'en': 'Please verify your email.',
        'ja_jp': 'メールアドレスを認証してください。',
      } +
      {
        'en': 'Something is wrong!',
        'ja_jp': '予想外のエラーです',
      } +
      {
        'en': 'Unexpected internal error occurs',
        'ja_jp': '予期せぬエラーが発生しました。',
      };

  String get i18nApi => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
}
