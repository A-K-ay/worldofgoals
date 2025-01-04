import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class AppUtils {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static String generateUuid() {
    return const Uuid().v4();
  }

  static int calculateXp(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 50;
      case 'medium':
        return 100;
      case 'hard':
        return 200;
      default:
        return 0;
    }
  }

  static int calculateLevel(int xp) {
    return (xp / 1000).floor() + 1;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
