import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarrierSelectionScreen extends StatelessWidget {
  final String productId; // Ürün ID'si

  CarrierSelectionScreen({required this.productId});

  Future<void> _assignCarrier(String carrierId, double price) async {
    await FirebaseFirestore.instance.collection('deliveries').add({
      'productId': productId,
      'carrierId': carrierId,
      'carrierPrice': price,
      'status': 'Pending',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Carrier'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc('Carrier')
            .collection('details')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading carriers'));
          }

          final carriers = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: carriers.length,
            itemBuilder: (context, index) {
              final carrier = carriers[index];
              final carrierData = carrier.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(carrierData['name'] ?? 'Unknown Carrier'),
                  subtitle: Text(
                      'Fixed Price: \$${carrierData['fixedPrice'] ?? 'N/A'}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _assignCarrier(
                          carrier.id, carrierData['fixedPrice']);
                      Navigator.pop(context);
                    },
                    child: const Text('Select'),
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
