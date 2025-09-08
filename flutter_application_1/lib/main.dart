import 'package:flutter/material.dart';
import 'login_page.dart';
import 'registration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartPage(),
    );
  }
}


class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Management System')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
              ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegistrationPage()));
                },
                child: const Text('Create a New Account', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
              ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text('Already Have an Account', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

