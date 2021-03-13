// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:catcher/catcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flamingo/flamingo.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:wiredash/wiredash.dart';

// 🌎 Project imports:
import 'package:c_school_app/i18n/wiredash_translation.dart';
import 'package:c_school_app/service/audio_service.dart';
import 'package:c_school_app/service/user_service.dart';
import './service/app_state_service.dart';
import 'app_theme.dart';
import 'i18n/messages.dart';
import 'router.dart';
import 'service/api_service.dart';
import 'service/localstorage_service.dart';
import 'util/extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  /// Debug configuration with dialog report mode and console handler. It will show dialog and once user accepts it, error will be shown   /// in console.
  var debugOptions = CatcherOptions(SilentReportMode(), [ConsoleHandler()]);

  /// Release configuration. Same as above, but once user accepts dialog, user will be prompted to send email with crash to support.
  var releaseOptions = CatcherOptions(SilentReportMode(), [
    SentryHandler(SentryClient(SentryOptions(
        dsn: 'https://6b7250fbad81463791e2036ffdd6b184@o455157.ingest.sentry.io/5446301')))
  ]);
  Catcher(rootWidget: CSchoolApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);
}

class CSchoolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return KeyboardDismisser(
        child: Wiredash(
      options: WiredashOptionsData(
        customTranslations: {
          const Locale.fromSubtags(languageCode: 'jp'):
          const CSchoolTranslations(),
        },
        locale: const Locale('jp'),
      ),
      projectId: 'c-school-iysnrje',
      secret: 'rbl6r14rthdvtkruhfu0lvlldp6rpq3pepclnowm1q6ui08u',

      /// We use Catcher's navigatorKey here also for Wiredash
      navigatorKey: Catcher.navigatorKey!,
      child: GetMaterialApp(
        title: 'CSchool',
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.fade,
        navigatorKey: Catcher.navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: AppTheme.textTheme,
        ),
        translations: Messages(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('ja', 'JP'),
        getPages: AppRouter.setupRouter(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        ],
        home: Splash(),
      ),
    ));
  }
}

class Splash extends StatelessWidget {
  Future<void> _init() async {
    await initServices();
    await Get.toNamed('/home');
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
  await Get.putAsync<LocalStorageService>(() async => await LocalStorageService.getInstance());
  await Get.putAsync<ApiService>(() async => await ApiService.getInstance());
  await Flamingo.initializeApp();
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  await Get.putAsync<UserService>(() async => await UserService.getInstance());
  Get.lazyPut<AudioService>(() => AudioService());
  Logger.level = AppStateService.isDebug ? Level.debug : Level.error;
}
