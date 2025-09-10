import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'category_products_page.dart';
import 'env.dart';
import 'auth_headers.dart';

http.Client createHttpClient() {
  if (kIsWeb) {
    // ignore: avoid_web_libraries_in_flutter
    final c = BrowserClient()..withCredentials = true;
    return c;
  }
  return http.Client();
}

class CategoryListPage extends StatefulWidget {
  final bool isManager;
  const CategoryListPage({Key? key, required this.isManager}) : super(key: key);

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late final http.Client _client;
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  String sortBy = 'CategoryName'; // or 'dateAdded'
  bool sortDescending = false;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _client.get(Uri.parse('${Env.baseUrl}/get_categories.php'));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> fetchedCategories = data['categories'] ?? [];
        setState(() {
          categories = List<Map<String, dynamic>>.from(fetchedCategories);
          _sortCategoriesLocally();
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: HTTP ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  void _sortCategoriesLocally() {
    categories.sort((a, b) {
      final aVal = a[sortBy]?.toString().toLowerCase() ?? '';
      final bVal = b[sortBy]?.toString().toLowerCase() ?? '';
      return sortDescending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    final url = Uri.parse('${Env.baseUrl}/delete_category.php');
    try {
      final response = await http.post(url, body: {'CategoryID': categoryId});
      if (!mounted) return;

      if (response.statusCode == 200) {
        await fetchCategories();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete category')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting category: $e')));
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? category}) {
    final nameController = TextEditingController(text: category?['CategoryName'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category Name cannot be empty')),
                );
                return;
              }

              final isEdit = category != null;
              final url = Uri.parse('${Env.baseUrl}/${isEdit ? 'edit_category.php' : 'add_category.php'}');

              try {
                final response = await http.post(
                  url,
                  headers: AuthHeaders.value,
                  body: {
                    if (isEdit) 'CategoryID': category!['CategoryID'].toString(),
                    'categoryName': name,
                  },
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (response.statusCode == 200) {
                  await fetchCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Category updated' : 'Category added')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to ${isEdit ? 'update' : 'add'} category')),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortControls() {
    return Row(
      children: [
        const Text("Sort by: "),
        DropdownButton<String>(
          value: sortBy,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              sortBy = value;
              _sortCategoriesLocally();
            });
          },
          items: const [
            DropdownMenuItem(value: 'CategoryName', child: Text('Category Name')),
            DropdownMenuItem(value: 'dateAdded', child: Text('Date Added')),
          ],
        ),
        IconButton(
          icon: Icon(sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
          onPressed: () {
            setState(() {
              sortDescending = !sortDescending;
              _sortCategoriesLocally();
            });
          },
        )
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Date Added', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(category['CategoryID'].toString())),
          Expanded(child: Text(category['CategoryName'] ?? 'Unknown')),
          Expanded(child: Text(category['dateAdded'] ?? 'N/A')),
          Expanded(
            child: widget.isManager
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEditDialog(category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteCategory(category['CategoryID'].toString()),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsPage(
                      categoryId: category['CategoryName'], // Pass the name!
                      categoryName: category['CategoryName'] ?? 'Unknown',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('View Products', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addCategory(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/add_category.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> editCategory(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/edit_category.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  Future<void> deleteCategoryById(int id) async {
    final resp = await _client.post(
      Uri.parse('${Env.baseUrl}/delete_category.php'), // change entity as needed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    final data = jsonDecode(resp.body);
    // Handle response...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.isManager)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Category'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        _buildSortControls(),
                      ],
                    ),
                  ),
                _buildTableHeader(),
                Expanded(
                  child: categories.isEmpty
                      ? const Center(child: Text('No categories found'))
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (_, index) => _buildCategoryRow(categories[index]),
                        ),
                ),
              ],
            ),
    );
  }
}
