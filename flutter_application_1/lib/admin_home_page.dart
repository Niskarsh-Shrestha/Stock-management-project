import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'env.dart';

class AdminHomePage extends StatelessWidget {
  final String username;
  final String email;
  final String role;

  const AdminHomePage({
    Key? key,
    required this.username,
    required this.email,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        // Removed notification icon
      ),
      body: Center(
        child: Text('Welcome, $username!'),
      ),
    );
  }
}

// Remove fetchPendingApprovals and showApprovalRequestsDialog functions