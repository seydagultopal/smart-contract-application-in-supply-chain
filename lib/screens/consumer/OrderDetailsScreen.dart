import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final List<QueryDocumentSnapshot> orderItems;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
    required this.orderItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in orderItems) {
      final data = item.data() as Map<String, dynamic>;
      final price = data['price'] ?? 0.0;
      final quantity = data['quantity'] ?? 1;
      totalPrice += price * quantity;
    }

    // İlk ürün üzerinden kargo bilgisi alınıyor
    final carrier = (orderItems.isNotEmpty &&
            (orderItems.first.data() as Map<String, dynamic>?)?['carrier'] !=
                null)
        ? (orderItems.first.data() as Map<String, dynamic>)['carrier']
            as Map<String, dynamic>?
        : null;

    final carrierName = carrier?['carrierName'] ?? 'Unknown Carrier';
    final carrierPrice = carrier?['carrierPrice'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB),
        title: Text('Order Details - $orderId'),
      ),
      body: ListView(
        children: [
          ...orderItems.map((item) {
            final data = item.data() as Map<String, dynamic>;
            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(data['productName'] ?? 'Unknown Product'),
                subtitle: Text(
                  'Price: \$${data['price'].toStringAsFixed(2)}\nQuantity: ${data['quantity']}',
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
                  'Carrier: $carrierName',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Carrier Fee: \$${carrierPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
