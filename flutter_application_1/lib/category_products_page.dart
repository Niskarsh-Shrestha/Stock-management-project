import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';
import 'http_client.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_products_by_category.php?categoryId=${widget.categoryId}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        products = List<Map<String, dynamic>>.from(data['products'] ?? []);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load products')),
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    final response = await _client.post(
      Uri.parse('${Env.baseUrl}/delete_product.php'),
      body: {'id': productId},
    );

    if (response.statusCode == 200) {
      fetchCategoryProducts(); // Refresh the product list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products in ${widget.categoryName}'),
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products found in this category.'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final p = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(p['productName'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Qty: ${p['quantity'] ?? ''} | Availability: ${p['availability'] ?? ''}'),
                            Text('Warehouse: ${p['warehouseLocation'] ?? ''}'),
                            Text('Supplier: ${p['supplierName'] ?? ''}'),
                            Text('Added: ${p['dateAdded'] ?? ''} | Updated: ${p['lastUpdated'] ?? ''} by ${p['modifiedBy'] ?? ''}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
