import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';
import 'auth_headers.dart';

class EmployeeProductListPage extends StatefulWidget {
  const EmployeeProductListPage({Key? key}) : super(key: key);

  @override
  State<EmployeeProductListPage> createState() => _EmployeeProductListPageState();
}

class _EmployeeProductListPageState extends State<EmployeeProductListPage> {
  List<dynamic> _products = [];
  List<String> _categories = [];
  List<String> _suppliers = [];

  bool _isLoading = true;

  String _sortBy = 'productName';
  bool _sortDescending = false;

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchProducts(), _fetchCategories(), _fetchSuppliers()]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/get_product.php'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['products'] is List) {
          setState(() {
            _products = decoded['products'];
            _sortProductsLocally();
          });
        }
      }
    } catch (_) {
      setState(() => _products = []);
    }
  }

  void _sortProductsLocally() {
    _products.sort((a, b) {
      final aVal = a[_sortBy] ?? '';
      final bVal = b[_sortBy] ?? '';
      if (_sortBy == 'quantity') {
        final aNum = int.tryParse(aVal.toString()) ?? 0;
        final bNum = int.tryParse(bVal.toString()) ?? 0;
        return _sortDescending ? bNum.compareTo(aNum) : aNum.compareTo(bNum);
      }
      return _sortDescending
          ? bVal.toString().toLowerCase().compareTo(aVal.toString().toLowerCase())
          : aVal.toString().toLowerCase().compareTo(bVal.toString().toLowerCase());
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/get_categories.php'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['categories'] is List) {
          setState(() {
            _categories = List<String>.from(decoded['categories'].map((c) => c['CategoryName'].toString()));
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchSuppliers() async {
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/get_suppliers.php'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['suppliers'] is List) {
          setState(() {
            _suppliers = List<String>.from(decoded['suppliers'].map((s) => s['supplierName'].toString()));
          });
        }
      }
    } catch (_) {}
  }

  Widget _buildSortControls() {
    return Row(
      children: [
        const Text("Sort by:", style: TextStyle(color: Colors.blue)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _sortBy,
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _sortBy = val;
              _sortProductsLocally();
            });
          },
          items: const [
            DropdownMenuItem(value: 'productName', child: Text('Product Name')),
            DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
            DropdownMenuItem(value: 'category', child: Text('Category')),
            DropdownMenuItem(value: 'supplierName', child: Text('Supplier')),
          ],
        ),
        IconButton(
          icon: Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.blue),
          onPressed: () {
            setState(() {
              _sortDescending = !_sortDescending;
              _sortProductsLocally();
            });
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Qty')),
          Expanded(flex: 2, child: Text('Category')),
          Expanded(flex: 2, child: Text('Supplier')),
          Expanded(flex: 2, child: Text('Warehouse')),
          Expanded(flex: 1, child: Text('Available')),
        ],
      ),
    );
  }

  Widget _buildProductRow(dynamic product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(product['productName'] ?? '')),
          Expanded(flex: 1, child: Text(product['quantity'].toString())),
          Expanded(flex: 2, child: Text(product['category'] ?? '')),
          Expanded(flex: 2, child: Text(product['supplierName'] ?? '')),
          Expanded(flex: 2, child: Text(product['warehouseLocation'] ?? '')),
          Expanded(
            flex: 1,
            child: Text(
              product['availability'] ?? '',
              style: TextStyle(
                color: (product['availability'] ?? '').toLowerCase() == 'yes' ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      final response = await _client.post(
        Uri.parse('${Env.baseUrl}/delete_product.php'),
        headers: AuthHeaders.value,
        body: {'id': productId},
      );
      if (response.statusCode == 200) {
        // Product deleted successfully, refetch the product list
        _fetchProducts();
      }
    } catch (e) {
      // Handle error
      print('Error deleting product: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/add_product.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> editProduct(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/edit_product.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> deleteProduct(int id) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/delete_product.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List'), backgroundColor: const Color(0xFF4F46E5)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildSortControls(),
                ),
                _buildTableHeader(),
                Expanded(
                  child: _products.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (_, i) => _buildProductRow(_products[i]),
                        ),
                ),
              ],
            ),
    );
  }
}