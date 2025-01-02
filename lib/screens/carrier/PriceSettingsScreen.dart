import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PriceSettingsScreen extends StatefulWidget {
  const PriceSettingsScreen({Key? key}) : super(key: key);

  @override
  _PriceSettingsScreenState createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  final TextEditingController _priceController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _savePrice() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        // `users` koleksiyonunun içindeki `carriers` alt koleksiyonunda fiyat güncelle
        await _firestore.collection('users').doc(user.uid).set({
          'fixedPrice': double.parse(_priceController.text),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Price updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update price: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCurrentPrice() async {
    final user = _auth.currentUser;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final price = doc.data()?['fixedPrice'] ?? 0.0;
        _priceController.text = price.toString();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB),
        title: const Text('Price Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fixed Delivery Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePrice,
              child: const Text('Save Price'),
            ),
          ],
        ),
      ),
    );
  }
}
