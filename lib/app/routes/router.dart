// 🐦 Flutter imports:

// 🌎 Project imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../data/repository/user_repository.dart';
import '../data/service/app_state_service.dart';
import '../modules/home/home_page.dart';
import '../modules/login/login_controller.dart';
import '../modules/login/login_page.dart';
import '../modules/review_panel/review_words/review_words_detail_controller.dart';
import '../modules/review_panel/review_words/review_words_detail_page.dart';
import '../modules/review_panel/review_words/review_words_lecture_list_controller.dart';
import '../modules/review_panel/review_words/review_words_lecture_list_page.dart';

class AppRouter {
  static const Locale DEFAULT_LOCALE = Locale('ja', 'JP');

  static List<GetPage> setupRouter() {
    return [
      GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: BindingsBuilder(
              () => {Get.lazyPut<LoginController>(() => LoginController())})),
      GetPage(
          middlewares: [HomeRouteMiddleware()],
          name: '/home',
          page: () => MainAppHomeScreen()),
      GetPage(
          name: '/review/words/home',
          page: () => ReviewWordsHomeScreen(),
          binding: BindingsBuilder(() => {
                Get.lazyPut(
                    () => ReviewWordsHomeController())
              })),
      GetPage(
          name: '/review/words',
          page: () => ReviewWords(),
          binding: BindingsBuilder(() => {
                Get.lazyPut(
                    () => ReviewWordsController())
              })),
    ];
  }
}

class HomeRouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (UserRepository.isUserLogin.isTrue) {
      if (AppStateService.isDebug) {
        return null;
      }
      return RouteSettings(name: '/review/words/home'); //TODO: For beta test
    } else {
      return RouteSettings(name: '/login');
    }
  }
}
