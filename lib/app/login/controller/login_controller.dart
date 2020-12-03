import 'package:c_school_app/service/app_state_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_beautiful_popup/main.dart';
import '../../../service/api_service.dart';
import '../../../i18n/api_service.i18n.dart';
import '../../../i18n/login_page.i18n.dart';

class LoginController extends GetxController {
  final ApiService apiService = Get.find();
  final BuildContext context = Get.context;

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
  }

  Future<void> handleEmailLogin() async {
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
  }

  void handleFacebookLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithFacebook();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('Something is wrong!'.i18n);
    }
  }

  void handleGoogleLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithGoogle();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('Something is wrong!'.i18n);
    }
  }

  void handleTwitterLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithTwitter();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('Something is wrong!'.i18n);
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

  void handleAnonymousLogin() async {
    var result = await apiService.firebaseAuthApi.loginAnonymous();
    if (result == 'ok') {
      //TODO: change this, only for words-list test
      await Get.offAllNamed('/review/words/home');
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
          // After login user should not press 'back' and return to login page
          //TODO: change this, only for words-list test
          Get.offAllNamed('/review/words/home');
        },
      )
    ];
    // TODO: get study daycount properly
    final content = 'You have study for %d times!'
        .i18n
        .fill([AppStateService.systemInfo.startCount]);

    popup.show(
        title: 'Welcome Back!'.i18n,
        content: content,
        actions: actions,
        close: Container()
        // bool barrierDismissible = false,
        // Widget close,
        );
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
