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
          pendingRequests = data['pending_requests'];
        });
        print('Pending requests count: ${pendingRequests.length}');
        print('First pending request: ${pendingRequests.isNotEmpty ? pendingRequests[0] : "None"}');
      }
    } else {
      print('Failed to fetch pending requests');
    }
    print(pendingRequests.runtimeType); // Should be List
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
        ],
      ),
      body: pendingRequests.isEmpty
          ? Center(child: Text('No pending approval requests'))
          : ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final user = pendingRequests[index];
                return ListTile(
                  title: Text(user['username'] ?? ''),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Text(user['role'] ?? ''),
                );
              },
            ),
    );
  }
}