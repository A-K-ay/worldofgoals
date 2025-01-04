import 'package:flutter/material.dart';
import '../../services/local_auth_provider.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authProvider = LocalAuthProvider();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isSignedIn = await _authProvider.isSignedIn();
    if (mounted) {
      setState(() {
        _isAuthenticated = isSignedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const MaterialApp(
        home: LoginScreen(),
      );
    }

    return widget.child;
  }
}
