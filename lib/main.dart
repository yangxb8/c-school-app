import 'dart:io';
import 'package:spoken_chinese/service/class_service.dart';

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
  await initServices();
  Logger.level = Get.find<AppStateService>().systemInfo.isDebugMode
      ? Level.debug
      : Level.error;
  runApp(SpokenChineseApp());
}

Future<void> initServices() async {
  await Get.putAsync<LocalStorageService>(
      () async => await LocalStorageService.getInstance());
  await Get.putAsync<ApiService>(() async => await ApiService.getInstance());
  await Flamingo.initializeApp();
  Get.put<LoggerService>(LoggerService());
  Get.put<AppStateService>(AppStateService.getInstance());
  await Get.putAsync<ClassService>(() async => await ClassService.getInstance());
  Get.lazyPut<SpeechRecordingController>(() => SpeechRecordingController());
}

class SpokenChineseApp extends GetView<AppStateService> {
  final logger = Get.find<LoggerService>().logger;

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
    return GetMaterialApp(
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
        //TODO: change default route, only for words-list test
        initialRoute:
            controller.systemInfo.startCount == 0 ? '/login' : '/review/words/home');
  }
}
