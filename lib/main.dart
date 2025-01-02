import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/auth/LoginScreen.dart';
import 'screens/auth/RegisterScreen.dart';
import 'screens/producer/AddProductScreen.dart';
import 'screens/producer/MyOrdersScreen.dart';
import 'screens/producer/MyProductsScreen.dart';
import 'screens/producer/ProducerDashboardScreen.dart'; // Producer Dashboard import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlatıyoruz
  runApp(const TedarikZinciriApp());
}

class TedarikZinciriApp extends StatelessWidget {
  const TedarikZinciriApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tedarik Zinciri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // İlk açıldığında LoginScreen gösterilecek
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) =>
            const RegisterScreen(), // RegisterScreen rotası eklendi
        '/producer': (context) =>
            const ProducerDashboardScreen(), // ProducerDashboard rotası eklendi
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Ekran listesi
  static final List<Widget> _screens = <Widget>[
    Container(
      color: const Color(0xFFFFF5F5), // Lighter pink background
      child: const MyProductsScreen(),
    ),
    Container(
      color: const Color(0xFFFFF5F5), // Lighter pink background
      child: AddProductScreen(),
    ),
    Container(
      color: const Color(0xFFFAF0F0), // Light pink background
      child: const MyOrdersScreen(),
    ),
  ];

  // Butona tıklanınca ekran değişimi
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'My Contracts',
          ),
        ],
      ),
    );
  }
}
