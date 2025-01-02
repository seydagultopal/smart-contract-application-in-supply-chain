import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'OrderDetailsScreen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('orders')
        .where('consumer.consumerId', isEqualTo: user.uid)
        .snapshots();
  }

  Map<String, List<QueryDocumentSnapshot>> _groupOrdersByOrderId(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> orders) {
    final Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};

    for (var order in orders) {
      final orderId = order['orderId'] ?? 'Unknown Order';
      if (!groupedOrders.containsKey(orderId)) {
        groupedOrders[orderId] = [];
      }
      groupedOrders[orderId]!.add(order);
    }

    return groupedOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB),
        title: const Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchUserOrders(),
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
                'No orders found!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final groupedOrders = _groupOrdersByOrderId(orders);

          return ListView.builder(
            itemCount: groupedOrders.keys.length,
            itemBuilder: (context, index) {
              final orderId = groupedOrders.keys.elementAt(index);
              final orderItems = groupedOrders[orderId]!;

              double totalPrice = 0;
              String status = '';
              for (var item in orderItems) {
                final data =
                    item.data() as Map<String, dynamic>; // Türü dönüştürme
                final price = data['price'] ?? 0.0;
                final quantity = data['quantity'] ?? 1;
                totalPrice += price * quantity;
                status = data['status'] ?? 'Unknown'; // Durumu al
              }

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.pink),
                  title: Text(
                    'Order ID: $orderId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Completed'
                          ? Colors.green
                          : (status == 'Pending' ? Colors.orange : Colors.blue),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(
                          orderId: orderId,
                          orderItems: orderItems,
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
