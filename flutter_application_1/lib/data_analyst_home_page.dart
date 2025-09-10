import 'package:flutter/material.dart';
import 'env.dart';

class DataAnalystHomePage extends StatelessWidget {
  final String username;
  final String email;
  final String role;

  const DataAnalystHomePage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Analyst Dashboard'),
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $username ($role)', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const Text('Analyze stock status and send notifications to all users.'),
            // Add your analytics and notification features here
          ],
        ),
      ),
    );
  }
}