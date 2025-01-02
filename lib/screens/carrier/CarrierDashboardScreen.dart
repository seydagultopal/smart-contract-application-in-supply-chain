import 'package:flutter/material.dart';

import '../shared/CustomDrawer.dart'; // Drawer ekranı eklendi
import 'DeliveryHistoryScreen.dart';
import 'PendingDeliveriesScreen.dart';
import 'PriceSettingsScreen.dart'; // Yeni ekran eklendi

class CarrierDashboardScreen extends StatefulWidget {
  const CarrierDashboardScreen({Key? key}) : super(key: key);

  @override
  _CarrierDashboardScreenState createState() => _CarrierDashboardScreenState();
}

class _CarrierDashboardScreenState extends State<CarrierDashboardScreen> {
  int _selectedIndex = 0;

  // Taşıyıcının kullanacağı ekranların listesi
  final List<Widget> _screens = [
    const PendingDeliveriesScreen(),
    const DeliveryHistoryScreen(),
    const PriceSettingsScreen(), // Yeni ekran
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
        title: const Text('Carrier Dashboard'),
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
            icon: Icon(Icons.pending_actions),
            label: 'Pending Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Delivery History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.price_change),
            label: 'Price Settings',
          ),
        ],
      ),
    );
  }
}
