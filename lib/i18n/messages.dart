// 📦 Package imports:
import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => const {
        'en_US': {
          // Common
          'button.close': 'Close',
          'error.oops': 'Oops?',
          'error.permission.mic':'Please allow the microphone usage',
          'error.unknown.title': 'Something is wrong!',
          'error.unknown.content': 'Unexpected internal error occurs',
          // Home
          'home.panel.study.title': 'Study',
          'home.panel.discover.title': 'Discover',
          'home.panel.review.title': 'Review',
          'home.panel.account.title': 'Account',
          // Login
          'login.common.email': 'Email Address',
          'login.common.password': 'Password',
          'login.common.error.emailFormat': "That doesn't looks like an Email",
          'login.common.error.required': 'Required',
          'login.register.tab.title': 'New',
          'login.register.button.signUp': 'SIGN UP',
          'login.register.button.forgotPassword': 'Forgot Password?',
          'login.register.form.name': 'Name',
          'login.register.form.passwordConfirm': 'Confirmation',
          'login.register.confirmEmail.title': 'Almost there',
          'login.register.confirmEmail.content':
              'We have sent your an Email at @email, follow the link there to verify your account!',
          'login.register.error.tooShort': '6 digits or more',
          'login.register.error.tooLong': 'Too long',
          'login.register.error.passwordConfirmError': 'Passwords do not match',
          'login.register.error.registeredEmail': 'The account already exists for that email.',
          'login.login.tab.title': 'Existing',
          'login.login.button.login': 'LOGIN',
          'login.login.dialog.resentEmail': 'Resend email',
          'login.login.dialog.success.title': 'Welcome Back!',
          'login.login.dialog.success.content': 'You have study for @studyCount times!',
          'login.login.error.unregisteredEmail': 'No user found for that email.',
          'login.login.error.wrongPassword': 'Wrong password provided for that user.',
          'login.login.error.unverifiedEmail': 'Please verify your email.',
          // Review Word
          'review.word.common.words': 'words',
          'review.word.home.allCourse.title': 'All Course',
          'review.word.home.myWord.title': 'My Words',
          'review.word.home.myWord.allWord': 'All words',
          'review.word.home.myWord.likedWord': 'Liked words',
          'review.word.home.myWord.forgottenWord': 'Forgotten words',
          'review.word.home.error.noWord': 'Oops, No words here',
          'review.word.search.empty': 'Empty',
          'review.word.toast.changeSpeaker': 'Change to @gender speaker',
          'review.word.toast.changeSpeaker.male': 'male',
          'review.word.toast.changeSpeaker.female': 'female',
          'review.word.card.lastCard': 'Last card reached. Swipe left will go to first card',
          // Ui view
          'ui.charts.summary':'Summary',
        },
        'ja_JP': {
          // Common
          'button.close': '閉じる',
          'error.oops': 'あら？',
          'error.permission.mic':'マイクの使用を許可してください',
          'error.unknown.title': '予想外のエラーです',
          'error.unknown.content': '予期せぬエラーが発生しました。',
          //Home
          'home.panel.study.title': '勉強',
          'home.panel.discover.title': '発現',
          'home.panel.review.title': '復習',
          'home.panel.account.title': '設定',
          // Login
          'login.common.email': 'メールアドレス',
          'login.common.password': 'パスワード',
          'login.common.error.emailFormat': '正しいメールを入力してください',
          'login.common.error.required': '必要項目です',
          'login.register.tab.title': '登録',
          'login.register.button.signUp': '登録',
          'login.register.button.forgotPassword': 'パスワードを忘れた？',
          'login.register.form.name': 'ID',
          'login.register.form.passwordConfirm': 'パスワード（確認用）',
          'login.register.confirmEmail.title': 'あと一歩',
          'login.register.confirmEmail.content':
              '検証用のメールを@emailへ送信しました。メールのリンクを沿ってアカウントをアクティブしてください。',
          'login.register.error.tooShort': '6位以上設定してください',
          'login.register.error.tooLong': '長すぎます',
          'login.register.error.passwordConfirmError': 'パスワードは一致しません',
          'login.register.error.registeredEmail': 'このメールアドレスは既に他のアカウントと関連しています',
          'login.login.tab.title': 'ログイン',
          'login.login.button.login': 'ログイン',
          'login.login.dialog.resentEmail': 'メールを再送',
          'login.login.dialog.success.title': 'お帰りなさい！',
          'login.login.dialog.success.content': '@studyCount回目の勉強を頑張りましょう！',
          'login.login.error.unregisteredEmail': '登録されていないメールアドレスです。',
          'login.login.error.wrongPassword': 'パスワードが間違えました。',
          'login.login.error.unverifiedEmail': 'メールアドレスを認証してください。',
          // Review Word
          'review.word.common.words': '単語',
          'review.word.home.allCourse.title': 'クラスリスト',
          'review.word.home.myWord.title': 'マイ単語',
          'review.word.home.myWord.allWord': 'すべての単語',
          'review.word.home.myWord.likedWord': 'お気に入りの単語',
          'review.word.home.myWord.forgottenWord': '忘れた単語',
          'review.word.home.error.noWord': 'あら、単語がないみたい',
          'review.word.search.empty': 'なし',
          'review.word.toast.changeSpeaker': 'スピーカを@genderに変更',
          'review.word.toast.changeSpeaker.male': '男性',
          'review.word.toast.changeSpeaker.female': '女性',
          'review.word.card.lastCard': '最後のカードです。左にスワイプすると初めに戻ります。',
          // Ui
          'ui.charts.summary':'総評',
        }
      };
}
