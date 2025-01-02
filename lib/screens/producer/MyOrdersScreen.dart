import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchApprovedOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Approved') // Sadece onaylanan siparişler
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: const Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchApprovedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No approved orders found!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data();

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    'Order ID: ${order['orderId'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Consumer: ${order['consumer']['consumerName'] ?? 'N/A'}\n'
                    'Total Price: \$${order['price'] ?? '0.0'}\n'
                    'Status: ${order['status'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
