import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PendingDeliveriesScreen extends StatefulWidget {
  const PendingDeliveriesScreen({Key? key}) : super(key: key);

  @override
  _PendingDeliveriesScreenState createState() =>
      _PendingDeliveriesScreenState();
}

class _PendingDeliveriesScreenState extends State<PendingDeliveriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchPendingDeliveries() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection('orders')
        .where('carrier.carrierId', isEqualTo: userId)
        .where('status',
            isEqualTo: 'Approved') // Sadece "Approved" durumundakileri getir
        .snapshots();
  }

  Future<void> _markAsCompleted(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'Completed', // Durumu "Completed" olarak güncelle
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update delivery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB),
        title: const Text('Pending Deliveries'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchPendingDeliveries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading deliveries'));
          }

          final deliveries = snapshot.data?.docs ?? [];

          if (deliveries.isEmpty) {
            return const Center(
              child: Text(
                'No pending deliveries!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final delivery = deliveries[index].data();

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.local_shipping, color: Colors.pink),
                  title: Text(
                    'Order ID: ${delivery['orderId'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Consumer: ${delivery['consumer']['consumerName'] ?? 'N/A'}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _markAsCompleted(deliveries[index].id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Complete'),
                  ),
                  onTap: () {
                    // Sipariş detay ekranına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryDetailsScreen(
                          orderId: delivery['orderId'] ?? 'Unknown',
                          orderItems: [
                            deliveries[index]
                          ], // Seçili teslimatı gönderiyoruz
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

class DeliveryDetailsScreen extends StatelessWidget {
  final String orderId;
  final List<DocumentSnapshot> orderItems;

  const DeliveryDetailsScreen({
    Key? key,
    required this.orderId,
    required this.orderItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB),
        title: Text('Details for Order: $orderId'),
      ),
      body: ListView(
        children: orderItems.map((order) {
          final data = order.data() as Map<String, dynamic>;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(data['productName'] ?? 'Unknown Product'),
              subtitle: Text(
                'Quantity: ${data['quantity']}\n'
                'Consumer: ${data['consumer']['consumerName']}',
              ),
              trailing: Text(
                'Price: \$${data['price']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
