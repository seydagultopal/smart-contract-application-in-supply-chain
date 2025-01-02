import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'CarrierSelectionScreen.dart'; // Taşıyıcı seçimi için ekran

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedCarrierId;
  String? _selectedCarrierName;
  double? _selectedCarrierPrice;

  // Sepetteki ürünlerin toplam fiyatını hesaplar
  double _calculateTotalPrice(List<QueryDocumentSnapshot> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      final data = item.data() as Map<String, dynamic>;
      final price = double.tryParse(data['price'].toString()) ?? 0.0;
      final quantity = data['quantity'] ?? 1;
      total += price * quantity;
    }
    if (_selectedCarrierPrice != null) {
      total += _selectedCarrierPrice!;
    }
    return total;
  }

  Future<void> _selectCarrier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarrierSelectionScreen(
          onSelectCarrier: (carrier) {
            setState(() {
              _selectedCarrierId = carrier['carrierId'];
              _selectedCarrierName = carrier['carrierName'];
              _selectedCarrierPrice = carrier['fixedPrice'];
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCarrierId = result['carrierId'];
        _selectedCarrierPrice = result['fixedPrice'];
      });
    }
  }

  // Sepetteki ürün miktarını günceller
  Future<void> _updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity > 0) {
      await _firestore.collection('cart').doc(cartItemId).update({
        'quantity': newQuantity,
      });
    } else {
      await _firestore.collection('cart').doc(cartItemId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: const Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cart items'));
          }

          final cartItems = snapshot.data?.docs ?? [];

          if (cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final totalPrice = _calculateTotalPrice(cartItems);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item =
                        cartItems[index].data() as Map<String, dynamic>;
                    final cartItemId = cartItems[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.shopping_cart, color: Colors.red),
                        title: Text(
                          item['productName'] ?? 'Unknown Product',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ${item['price'] ?? 'N/A'}\n'
                              'Quantity: ${item['quantity'] ?? 1}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    final currentQuantity =
                                        item['quantity'] ?? 1;
                                    if (currentQuantity > 1) {
                                      _updateQuantity(
                                          cartItemId, currentQuantity - 1);
                                    }
                                  },
                                  icon: const Icon(Icons.remove,
                                      color: Colors.red),
                                ),
                                Text(
                                  '${item['quantity'] ?? 1}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final currentQuantity =
                                        item['quantity'] ?? 1;
                                    _updateQuantity(
                                        cartItemId, currentQuantity + 1);
                                  },
                                  icon: const Icon(Icons.add,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _firestore
                                .collection('cart')
                                .doc(cartItemId)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _selectCarrier,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        _selectedCarrierId == null
                            ? 'Select Carrier'
                            : 'Carrier: $_selectedCarrierName',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selectedCarrierId == null
                          ? null
                          : () async {
                              try {
                                final user = _auth.currentUser;
                                final userDoc = await _firestore
                                    .collection('users')
                                    .doc(user?.uid)
                                    .get();

                                final consumerName =
                                    userDoc.data()?['name'] ?? '';
                                final consumerEmail = user?.email ?? '';
                                final orderId =
                                    _firestore.collection('orders').doc().id;

                                final cartItems =
                                    await _firestore.collection('cart').get();
                                final ordersRef =
                                    _firestore.collection('orders');

                                for (var doc in cartItems.docs) {
                                  final productId = doc.data()['productId'];
                                  final productSnapshot = await _firestore
                                      .collection('products')
                                      .doc(productId)
                                      .get();

                                  final producerData = {
                                    'producerId':
                                        productSnapshot.data()?['producerId'],
                                    'producerEmail': productSnapshot
                                        .data()?['producerEmail'],
                                  };

                                  await ordersRef.add({
                                    'orderId': orderId,
                                    ...doc.data(),
                                    'producer': producerData,
                                    'consumer': {
                                      'consumerId': user?.uid,
                                      'consumerName': consumerName,
                                      'consumerEmail': consumerEmail,
                                    },
                                    'carrier': {
                                      'carrierId': _selectedCarrierId,
                                      'carrierName': _selectedCarrierName,
                                      'carrierPrice': _selectedCarrierPrice,
                                    },
                                    'status': 'Pending', // Status ekleniyor
                                    'orderDate': FieldValue.serverTimestamp(),
                                  });

                                  await doc.reference
                                      .delete(); // Sepetten kaldır
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order placed successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error placing order: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCarrierId == null
                            ? Colors.grey
                            : const Color(0xFFFFC0CB),
                      ),
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
