import 'package:flutter/material.dart';
import 'package:worldofgoals/src/core/config/app_config.dart';
import 'package:worldofgoals/src/core/utils/app_utils.dart';
import 'src/app.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  
  AppUtils.logger.i('Starting ${AppConfig.appName} v${AppConfig.appVersion}');
  
  runApp(const WorldOfGoalsApp());
}
