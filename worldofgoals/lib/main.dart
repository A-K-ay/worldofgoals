import 'package:flutter/material.dart';
import 'package:worldofgoals/src/core/config/app_config.dart';
import 'package:worldofgoals/src/core/theme/app_theme.dart';
import 'package:worldofgoals/src/core/database/database.dart';
import 'package:worldofgoals/src/core/utils/app_utils.dart';
import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final database = AppDatabase();
  
  AppUtils.logger.i('Starting ${AppConfig.appName} v${AppConfig.appVersion}');
  
  runApp(const WorldOfGoalsApp());
}
