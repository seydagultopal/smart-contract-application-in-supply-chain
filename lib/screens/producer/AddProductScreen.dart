import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originCountryController = TextEditingController();
  final _chemicalInfoController = TextEditingController();
  final _certificationsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _originCountryController.dispose();
    _chemicalInfoController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        // Şu anki kullanıcı bilgilerini al
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          throw 'Kullanıcı giriş yapmamış.';
        }

        // Firestore'a ürün bilgilerini kaydet
        await FirebaseFirestore.instance.collection('products').add({
          'productName': _productNameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'manufactureDate': _selectedDate,
          'description': _descriptionController.text.trim(),
          'originCountry': _originCountryController.text.trim(),
          'chemicalInfo': _chemicalInfoController.text.trim(),
          'certifications': _certificationsController.text.trim(),
          'producerId': user.uid, // Üretici ID'si
          'producerEmail': user.email, // Üretici email'i
          'createdAt': FieldValue.serverTimestamp(), // Oluşturulma tarihi
        });

        // Başarılı mesaj
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );

        // Formu temizle
        _formKey.currentState!.reset();
        setState(() {
          _selectedDate = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürün eklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(
                controller: _productNameController,
                label: 'Product Name *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: _priceController,
                label: 'Price (in terms of price per kilogram) *',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Manufacture Date (DD/MM/YYYY) *',
                    errorText: _selectedDate == null
                        ? 'Please select a manufacture date'
                        : null,
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'Select a date',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              buildTextField(
                controller: _descriptionController,
                label: 'Description *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: _originCountryController,
                label: 'Origin Country *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the origin country';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: _chemicalInfoController,
                label: 'Chemical Info (vitamins, fertilizers, pesticides)',
              ),
              buildTextField(
                controller: _certificationsController,
                label: 'Certifications',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
