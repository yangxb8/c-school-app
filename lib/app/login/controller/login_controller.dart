// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/service/app_state_service.dart';
import 'package:c_school_app/service/user_service.dart';
import '../../../service/api_service.dart';

class LoginController extends GetxController {
  final ApiService apiService = Get.find();
  RxBool processing = false.obs;

  final GlobalKey<FormFieldState> loginEmailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> loginPasswordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupEmailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupPasswordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupNamelKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupConfirmPasswordlKey = GlobalKey<FormFieldState>();

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
      signupNamelKey.currentState!.validate(),
      signupEmailKey.currentState!.validate(),
      signupPasswordKey.currentState!.validate(),
      signupConfirmPasswordlKey.currentState!.validate()
    ].every((e) => e);
    if (_validateAll) {
      signupNamelKey.currentState!.reset();
      signupEmailKey.currentState!.reset();
      signupPasswordKey.currentState!.reset();
      signupConfirmPasswordlKey.currentState!.reset();
      var result = await apiService.firebaseAuthApi.signUpWithEmail(
          formTexts['signupEmail']!, formTexts['signupPassword']!, formTexts['signupName']!);
      if (result == 'need email verify') {
        _showEmailVerificationPopup(formTexts['signupEmail']!);
      } else if (result != 'ok') {
        _showErrorPopup(result);
      }
    }
    processing.value = false;
  }

  Future<void> handleEmailLogin() async {
    processing.value = true;
    var _validateAll = [
      loginEmailKey.currentState!.validate(),
      loginPasswordKey.currentState!.validate()
    ].every((e) => e);
    if (!_validateAll) return;
    var result = await apiService.firebaseAuthApi
        .loginWithEmail(formTexts['loginEmail']!, formTexts['loginPassword']!);
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else if (result == 'login.login.error.unverifiedEmail'.tr) {
      _showErrorPopup(result, extraAction: [
        TextButton(
          onPressed: () {
            apiService.firebaseAuthApi.sendVerifyEmail();
            Get.back();
          },
          child: Text('login.login.dialog.resentEmail'.tr),
        )
      ]);
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
    } else if (result == 'abort') {
      return;
    } else {
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

  void _showErrorPopup(String content, {List<Widget> extraAction = const []}) {
    Get.defaultDialog(
      title: 'error.oops'.tr,
      content: Text(content),
      textConfirm: 'button.close'.tr,
      onConfirm: () => Get.back(),
      actions: extraAction,
    );
  }

  void _showLoginSuccessPopup() {
    Get.defaultDialog(
        title: 'login.login.dialog.success.title'.tr,
        content: Text('login.login.dialog.success.content'
            .trParams({'studyCount': '${AppStateService.startCount + 1}'})!),
        textConfirm: 'button.close'.tr,
        onConfirm: () {
          if (UserService.isLectureServiceInitialized.isTrue!) {
            Get.offAllNamed('/home');
          } else {
            processing.value = true;
            once(UserService.isLectureServiceInitialized, (dynamic _) {
              processing.value = false;
              Get.offAllNamed('/home');
            });
          }
        });
  }

  void _showEmailVerificationPopup(String email) {
    Get.defaultDialog(
      title: 'login.register.confirmEmail.title'.tr,
      content: Text('login.register.confirmEmail.content'.trParams({'email': email})!),
      textConfirm: 'button.close'.tr,
      onConfirm: () => Get.back(),
    );
  }
}
