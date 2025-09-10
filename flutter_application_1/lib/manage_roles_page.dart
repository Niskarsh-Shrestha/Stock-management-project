import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env.dart';

class ManageRolesPage extends StatefulWidget {
  const ManageRolesPage({super.key});

  @override
  State<ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends State<ManageRolesPage> {
  List<dynamic> roles = [];
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_roles.php'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      roles = data['roles'];
    });
  }

  void _showAddRoleDialog(BuildContext context) {
    final roleNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Role'),
        content: TextField(
          controller: roleNameController,
          decoration: const InputDecoration(labelText: 'Role Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addRole(roleNameController.text.trim());
            },
            child: const Text('Add Role'),
          ),
        ],
      ),
    );
  }

  Future<void> _addRole(String roleName) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/add_role.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': roleName}),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Role creation failed')),
    );
    fetchRoles();
  }

  void _showEditRoleDialog(BuildContext context, Map role) {
    final roleController = TextEditingController(text: role['role_name']);
    String editedRoleName = role['role_name'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Role'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => TextField(
            controller: roleController,
            decoration: const InputDecoration(labelText: 'Role Name'),
            onChanged: (value) {
              setStateDialog(() {
                editedRoleName = value;
              });
            },
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
              await _editRole(int.parse(role['id'].toString()), editedRoleName);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editRole(int id, String roleName) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/edit_role.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'role_name': roleName}),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Role update failed')),
    );
    fetchRoles();
  }

  Future<void> _deleteRole(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Role'),
        content: const Text('Are you sure you want to delete this role?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/delete_role.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Delete failed')),
      );
      fetchRoles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Roles')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showAddRoleDialog(context),
                child: const Text('Add Role', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final role = roles[index];
                return ListTile(
                  title: Text(role['role_name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditRoleDialog(context, role),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteRole(int.parse(role['id'].toString())),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedRole,
            hint: const Text('Select Role'),
            items: roles.map<DropdownMenuItem<String>>((role) {
              return DropdownMenuItem<String>(
                value: role['role_name'],
                child: Text(role['role_name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRole = value;
              });
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
        ],
      ),
    );
  }
}