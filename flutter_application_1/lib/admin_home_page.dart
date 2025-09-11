import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/env.dart'; // <-- Import the Env class

class AdminHomePage extends StatefulWidget {
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
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List pendingRequests = [];

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_pending_requests.php'),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['pending_requests'] != null) {
        setState(() {
          pendingRequests = (data['pending_requests'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        });
        print('Pending requests count: ${pendingRequests.length}');
        print('First pending request: ${pendingRequests.isNotEmpty ? pendingRequests[0] : "None"}');
      }
    } else {
      print('Failed to fetch pending requests');
    }
    print('pendingRequests type: ${pendingRequests.runtimeType}');
    print('pendingRequests: $pendingRequests');
  }

  void _showApprovalRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Approval Requests'),
        content: pendingRequests.isEmpty
            ? Text('No pending requests.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (var user in pendingRequests)
                      ListTile(
                        title: Text(user['username'] ?? ''),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: Text(user['role'] ?? ''),
                      ),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchPendingRequests,
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _showApprovalRequestsDialog,
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var user in pendingRequests)
            ListTile(
              title: Text(user['username'] ?? ''),
              subtitle: Text(user['email'] ?? ''),
              trailing: Text(user['role'] ?? ''),
            ),
        ],
      ),
    );
  }
}