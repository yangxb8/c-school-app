import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LoggerService extends GetxService {
  static final Logger logger = Logger(
      printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: false,
  ));
}
