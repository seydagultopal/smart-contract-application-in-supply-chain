import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final String orderId; // Seçilen siparişin ID'si

  const DeliveryDetailsScreen({Key? key, required this.orderId})
      : super(key: key);

  // Firebase'den sipariş detaylarını getiren fonksiyon
  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchOrderDetails() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('orders')
        .where('orderId', isEqualTo: orderId)
        .where('carrier.carrierId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: Text('Details for Order: $orderId'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading delivery details'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No delivery details found'));
          }

          final orders = snapshot.data!.docs;
          double totalPrice = 0;
          final producerEmails = <String>{};

          return ListView(
            children: [
              ...orders.map((orderDoc) {
                final order = orderDoc.data();

                final productName = order['productName'] ?? 'Unknown Product';
                final quantity = order['quantity'] ?? 1;
                final price = order['price'] ?? 0.0;
                final producerEmail =
                    order['producer']['producerEmail'] ?? 'Unknown Email';
                totalPrice += price * quantity;
                producerEmails.add(producerEmail);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(productName),
                    subtitle: Text(
                      'Quantity: $quantity\nPrice: \$${price.toStringAsFixed(2)}\nConsumer: ${order['consumer']['consumerName'] ?? 'N/A'}\nProducer Email: $producerEmail',
                    ),
                  ),
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producers: ${producerEmails.join(', ')}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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
