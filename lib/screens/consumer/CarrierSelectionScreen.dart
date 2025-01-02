import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarrierSelectionScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onSelectCarrier;

  const CarrierSelectionScreen({Key? key, required this.onSelectCarrier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Carrier'),
        backgroundColor: const Color(0xFFFFC0CB), // Pink color
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Carrier') // Sadece taşıyıcıları getir
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading carriers'));
          }

          final carriers = snapshot.data?.docs ?? [];

          if (carriers.isEmpty) {
            return const Center(
              child: Text(
                'No carriers available!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: carriers.length,
            itemBuilder: (context, index) {
              final carrier = carriers[index];
              final carrierData = carrier.data();

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.local_shipping, color: Colors.blue),
                  title: Text(
                    carrierData['name'] ?? 'Unknown Carrier',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('Price: \$${carrierData['fixedPrice'] ?? 'N/A'}'),
                  onTap: () {
                    onSelectCarrier({
                      'carrierId': carrier.id,
                      'carrierName': carrierData['name'],
                      'fixedPrice': carrierData['fixedPrice'],
                    });
                    Navigator.pop(context);
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
