import 'package:flutter/material.dart';
import '../../services/session_manager.dart'; // Import SessionManager
import '../screens/login_screen.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import '../../../../core/utils/app_utils.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _sessionManager = SessionManager();
    _loadSession(); // Load session on initState
  }

  Future<void> _loadSession() async {
    await _sessionManager.loadSessionFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // Change Future<bool> to Future<String?>
      future: _sessionManager
          .checkForExistingSession(), // Use checkForExistingSession
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          AppUtils.logger.e('Session check failed', error: snapshot.error);
          return const LoginScreen();
        }

        final sessionToken = snapshot.data; // Get session token from snapshot
        final isLoggedIn =
            sessionToken != null; // Check if session token exists

        if (isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const LoginScreen(); // Return LoginScreen directly
        }
      },
    );
  }
}
