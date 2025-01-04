import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';

class WorldOfGoalsApp extends StatelessWidget {
  const WorldOfGoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World of Goals',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) =>  HomeScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes here if needed
        return null;
      },
      onUnknownRoute: (settings) {
        // Fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}
