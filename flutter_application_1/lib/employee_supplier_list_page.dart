import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';
import 'auth_headers.dart';

class EmployeeSupplierListPage extends StatefulWidget {
  const EmployeeSupplierListPage({Key? key}) : super(key: key);

  @override
  State<EmployeeSupplierListPage> createState() => _EmployeeSupplierListPageState();
}

class _EmployeeSupplierListPageState extends State<EmployeeSupplierListPage> {
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = true;

  String _sortBy = 'supplierName';
  bool _sortDescending = false;

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/get_suppliers.php'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['suppliers'] is List) {
          setState(() {
            _suppliers = List<Map<String, dynamic>>.from(decoded['suppliers']);
            _sortSuppliersLocally();
            _isLoading = false;
          });
        } else {
          setState(() {
            _suppliers = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _suppliers = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _suppliers = [];
        _isLoading = false;
      });
    }
  }

  void _sortSuppliersLocally() {
    _suppliers.sort((a, b) {
      final aVal = a[_sortBy]?.toString().toLowerCase() ?? '';
      final bVal = b[_sortBy]?.toString().toLowerCase() ?? '';
      return _sortDescending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
    });
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
              _sortSuppliersLocally();
            });
          },
          items: const [
            DropdownMenuItem(value: 'supplierName', child: Text('Supplier Name')),
            DropdownMenuItem(value: 'contact', child: Text('Contact')),
            DropdownMenuItem(value: 'email', child: Text('Email')),
            DropdownMenuItem(value: 'category', child: Text('Category')),
          ],
        ),
        IconButton(
          icon: Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.blue),
          onPressed: () {
            setState(() {
              _sortDescending = !_sortDescending;
              _sortSuppliersLocally();
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
          Expanded(flex: 2, child: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Last Order', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSupplierRow(Map<String, dynamic> supplier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(supplier['supplierName'] ?? '')),
          Expanded(flex: 2, child: Text(supplier['category'] ?? supplier['categoryName'] ?? '')),
          Expanded(flex: 2, child: Text(supplier['contact'] ?? '')),
          Expanded(flex: 2, child: Text(supplier['email'] ?? '')),
          Expanded(flex: 2, child: Text(supplier['lastOrderDate'] ?? '')),
        ],
      ),
    );
  }

  Future<void> _deleteSupplier(String productId) async {
    try {
      final response = await _client.post(
        Uri.parse('${Env.baseUrl}/delete_product.php'),
        headers: AuthHeaders.value,
        body: {'id': productId},
      );
      if (response.statusCode == 200) {
        // Handle successful deletion, e.g., by refetching the supplier list
        _fetchSuppliers();
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
    }
  }

  Future<void> addSuppliers(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/add_suppliers.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> editSuppliers(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/edit_suppliers.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> deleteSuppliers(int id) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/delete_suppliers.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supplier List'), backgroundColor: const Color(0xFF4F46E5)),
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
                  child: _suppliers.isEmpty
                      ? const Center(child: Text('No suppliers found'))
                      : ListView.builder(
                          itemCount: _suppliers.length,
                          itemBuilder: (_, i) => _buildSupplierRow(_suppliers[i]),
                        ),
                ),
              ],
            ), 
    );
  }
  }