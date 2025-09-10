import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';

class ProductListPage extends StatefulWidget {
  final bool isManager;
  const ProductListPage({Key? key, this.isManager = false}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> _products = [];
  List<String> _categories = [];
  List<String> _suppliers = [];

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _warehouseController = TextEditingController();

  String? _availability;
  String? _selectedCategory;
  String? _selectedSupplier;

  bool _isLoading = true;

  String _sortBy = 'productName';
  bool _sortDescending = false;

  bool _isEditMode = false;
  dynamic _editingProduct;

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
    _fetchAllData();
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

  Future<void> _addOrEditProduct() async {
    final name = _productNameController.text.trim();
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final warehouse = _warehouseController.text.trim();

    if (name.isEmpty || qty <= 0 || warehouse.isEmpty || _availability == null || _selectedCategory == null || _selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    final url = Uri.parse('${Env.baseUrl}/${_isEditMode ? 'edit_product.php' : 'add_product.php'}');
    final body = {
      'productName': name,
      'quantity': qty.toString(),
      'availability': _availability!,
      'category': _selectedCategory!,
      'warehouseLocation': warehouse,
      'supplierName': _selectedSupplier!,
      'modifiedBy': 'manager',
    };

    if (_isEditMode) {
      body['id'] = _editingProduct['id'].toString();  // <-- Use 'id' here!
    }

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        Navigator.pop(context);
        await _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditMode ? 'Product updated' : 'Product added')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${decoded['error'] ?? 'Unknown error'}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit product')));
    }
  }

  Future<void> _deleteProduct(dynamic product) async {
    final productId = product['id']?.toString();  // <-- Use 'id' here!
    if (productId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure to delete "${product['productName']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      final response = await _client.post(
        Uri.parse('${Env.baseUrl}/delete_product.php'),
        body: {'id': productId},
      );
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        await _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
      }
    }
  }

  void _showAddProductDialog({dynamic product}) {
    _isEditMode = product != null;
    _editingProduct = product;

    if (_isEditMode) {
      _productNameController.text = product['productName'] ?? '';
      _quantityController.text = product['quantity'].toString();
      _warehouseController.text = product['warehouseLocation'] ?? '';
      _availability = product['availability'];
      _selectedCategory = product['category'];
      _selectedSupplier = product['supplierName'];
    } else {
      _productNameController.clear();
      _quantityController.clear();
      _warehouseController.clear();
      _availability = null;
      _selectedCategory = null;
      _selectedSupplier = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _productNameController, decoration: const InputDecoration(labelText: 'Product Name')),
              TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
              TextField(controller: _warehouseController, decoration: const InputDecoration(labelText: 'Warehouse Location')),
              DropdownButtonFormField<String>(
                value: _availability,
                hint: const Text('-- Availability --'),
                items: ['Yes', 'No'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _availability = val),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('-- Category --'),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              DropdownButtonFormField<String>(
                value: _selectedSupplier,
                hint: const Text('-- Supplier --'),
                items: _suppliers.map((sup) => DropdownMenuItem(value: sup, child: Text(sup))).toList(),
                onChanged: (val) => setState(() => _selectedSupplier = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addOrEditProduct, child: Text(_isEditMode ? 'Update' : 'Add')),
        ],
      ),
    );
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
          Expanded(flex: 1, child: Text('Actions')),
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
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddProductDialog(product: product)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(product)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List'), backgroundColor: const Color(0xFF4F46E5)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.isManager)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddProductDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        _buildSortControls(),
                      ],
                    ),
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
