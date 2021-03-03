// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 📦 Package imports:
import 'package:flutter_beautiful_popup/main.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/service/app_state_service.dart';
import 'package:c_school_app/service/user_service.dart';
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
    } else if (result == 'login.login.error.unverifiedEmail'.tr) {
      _showErrorPopup(result, extraAction: {
        'label': 'login.login.dialog.resentEmail'.tr,
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
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void handleGoogleLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithGoogle();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else if(result=='abort'){
      return;
    }else{
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void handleTwitterLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithTwitter();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void handleForgetPassword() {}

  void handleAppleLogin() async {
    var result = await apiService.firebaseAuthApi.loginWithApple();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void _showErrorPopup(String content, {Map<String, dynamic> extraAction}) {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateFail,
    );
    final actions = [
      popup.button(
        label: 'button.close'.tr,
        onPressed: () => Get.back(),
      )
    ];
    if (extraAction != null) {
      actions.add(popup.button(
          label: extraAction['label'], onPressed: extraAction['onPressed']));
    }
    popup.show(title: 'error.oops'.tr, content: content, actions: actions
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
        label: 'button.close'.tr,
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
    final content = 'login.login.dialog.success.content'
        .trParams({'studyCount':'${AppStateService.startCount + 1}'});

    popup.show(
        title: 'login.login.dialog.success.title'.tr,
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
      title: 'login.register.confirmEmail.title'.tr,
      content:
          'login.register.confirmEmail.content'
              .trParams({'email':email}),
      actions: [
        popup.button(
          label: 'button.close'.tr,
          onPressed: Navigator.of(context).pop,
        ),
      ],
      // bool barrierDismissible = false,
      // Widget close,
    );
  }
}
