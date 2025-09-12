import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'env.dart';

Future<List<Map<String, dynamic>>> fetchPendingApprovals() async {
  final uri = Uri.parse('${Env.baseUrl}/get_pending_requests.php');
  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
  }
  final body = jsonDecode(resp.body);
  final list = (body['pending'] ?? []) as List;
  if (list.isEmpty) {
    // Show "No pending requests."
  } else {
    // Show the list of pending requests
  }
  return list.map((e) => Map<String, dynamic>.from(e)).toList();
}

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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => showApprovalRequestsDialog(context),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPendingApprovals(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No pending approvals.'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final u = items[i];
              return ListTile(
                title: Text(u['username'] ?? ''),
                subtitle: Text(u['email'] ?? ''),
                trailing: Text(u['role'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> showApprovalRequestsDialog(BuildContext context) async {
  print('Dialog opened');
  final pending = await fetchPendingApprovals();
  print('Dialog pending: $pending');
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Account Approval Requests'),
      content: pending.isEmpty
          ? const Text('No pending requests.')
          : SizedBox(
              width: 300,
              child: ListView(
                shrinkWrap: true,
                children: pending.map((u) => ListTile(
                  title: Text(u['username'] ?? ''),
                  subtitle: Text(u['email'] ?? ''),
                  trailing: Text(u['role'] ?? ''),
                )).toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}