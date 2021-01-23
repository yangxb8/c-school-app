import 'dart:async';
import 'dart:io';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:catcher/catcher.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:wiredash/wiredash.dart';
import './service/app_state_service.dart';
import 'app_theme.dart';
import 'router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:flamingo/flamingo.dart';

import 'util/extensions.dart';
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
    SentryHandler(SentryClient(SentryOptions(
        dsn:
            'https://6b7250fbad81463791e2036ffdd6b184@o455157.ingest.sentry.io/5446301')))
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
  Future<void> _init() async {
    await initServices();
    // TODO: Only for development, might need a proper way to upload our class
    // if (AppStateService.isDebug) {
    //   await Get.find<ApiService>().firestoreApi.uploadLecturesByCsv();
    //   await Get.find<ApiService>().firestoreApi.uploadWordsByCsv();
    // }
    await Get.toNamed(UserService.user.isLogin() ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/splash/splash.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    ).afterFirstLayout(_init);
  }
}

Future<void> initServices() async {
  await Get.putAsync<LocalStorageService>(
      () async => await LocalStorageService.getInstance());
  await Get.putAsync<ApiService>(() async => await ApiService.getInstance());
  await Flamingo.initializeApp();
  await Get.putAsync<UserService>(() async => await UserService.getInstance());
  await Get.putAsync<LectureService>(
      () async => await LectureService.getInstance());
  Logger.level = AppStateService.isDebug ? Level.debug : Level.error;
}
