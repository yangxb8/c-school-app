// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 📦 Package imports:
import 'package:flutter_beautiful_popup/main.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/service/app_state_service.dart';
import 'package:c_school_app/service/user_service.dart';
import '../../../i18n/api_service.i18n.dart';
import '../../../i18n/login_page.i18n.dart';
import '../../../service/api_service.dart';

class LoginController extends GetxController {
  final ApiService apiService = Get.find();
  final BuildContext context = Get.context;
  RxBool processing = false.obs;

  final GlobalKey<FormFieldState> loginEmailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> loginPasswordKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupEmailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupPasswordKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupNamelKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupConfirmPasswordlKey =
      GlobalKey<FormFieldState>();

  Map<String, String> formTexts = {
    'loginEmail': '',
    'loginPassword': '',
    'signupEmail': '',
    'signupPassword': '',
    'signupName': ''
  };

  Future<void> handleEmailSignUp() async {
    processing.value = true;
    var _validateAll = [
      signupNamelKey.currentState.validate(),
      signupEmailKey.currentState.validate(),
      signupPasswordKey.currentState.validate(),
      signupConfirmPasswordlKey.currentState.validate()
    ].every((e) => e);
    if (_validateAll) {
      signupNamelKey.currentState.reset();
      signupEmailKey.currentState.reset();
      signupPasswordKey.currentState.reset();
      signupConfirmPasswordlKey.currentState.reset();
      var result = await apiService.firebaseAuthApi.signUpWithEmail(
          formTexts['signupEmail'],
          formTexts['signupPassword'],
          formTexts['signupName']);
      if (result == 'need email verify') {
        _showEmailVerificationPopup(context, formTexts['signupEmail']);
      } else if (result != 'ok') {
        _showErrorPopup(result);
      }
    }
    processing.value = false;
  }

  Future<void> handleEmailLogin() async {
    processing.value = true;
    var _validateAll = [
      loginEmailKey.currentState.validate(),
      loginPasswordKey.currentState.validate()
    ].every((e) => e);
    if (!_validateAll) return;
    var result = await apiService.firebaseAuthApi
        .loginWithEmail(formTexts['loginEmail'], formTexts['loginPassword']);
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else if (result == 'Please verify your email.'.i18nApi) {
      _showErrorPopup(result, extraAction: {
        'label': 'Resend email'.i18n,
        'onPressed': () {
          apiService.firebaseAuthApi.sendVerifyEmail();
          Get.back();
        }
      });
    } else {
      _showErrorPopup(result);
    }
    processing.value = false;
  }

  void handleFacebookLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithFacebook();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('Something is wrong!'.i18nApi);
    }
  }

  void handleGoogleLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithGoogle();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else if(result=='abort'){
      return;
    }else{
      _showErrorPopup('Something is wrong!'.i18nApi);
    }
  }

  void handleTwitterLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithTwitter();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('Something is wrong!'.i18nApi);
    }
  }

  void handleForgetPassword() {}

  void handleAppleLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithApple();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('Something is wrong!'.i18n);
    }
  }

  void _showErrorPopup(String content, {Map<String, dynamic> extraAction}) {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateFail,
    );
    final actions = [
      popup.button(
        label: 'Close'.i18n,
        onPressed: () => Get.back(),
      )
    ];
    if (extraAction != null) {
      actions.add(popup.button(
          label: extraAction['label'], onPressed: extraAction['onPressed']));
    }
    popup.show(title: 'Oops?'.i18n, content: content, actions: actions
        // bool barrierDismissible = false,
        // Widget close,
        );
  }

  void _showLoginSuccessPopup() {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateBlueRocket,
    );
    final actions = [
      popup.button(
        label: 'Close'.i18n,
        onPressed: () {
          if (UserService.isLectureServiceInitialized.isTrue) {
            Get.offAllNamed('/home');
          } else {
            processing.value = true;
            once(UserService.isLectureServiceInitialized, (_) {
              processing.value = false;
              Get.offAllNamed('/home');
            });
          }
        },
      )
    ];
    final content = 'You have study for %d times!'
        .i18n
        .fill([AppStateService.startCount + 1]);

    popup.show(
        title: 'Welcome Back!'.i18n,
        content: content,
        actions: actions,
        close: Container());
  }

  void _showEmailVerificationPopup(BuildContext context, String email) {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateSuccess,
    );
    popup.show(
      title: 'Almost there'.i18nApi,
      content:
          'We have sent your an Email at %s, follow the link there to verify your account!'
              .i18nApi
              .fill([email]),
      actions: [
        popup.button(
          label: 'Close'.i18nApi,
          onPressed: Navigator.of(context).pop,
        ),
      ],
      // bool barrierDismissible = false,
      // Widget close,
    );
  }
}
