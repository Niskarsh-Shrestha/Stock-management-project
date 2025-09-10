import 'package:flutter/material.dart';
import 'main.dart';
import 'product_list.dart';
import 'category_list.dart';
import 'supplier_list.dart';
import 'dart:convert';
import 'http_client.dart' as http_client;
import 'package:http/http.dart' as http;
import 'env.dart';

class ManagerHomePage extends StatefulWidget {
  final String username;
  final String email;
  final String role;

  const ManagerHomePage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  int _lowStockCount = 0;
  List<Map<String, dynamic>> _lowStockProducts = [];
  List<dynamic> notifications = [];

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = http_client.createHttpClient();
    _fetchLowStockProducts();
    _fetchNotifications();
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

  Future<void> _fetchNotifications() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_notifications.php?role=Managers'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      notifications = data['notifications'] ?? [];
    });
  }

  void _showNotificationsDialog(BuildContext context) {
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
              if (_lowStockProducts.isNotEmpty) ...[
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text('Low Stock Alerts'),
                ),
                ..._lowStockProducts.map((p) => ListTile(
                      title: Text(p['productName']?.toString() ?? 'Unknown'),
                      subtitle: Text('Quantity: ${p['quantity']?.toString() ?? 'N/A'}'),
                    )),
              ],
              if (notifications.isEmpty && _lowStockProducts.isEmpty)
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
            Text('Username: ${widget.username}'),
            Text('Email: ${widget.email}'),
            Text('Role: ${widget.role}'),
          ],
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

  Future<void> _deleteProduct(String productId) async {
    final response = await _client.post(
      Uri.parse('${Env.baseUrl}/delete_product.php'),
      body: {'id': productId},
    );
    // Handle response...
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
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _showNotificationsDialog(context),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showProfileDialog(context),
          )
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
                      builder: (_) => const CategoryListPage(isManager: true),
                    ),
                  );
                },
                child: const Text('Manage Categories', style: TextStyle(color: Colors.white)),
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
