import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  const DeliveryHistoryScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchDeliveryHistory() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('orders')
        .where('carrier.carrierId', isEqualTo: userId)
        .where('status',
            isEqualTo: 'Completed') // Sadece "Completed" durumundakileri getir
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: const Text('Delivery History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchDeliveryHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading delivery history'));
          }

          final deliveries = snapshot.data?.docs ?? [];

          if (deliveries.isEmpty) {
            return const Center(
              child: Text(
                'No completed deliveries found!',
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
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    delivery['productName'] ?? 'Unknown Product',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Consumer: ${delivery['consumer']['consumerName'] ?? 'N/A'}',
                  ),
                  trailing: Text(
                    'Status: ${delivery['status'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
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
