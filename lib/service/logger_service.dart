// 📦 Package imports:
import 'package:logger/logger.dart';

class LoggerService {
  static final Logger logger = Logger(
      printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: false,
  ));

  /// For redirect log from getx
  static void getLogWriter(String text, {bool isError = false}) {
    if (isError) {
      logger.e(text);
    } else {
      logger.i(text);
    }
  }
}
