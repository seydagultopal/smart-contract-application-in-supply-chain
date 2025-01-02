import 'package:flutter/material.dart';

import '../shared/CustomDrawer.dart'; // Drawer ekranını dahil ettik
import 'CartScreen.dart'; // Sepet ekranını dahil ettik
import 'OrderHistoryScreen.dart';
import 'ProductListScreen.dart';

class ConsumerDashboardScreen extends StatefulWidget {
  const ConsumerDashboardScreen({Key? key}) : super(key: key);

  @override
  _ConsumerDashboardScreenState createState() =>
      _ConsumerDashboardScreenState();
}

class _ConsumerDashboardScreenState extends State<ConsumerDashboardScreen> {
  int _selectedIndex = 0;

  // Tüketici için kullanılacak ekranlar listesi
  final List<Widget> _screens = [
    const ProductListScreen(),
    const OrderHistoryScreen(),
    const CartScreen(), // Sepet ekranını ekledik
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
        backgroundColor: const Color(0xFFFFC0CB), // Pembe renk
        title: const Text('Consumer Dashboard'),
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
            label: 'Product List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Order History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart', // Sepet sekmesi
          ),
        ],
      ),
    );
  }
}
