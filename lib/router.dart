// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:c_school_app/service/app_state_service.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:i18n_extension/i18n_widget.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/review_panel/controller/review_words_home_screen_controller.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_home_screen.dart';
import 'package:c_school_app/service/user_service.dart';
import 'app/login/controller/login_controller.dart';
import 'app/login/login_page.dart';
import 'app/main_app_controller.dart';
import 'app/main_app_home_screen.dart';
import 'app/review_panel/controller/review_words_controller.dart';
import 'app/review_panel/review_words_screen//review_words_screen.dart';

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
          middlewares: [HomeRouteMiddleware()],
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

class HomeRouteMiddleware extends GetMiddleware{
  
  @override
  RouteSettings redirect(String route) {
    if(UserService.user.isLogin()){
      if(AppStateService.isDebug){
        return null;
      }
      return RouteSettings(name: '/review/words/home'); //TODO: For beta test
    } else {
    return RouteSettings(name: '/login');
    }
  }
}
