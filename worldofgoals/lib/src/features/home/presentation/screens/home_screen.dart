import 'package:flutter/material.dart';
import '../../../auth/services/local_auth_provider.dart';

class HomeScreen extends StatelessWidget {
  final _authProvider = LocalAuthProvider();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World of Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to World of Goals!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
