import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({Key? key}) : super(key: key);

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Map<String, dynamic>> products = []; // Ürünleri tutacak liste
  bool isLoading = true; // Veri yükleniyor mu kontrolü

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Firestore'dan ürünleri çek
  }

  Future<void> _fetchProducts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw 'Kullanıcı giriş yapmamış.';
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('producerId',
              isEqualTo:
                  user.uid) // Sadece giriş yapan üreticinin ürünlerini getir
          .get();

      setState(() {
        products = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['productName'] ?? 'Unknown Product',
            'price': data['price']?.toString() ?? 'N/A',
            'date': data['manufactureDate'] != null
                ? (data['manufactureDate'] as Timestamp).toDate().toString()
                : 'N/A',
          };
        }).toList();
        isLoading = false; // Yükleme tamamlandı
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ürünler alınamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      setState(() {
        products.removeWhere((product) => product['id'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün başarıyla silindi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ürün silinemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: const Text('My Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Yükleniyor göstergesi
              )
            : products.isEmpty
                ? const Center(
                    child: Text(
                      'No products added yet!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_cart,
                              color: Colors.red),
                          title: Text(
                            product['name'] ?? 'Unknown Product',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Price: ${product['price']}\nDate: ${product['date']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteProduct(product['id']);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
