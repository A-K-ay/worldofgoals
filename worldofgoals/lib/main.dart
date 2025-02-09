import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worldofgoals/src/core/config/app_config.dart';
import 'package:worldofgoals/src/core/utils/app_utils.dart';
import 'package:worldofgoals/src/features/tasks/presentation/cubits/task_cubit.dart';
import 'src/app.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'src/core/database/services/database_service.dart';
import 'src/core/database/repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

  AppUtils.logger.i('Starting ${AppConfig.appName} v${AppConfig.appVersion}');

  runApp(
    MultiProvider(
      // Wrap WorldOfGoalsApp with MultiProvider
      providers: [Provider<TasksCubit>(create: (_) => TasksCubit())],
      child: const WorldOfGoalsApp(),
    ),
  );
}
