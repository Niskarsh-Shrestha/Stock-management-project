import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';
import 'auth_headers.dart';

class EmployeeCategoryListPage extends StatefulWidget {
  const EmployeeCategoryListPage({Key? key}) : super(key: key);

  @override
  State<EmployeeCategoryListPage> createState() => _EmployeeCategoryListPageState();
}

class _EmployeeCategoryListPageState extends State<EmployeeCategoryListPage> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  String _sortBy = 'CategoryName';
  bool _sortDescending = false;

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/some_file.php'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['categories'] is List) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(decoded['categories']);
            _sortCategoriesLocally();
            _isLoading = false;
          });
        } else {
          setState(() {
            _categories = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _categories = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _categories = [];
        _isLoading = false;
      });
    }
  }

  void _sortCategoriesLocally() {
    _categories.sort((a, b) {
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
              _sortCategoriesLocally();
            });
          },
          items: const [
            DropdownMenuItem(value: 'CategoryName', child: Text('Category Name')),
            DropdownMenuItem(value: 'dateAdded', child: Text('Date Added')),
          ],
        ),
        IconButton(
          icon: Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.blue),
          onPressed: () {
            setState(() {
              _sortDescending = !_sortDescending;
              _sortCategoriesLocally();
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
          Expanded(flex: 2, child: Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Date Added', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(category['CategoryName'] ?? '')),
          Expanded(flex: 2, child: Text(category['dateAdded'] ?? '')),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String productId) async {
    try {
      final response = await _client.post(
        Uri.parse('${Env.baseUrl}/delete_product.php'),
        headers: AuthHeaders.value,
        body: {'id': productId},
      );
      if (response.statusCode == 200) {
        _fetchCategories(); // Refresh the list after deletion
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category List'), backgroundColor: const Color(0xFF4F46E5)),
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
                  child: _categories.isEmpty
                      ? const Center(child: Text('No categories found'))
                      : ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (_, i) => _buildCategoryRow(_categories[i]),
                        ),
                ),
              ],
            ),
    );
  }
}