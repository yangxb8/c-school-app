import 'package:c_school_app/app/review_panel/controller/review_words_home_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_home_screen.dart';
import 'app/login/login_page.dart';
import 'app/main_app_home_screen.dart';
import 'app/review_panel/review_words_screen//review_words_screen.dart';
import 'app/login/controller/login_controller.dart';
import 'controller/main_app_controller.dart';
import 'app/review_panel/controller/review_words_controller.dart';

class AppRouter {
  static const Locale DEFAULT_LOCALE = Locale('ja', 'JP');

  static List<GetPage> setupRouter() {
    return [
      GetPage(
          name: '/login',
          page: () => I18n(initialLocale: DEFAULT_LOCALE, child: LoginPage()),
          binding: BindingsBuilder(
              () => {Get.lazyPut<LoginController>(() => LoginController())})),
      GetPage(
          name: '/home',
          page: () =>
              I18n(initialLocale: DEFAULT_LOCALE, child: MainAppHomeScreen()),
          binding: BindingsBuilder(() =>
              {Get.lazyPut<MainAppController>(() => MainAppController())})),
      GetPage(
          name: '/review/words/home',
          page: () => I18n(
              initialLocale: DEFAULT_LOCALE, child: ReviewWordsHomeScreen()),
          binding: BindingsBuilder(() => {
                Get.lazyPut<ReviewWordsHomeController>(
                    () => ReviewWordsHomeController())
              })),
      GetPage(
          name: '/review/words',
          page: () => I18n(initialLocale: DEFAULT_LOCALE, child: ReviewWords()),
          binding: BindingsBuilder(() => {
                Get.lazyPut<ReviewWordsController>(
                    () => ReviewWordsController())
              })),
    ];
  }
}
