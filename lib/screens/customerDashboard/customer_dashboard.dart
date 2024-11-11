import 'package:farmersmarketplace/screens/customerDashboard/orders.dart';
import 'package:farmersmarketplace/screens/customerDashboard/products.dart';
import 'package:farmersmarketplace/screens/customerDashboard/profile.dart';
import 'package:farmersmarketplace/screens/customerDashboard/promotions.dart';
import 'package:farmersmarketplace/screens/customerDashboard/farmers.dart';
import 'package:flutter/material.dart';


class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  int _selectedIndex = 0;

  List<Widget> pages = [
    // const HomePage(),
    const Products(),
    const PromotionProducts(),
    const CustomerOrders(),
    const Farmers(),
     const UserProfileScreen(),
 
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
            icon: Icon(Icons.list),
            label: 'Products',
            backgroundColor: Colors.blue,
          ),
                    BottomNavigationBarItem(
            icon: Icon(Icons.addchart_rounded),
            label: 'Promos',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_sharp),
            label: 'My Orders',
            backgroundColor: Colors.blue,
          ),
                    BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_sharp),
            label: 'Farmers',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
