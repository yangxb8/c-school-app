import 'dart:async';
import 'dart:io';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:catcher/catcher.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:wiredash/wiredash.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  /// Debug configuration with dialog report mode and console handler. It will show dialog and once user accepts it, error will be shown   /// in console.
  var debugOptions = CatcherOptions(SilentReportMode(), [ConsoleHandler()]);

  /// Release configuration. Same as above, but once user accepts dialog, user will be prompted to send email with crash to support.
  var releaseOptions = CatcherOptions(DialogReportMode(), [
    EmailManualHandler(['yangxb10@gmail.com'])
  ]);
  Catcher(
      rootWidget: CSchoolApp(),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions);
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
        child: Wiredash(
      projectId: 'c-school-iysnrje',
      secret: 'rbl6r14rthdvtkruhfu0lvlldp6rpq3pepclnowm1q6ui08u',

      /// We use Catcher's navigatorKey here also for Wiredash
      navigatorKey: Catcher.navigatorKey,
      child: GetMaterialApp(
        builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget),
          maxWidth: 1200,
          minWidth: 450,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(450, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          ]),
        title: 'CSchool',
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.fade,
        navigatorKey: Catcher.navigatorKey,
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
      ),
    ));
  }
}

class Splash extends StatelessWidget {
  void navigateToHome() async {
    await Get.toNamed(
        UserService.user.isLogin() ? '/review/words/home' : '/login');
  }

  Future<void> _loadFromFuture() async {
    await initServices();
    // TODO: Only for development, might need a proper way to upload our class
    if (AppStateService.isDebug) {
      await Get.find<ApiService>().firestoreApi.uploadLecturesByCsv();
      await Get.find<ApiService>().firestoreApi.uploadWordsByCsv();
    }
    await navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      navigateAfterFuture: _loadFromFuture(),
      imageBackground: Image.asset('assets/splash/splash.png').image,
      photoSize: 100.0,
      useLoader: false,
    );
  }
}

Future<void> initServices() async {
  await Get.putAsync<LocalStorageService>(
      () async => await LocalStorageService.getInstance());
  await Get.putAsync<ApiService>(() async => await ApiService.getInstance());
  await Flamingo.initializeApp();
  await Get.putAsync<UserService>(() async => await UserService.getInstance());
  Get.lazyPut<SpeechRecordingController>(() => SpeechRecordingController());
  await Get.putAsync<LectureService>(
      () async => await LectureService.getInstance());
  Logger.level = AppStateService.isDebug ? Level.debug : Level.error;
}
