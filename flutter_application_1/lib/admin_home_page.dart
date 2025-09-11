import 'package:flutter/material.dart';
import 'main.dart';
import 'product_list.dart';
import 'category_list.dart' as category_list;
import 'supplier_list.dart';
import 'dart:convert';
import 'http_client.dart' as http_client;
import 'package:http/http.dart' as http;
import 'manage_users_page.dart';
import 'manage_roles_page.dart';
import 'env.dart';

class AdminHomePage extends StatefulWidget {
  final String username;
  final String email;
  final String role;

  const AdminHomePage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<dynamic> users = [];
  List<dynamic> roles = [];
  int _lowStockCount = 0;
  List<Map<String, dynamic>> _lowStockProducts = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = http_client.createHttpClient();
    fetchUsers();
    fetchRoles();
    _fetchLowStockProducts();
    _fetchPendingRequests();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_users.php'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      users = data['users'];
    });
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

  Future<void> _fetchLowStockProducts() async {
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/get_product.php'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['products'] is List) {
          final products = List<Map<String, dynamic>>.from(decoded['products']);
          final lowStock = products.where((p) {
            final qty = int.tryParse(p['quantity'].toString()) ?? 0;
            return qty < 10;
          }).toList();
          setState(() {
            _lowStockCount = lowStock.length;
            _lowStockProducts = lowStock;
          });
        }
      }
    } catch (_) {
      setState(() {
        _lowStockCount = 0;
        _lowStockProducts = [];
      });
    }
  }

  Future<void> _fetchPendingRequests() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_pending_requests.php'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      _pendingRequests = List<Map<String, dynamic>>.from(data['requests'] ?? []);
    });
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${widget.username}'),
            Text('Email: ${widget.email}'),
            Text('Role: ${widget.role}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // <-- Use dialogContext here
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
        content: SingleChildScrollView(
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
                  return DropdownMenuItem(
                    value: role['role_name'],
                    child: Text(role['role_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value;
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
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

  Future<void> editUser(Map user) async {
    final usernameController = TextEditingController(text: user['username']);
    final emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: roles.map<DropdownMenuItem<String>>((role) {
                return DropdownMenuItem(
                  value: role['role_name'],
                  child: Text(role['role_name']),
                );
              }).toList(),
              onChanged: (value) {
                selectedRole = value!;
              },
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await http.post(
                Uri.parse('${Env.baseUrl}/edit_user.php'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'id': user['id'],
                  'username': usernameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole,
                }),
              );
              final data = jsonDecode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? 'Update failed')),
              );
              fetchUsers();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(int id) async {
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
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/delete_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Delete failed')),
      );
      fetchUsers();
    }
  }

  Future<void> editRole(Map role) async {
    final roleController = TextEditingController(text: role['role_name']);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Role'),
        content: TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await http.post(
                Uri.parse('${Env.baseUrl}/edit_role.php'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'id': role['id'], 'role_name': roleController.text.trim()}),
              );
              final data = jsonDecode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? 'Update failed')),
              );
              fetchRoles();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteRole(int id) async {
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

  void _showLowStockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Low Stock Alert'),
        content: _lowStockProducts.isEmpty
            ? const Text('No products are low in stock.')
            : SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('The following products have less than 10 in quantity:'),
                    const SizedBox(height: 12),
                    ..._lowStockProducts.map((p) => ListTile(
                          title: Text(p?['productName']?.toString() ?? 'Unknown'),
                          subtitle: Text('Quantity: ${p?['quantity']?.toString() ?? 'N/A'}'),
                        )),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    final messageController = TextEditingController();
    String? selectedRecipient;
    final List<String> recipients = ['All', 'Managers', 'Employees'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Notification'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedRecipient,
                hint: const Text('Select Recipient'),
                items: recipients.map((recipient) {
                  return DropdownMenuItem<String>(
                    value: recipient,
                    child: Text(recipient),
                  );
                }).toList(),
                onChanged: (value) {
                  setStateDialog(() {
                    selectedRecipient = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Recipient'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if ((selectedRecipient == null || selectedRecipient?.isEmpty == true) || messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a recipient and enter a message')),
                );
                return;
              }
              Navigator.pop(context);
              await _sendNotification(
                selectedRecipient ?? '',
                messageController.text.trim(),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification(String recipient, String message) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/send_notification.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipient': recipient,
        'message': message,
      }),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Notification sent')),
    );
  }

  void _showApprovalRequestsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) => AlertDialog(
          title: const Text('Account Approval Requests'),
          content: _pendingRequests.isEmpty
              ? const Text('No pending requests.')
              : SizedBox(
                  width: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _pendingRequests.map((req) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('${req['username']} (${req['role']})'),
                          subtitle: Text(req['email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                tooltip: 'Accept',
                                onPressed: () async {
                                  if (req['email'] != null && req['email'].toString().isNotEmpty) {
                                    await _handleRequest(int.parse(req['id'].toString()), true, req['email']);
                                    setStateDialog(() {
                                      _pendingRequests.removeWhere((r) => r['id'].toString() == req['id'].toString());
                                    });
                                    if (_pendingRequests.isEmpty) {
                                      Navigator.pop(dialogContext);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User email is missing. Cannot approve.')),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Reject',
                                onPressed: () async {
                                  if (req['email'] != null && req['email'].toString().isNotEmpty) {
                                    await _handleRequest(int.parse(req['id'].toString()), false, req['email']);
                                    setStateDialog(() {
                                      _pendingRequests.removeWhere((r) => r['id'].toString() == req['id'].toString());
                                    });
                                    if (_pendingRequests.isEmpty) {
                                      Navigator.pop(dialogContext);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User email is missing. Cannot reject.')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequest(int userId, bool approve, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/handle_request.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'approve': approve,
          'email': email,
        }),
      );
      print(response.body); // Debugging

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Action completed')),
        );
        // Only refresh users, not _pendingRequests here
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Action failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4F46E5),
        title: Text(
          'Welcome ${widget.username}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () => _showLowStockDialog(context),
                tooltip: 'Low Stock Alerts',
              ),
              if (_lowStockCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_lowStockCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            tooltip: 'Send Notification',
            onPressed: () => _showSendNotificationDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in, color: Colors.amber),
            tooltip: 'Request Approvals',
            onPressed: () => _showApprovalRequestsDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductListPage(isManager: true),
                      ),
                    );
                  },
                  child: const Text('View Products', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupplierListPage(isManager: true),
                      ),
                    );
                  },
                  child: const Text('View Suppliers', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const category_list.CategoryListPage(isManager: true),
                      ),
                    );
                  },
                  child: const Text('View Categories', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                    );
                  },
                  child: const Text('Manage Users', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageRolesPage()),
                    );
                  },
                  child: const Text('Manage Roles', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  },
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}