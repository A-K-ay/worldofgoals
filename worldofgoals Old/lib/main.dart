import 'package:flutter/material.dart';
import 'package:worldofgoals/src/core/config/app_config.dart';
import 'package:worldofgoals/src/core/theme/app_theme.dart';
import 'package:worldofgoals/src/core/database/database.dart';
import 'package:worldofgoals/src/core/utils/app_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final database = AppDatabase();
  
  AppUtils.logger.i('Starting ${AppConfig.appName} v${AppConfig.appVersion}');
  
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to GoalQuest'),
        ),
      ),
    );
  }
}
