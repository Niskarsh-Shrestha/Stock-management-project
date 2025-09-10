import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';
import 'auth_headers.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<dynamic> users = [];
  List<Map<String, dynamic>> roles = [];
  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
    fetchUsers();
    fetchRoles();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_users.php'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      users = List<Map<String, dynamic>>.from(data['users']);
    });
  }

  Future<void> fetchRoles() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_roles.php'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      roles = List<Map<String, dynamic>>.from(data['roles']);
    });
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedRole;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New User'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  hint: const Text('Select Role'),
                  items: roles.map<DropdownMenuItem<String>>((role) {
                    return DropdownMenuItem<String>(
                      value: role['role_name'] as String,
                      child: Text(role['role_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedRole = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addUser(
                usernameController.text.trim(),
                emailController.text.trim(),
                passwordController.text,
                selectedRole ?? '',
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser(String username, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/add_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'User creation failed')),
    );
    fetchUsers();
  }

  void _showEditUserDialog(BuildContext context, Map user) {
    final usernameController = TextEditingController(text: user['username']);
    final emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  hint: const Text('Select Role'),
                  items: roles.map<DropdownMenuItem<String>>((role) {
                    return DropdownMenuItem<String>(
                      value: role['role_name'] as String,
                      child: Text(role['role_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedRole = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _editUser(
                int.parse(user['id'].toString()),
                usernameController.text.trim(),
                emailController.text.trim(),
                selectedRole,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editUser(int id, String username, String email, String role) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/edit_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'username': username,
        'email': email,
        'role': role,
      }),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'User update failed')),
    );
    fetchUsers();
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final response = await _client.post(
        Uri.parse('${Env.baseUrl}/delete_user.php'),
        headers: AuthHeaders.value,
        body: {'id': id},
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Delete failed')),
      );
      fetchUsers();
    }
  }

  Future<void> addUser(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/add_user.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> editUser(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/edit_user.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> deleteUser(int id) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/delete_user.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showAddUserDialog(context),
                child: const Text('Add User', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text('${user['username']} (${user['role']})'),
                  subtitle: Text(user['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditUserDialog(context, user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(int.parse(user['id'].toString())),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}