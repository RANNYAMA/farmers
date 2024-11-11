import 'package:farmersmarketplace/screens/farmerDashboard/add_product.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/famer_orders.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/farmer_specials.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/profile.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/settings.dart';
import 'package:flutter/material.dart';

import 'farmer_products.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  List<Widget> pages = [
    // const HomePage(),
    const FarmerOrders(),
    const CustomerBookings(),
    const FarmerSpecials(),
    const UserProfileScreen(),
    // const SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // iconSize: 35,
        // backgroundColor: Color.fromARGB(255, 212, 135, 179),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Orders',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Products',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.addchart_rounded),
            label: 'Promotions',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings),
          //   label: 'Settings',
          //   backgroundColor: Colors.blue,
          // ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
