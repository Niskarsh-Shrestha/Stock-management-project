import 'package:flutter/material.dart';
import 'main.dart';
import 'product_list.dart';
import 'employee_product_list_page.dart';
import 'employee_supplier_list_page.dart';
import 'employee_category_list_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env.dart';

class EmployeeHomePage extends StatelessWidget {
  final String username;
  final String email;
  final String role;

  const EmployeeHomePage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  Future<List<dynamic>> _fetchNotifications() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_notifications.php?role=Employees'),
    );
    final data = jsonDecode(response.body);
    return data['notifications'] ?? [];
  }

  Future<List<Map<String, dynamic>>> _fetchLowStockProducts() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_product.php'),
    );
    final data = jsonDecode(response.body);
    if (data['products'] is List) {
      final products = List<Map<String, dynamic>>.from(data['products']);
      return products.where((p) {
        final qty = int.tryParse(p['quantity'].toString()) ?? 0;
        return qty < 10;
      }).toList();
    }
    return [];
  }

  void _showNotificationsDialog(BuildContext context) async {
    final notifications = await _fetchNotifications();
    final lowStockProducts = await _fetchLowStockProducts();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (notifications.isNotEmpty)
                ...notifications.map<Widget>((n) {
                  final msg = n?['message']?.toString() ?? '';
                  final date = n?['created_at']?.toString() ?? '';
                  return ListTile(
                    leading: const Icon(Icons.announcement, color: Colors.blue),
                    title: Text(msg.isNotEmpty ? msg : 'No message'),
                    subtitle: Text(date.isNotEmpty ? date : ''),
                  );
                }),
              if (lowStockProducts.isNotEmpty) ...[
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text('Low Stock Alerts'),
                ),
                ...lowStockProducts.map((p) => ListTile(
                      title: Text(p['productName']?.toString() ?? 'Unknown'),
                      subtitle: Text('Quantity: ${p['quantity']?.toString() ?? 'N/A'}'),
                    )),
              ],
              if (notifications.isEmpty && lowStockProducts.isEmpty)
                const Text('No notifications.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${username}'),
            Text('Email: ${email}'),
            Text('Role: ${role}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4F46E5),
        title: Text(
          'Welcome ${username}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _showNotificationsDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                      builder: (_) => const EmployeeProductListPage(),
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
                      builder: (_) => const EmployeeSupplierListPage(),
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
                      builder: (_) => const EmployeeCategoryListPage(),
                    ),
                  );
                },
                child: const Text('View Categories', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
