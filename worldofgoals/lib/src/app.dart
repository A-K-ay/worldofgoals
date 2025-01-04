import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/home/presentation/screens/home_screen.dart';

class WorldOfGoalsApp extends StatelessWidget {
  const WorldOfGoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
        },
      ),
    );
  }
}
