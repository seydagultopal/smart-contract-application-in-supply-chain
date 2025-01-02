import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'ProductDetailsScreen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Firestore'dan ürünleri getiren fonksiyon
  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  // Ürün miktarlarını tutacak map
  Map<String, int> quantities = {};

  void _updateQuantity(String productId, int quantity) {
    setState(() {
      quantities[productId] = quantity;
    });
  }

  void _increaseQuantity(String productId) {
    setState(() {
      quantities[productId] = (quantities[productId] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(String productId) {
    setState(() {
      if (quantities[productId] != null && quantities[productId]! > 0) {
        quantities[productId] = quantities[productId]! - 1;
      }
    });
  }

  Future<void> addToCart(
      Map<String, dynamic> productData, String productId) async {
    final int quantity = quantities[productId] ?? 0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('cart').add({
        'productName': productData['productName'],
        'price': productData['price'],
        'quantity': quantity,
        'productId': productId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pink color
        title: const Text('Product List'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products available!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productData = product.data();
              final productId = product.id;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.red),
                  title: Text(
                    productData['productName'] ?? 'Unknown Product',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${productData['price'] ?? 'N/A'}\n'
                        'Manufacture Date: ${productData['manufactureDate'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _decreaseQuantity(productId),
                            icon: const Icon(Icons.remove, color: Colors.red),
                          ),
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              initialValue:
                                  '${quantities[productId] ?? 0}', // Default quantity
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                final parsedValue = int.tryParse(value);
                                if (parsedValue != null) {
                                  _updateQuantity(productId, parsedValue);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () => _increaseQuantity(productId),
                            icon: const Icon(Icons.add, color: Colors.green),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => addToCart(productData, productId),
                            icon: const Icon(Icons.add_shopping_cart,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Product Details Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          productId: productId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
