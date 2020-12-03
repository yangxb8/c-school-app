import 'dart:async';
import 'dart:io';
import 'package:c_school_app/service/class_service.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:splashscreen/splashscreen.dart';

import './service/app_state_service.dart';

import 'app_theme.dart';
import 'controller/ui_view_controller/speech_recording_controller.dart';
import 'router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:flamingo/flamingo.dart';

import 'service/api_service.dart';
import 'service/localstorage_service.dart';
import 'service/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(CSchoolApp());
}

class CSchoolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return KeyboardDismisser(
        child: GetMaterialApp(
            title: 'Chinese Classroom',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: AppTheme.textTheme,
              platform: TargetPlatform.iOS,
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ja', 'JP'),
            ],
            getPages: AppRouter.setupRouter(),
            home: Splash(),
        ));
  }
}

class Splash extends StatelessWidget {
  Future<void> _loadFromFuture() async {
    await initServices();
    await Get.toNamed(UserService.user.isLogin() ? '/review/words/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        navigateAfterFuture: _loadFromFuture(),
        title: Text(
          'C!School',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: Image.network('https://i.imgur.com/TyCSG9A.png'),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
}

Future<void> initServices() async {
  await Get.putAsync<LocalStorageService>(
      () async => await LocalStorageService.getInstance());
  await Get.putAsync<ApiService>(() async => await ApiService.getInstance());
  await Flamingo.initializeApp();
  Get.put<LoggerService>(LoggerService());
  Get.put<AppStateService>(AppStateService.getInstance());
  await Get.putAsync<UserService>(() async => await UserService.getInstance());
  await Get.putAsync<ClassService>(
      () async => await ClassService.getInstance());
  Get.lazyPut<SpeechRecordingController>(() => SpeechRecordingController());
  Logger.level =
      AppStateService.systemInfo.isDebugMode ? Level.debug : Level.error;
}
