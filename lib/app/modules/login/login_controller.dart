// 🐦 Flutter imports:

// 🌎 Project imports:

// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../core/utils/helper/api_helper.dart';
import '../../data/service/app_state_service.dart';

class LoginController extends GetxController {
  final FirebaseAuthApiHelper apiHelper = FirebaseAuthApiHelper();
  Map<String, String> formTexts = {
    'loginEmail': '',
    'loginPassword': '',
    'signupEmail': '',
    'signupPassword': '',
    'signupName': ''
  };

  final GlobalKey<FormFieldState> loginEmailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> loginPasswordKey =
      GlobalKey<FormFieldState>();

  RxBool processing = false.obs;
  final GlobalKey<FormFieldState> signupConfirmPasswordlKey =
      GlobalKey<FormFieldState>();

  final GlobalKey<FormFieldState> signupEmailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupNamelKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> signupPasswordKey =
      GlobalKey<FormFieldState>();

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
      var result = await apiHelper.signUpWithEmail(formTexts['signupEmail']!,
          formTexts['signupPassword']!, formTexts['signupName']!);
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
    var result = await apiHelper.loginWithEmail(
        formTexts['loginEmail']!, formTexts['loginPassword']!);
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else if (result == 'login.login.error.unverifiedEmail'.tr) {
      _showErrorPopup(result, extraAction: [
        TextButton(
          onPressed: () {
            apiHelper.sendVerifyEmail();
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
    var result = await apiHelper.loginWithFacebook();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void handleGoogleLogin() async {
    var result = await apiHelper.loginWithGoogle();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else if (result == 'abort') {
      return;
    } else {
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void handleTwitterLogin() async {
    var result = await apiHelper.loginWithTwitter();
    if (result == 'ok') {
      _showLoginSuccessPopup();
    } else {
      _showErrorPopup('error.unknown.title'.tr);
    }
  }

  void handleForgetPassword() {}

  void handleAppleLogin() async {
    var result = await apiHelper.loginWithApple();
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
          if (AppStateService.fullyInitialized) {
            Get.offAllNamed('/home');
          } else {
            processing.value = true;
            Timer.periodic(0.5.seconds, (timer) {
              if (AppStateService.fullyInitialized) {
                timer.cancel();
                Get.offAllNamed('/home');
              }
            });
          }
        });
  }

  void _showEmailVerificationPopup(String email) {
    Get.defaultDialog(
      title: 'login.register.confirmEmail.title'.tr,
      content: Text(
          'login.register.confirmEmail.content'.trParams({'email': email})!),
      textConfirm: 'button.close'.tr,
      onConfirm: () => Get.back(),
    );
  }
}
