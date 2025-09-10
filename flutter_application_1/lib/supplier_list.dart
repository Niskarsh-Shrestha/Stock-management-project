import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';

class SupplierListPage extends StatefulWidget {
  final bool isManager;
  const SupplierListPage({Key? key, required this.isManager}) : super(key: key);

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  String sortBy = 'supplierName'; // or 'dateAdded'
  bool sortDescending = false;

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
  }

  Future<void> fetchSuppliersAndCategories() async {
    setState(() => isLoading = true);
    await Future.wait([fetchCategories(), fetchSuppliers()]);
    setState(() => isLoading = false);
  }

  Future<void> fetchSuppliers() async {
    final response = await http.get(Uri.parse('${Env.baseUrl}/get_suppliers.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        suppliers = List<Map<String, dynamic>>.from(data['suppliers'] ?? []);
        _sortSuppliersLocally();
      });
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('${Env.baseUrl}/get_categories.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categories = List<Map<String, dynamic>>.from(data['categories'] ?? []);
      });
    }
  }

  void _sortSuppliersLocally() {
    suppliers.sort((a, b) {
      final aVal = a[sortBy]?.toString().toLowerCase() ?? '';
      final bVal = b[sortBy]?.toString().toLowerCase() ?? '';
      return sortDescending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
    });
  }

  Future<void> deleteSupplier(String supplierId) async {
    final url = Uri.parse('${Env.baseUrl}/delete_suppliers.php');
    final response = await _client.post(url, body: {'SupplierID': supplierId});
    if (!mounted) return;

    if (response.statusCode == 200) {
      await fetchSuppliers();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete supplier')));
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? supplier}) {
    final nameController = TextEditingController(text: supplier?['supplierName'] ?? '');
    final contactController = TextEditingController(text: supplier?['contact'] ?? '');
    final emailController = TextEditingController(text: supplier?['email'] ?? '');
    DateTime? selectedDate;
    if (supplier != null && supplier['lastOrderDate'] != null && supplier['lastOrderDate'].toString().isNotEmpty) {
      try {
        selectedDate = DateTime.parse(supplier['lastOrderDate']);
      } catch (_) {
        selectedDate = null;
      }
    }
    String selectedCategory = supplier?['categoryID']?.toString() ?? (categories.isNotEmpty ? categories[0]['CategoryID'].toString() : '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> _pickDate() async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setDialogState(() {
                selectedDate = picked;
              });
            }
          }

          return AlertDialog(
            title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Supplier Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory.isNotEmpty ? selectedCategory : null,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map((cat) => DropdownMenuItem<String>(
                              value: cat['CategoryID'].toString(),
                              child: Text(cat['CategoryName'] ?? ''),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedCategory = val ?? '';
                      });
                    },
                  ),
                  TextField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: 'Contact'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? 'Last Order Date: ${selectedDate!.toLocal().toIso8601String().split('T').first}'
                              : 'Select Last Order Date',
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Pick Date'),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || selectedCategory.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Supplier Name and Category are required')),
                    );
                    return;
                  }
                  final isEdit = supplier != null;
                  final url = Uri.parse('${Env.baseUrl}/${isEdit ? 'edit_suppliers.php' : 'add_suppliers.php'}');
                  final body = {
                    if (isEdit) 'SupplierID': supplier!['supplierID'].toString(),
                    'supplierName': nameController.text.trim(),
                    'categoryID': selectedCategory,
                    'contact': contactController.text.trim(),
                    'email': emailController.text.trim(),
                    'lastOrderDate': selectedDate != null ? selectedDate!.toIso8601String().split('T').first : '',
                  };
                  final response = await http.post(url, body: body);
                  if (!mounted) return;
                  Navigator.pop(context);
                  await fetchSuppliers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Supplier updated' : 'Supplier added')),
                  );
                },
                child: Text(supplier == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
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
              _sortSuppliersLocally();
            });
          },
          items: const [
            DropdownMenuItem(value: 'supplierName', child: Text('Supplier Name')),
            DropdownMenuItem(value: 'dateAdded', child: Text('Date Added')),
          ],
        ),
        IconButton(
          icon: Icon(sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
          onPressed: () {
            setState(() {
              sortDescending = !sortDescending;
              _sortSuppliersLocally();
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
          Expanded(child: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Last Order Date', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Date Added', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSupplierRow(Map<String, dynamic> supplier) {
    final category = categories.firstWhere(
      (c) => c['CategoryID'].toString() == supplier['categoryID'].toString(),
      orElse: () => {'CategoryName': 'Unknown'},
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(supplier['supplierID']?.toString() ?? '')),
          Expanded(child: Text(supplier['supplierName'] ?? '')),
          Expanded(child: Text(category['CategoryName'] ?? 'Unknown')),
          Expanded(child: Text(supplier['contact'] ?? '')),
          Expanded(child: Text(supplier['email'] ?? '')),
          Expanded(child: Text(supplier['lastOrderDate'] ?? '')),
          Expanded(child: Text(supplier['dateAdded'] ?? '')),
          Expanded(
            child: widget.isManager
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEditDialog(supplier: supplier),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteSupplier(supplier['supplierID'].toString()),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text('Supplier Management'),
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
                          label: const Text('Add Supplier'),
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
                  child: suppliers.isEmpty
                      ? const Center(child: Text('No suppliers found'))
                      : ListView.builder(
                          itemCount: suppliers.length,
                          itemBuilder: (_, index) => _buildSupplierRow(suppliers[index]),
                        ),
                ),
              ],
            ),
    );
  }
}
