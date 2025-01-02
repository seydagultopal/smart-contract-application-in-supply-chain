import 'package:flutter/material.dart';

import '../shared/CustomDrawer.dart'; // Drawer ekranını dahil ettik
import 'AddProductScreen.dart';
import 'MyOrdersScreen.dart';
import 'MyProductsScreen.dart';
import 'PendingOrdersScreen.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({Key? key}) : super(key: key);

  @override
  _ProducerDashboardScreenState createState() =>
      _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  int _selectedIndex = 0;

  // Ekran listesi
  static final List<Widget> _screens = [
    const MyProductsScreen(), // Ürün Listeleme
    AddProductScreen(), // Yeni Ürün Ekle
    const MyOrdersScreen(), // Sipariş geçmişi
    const PendingOrdersScreen(), // Bekleyen Siparişler
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üretici Paneli'),
        backgroundColor: const Color(0xFFFFC0CB),
      ),
      drawer: const CustomDrawer(), // Drawer entegre edildi
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink, // Aktif sekme rengi
        unselectedItemColor: Colors.grey, // Pasif sekme rengi
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Ürünler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ürün Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Sipariş Geçmişi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Bekleyen Siparişler',
          ),
        ],
      ),
    );
  }
}
