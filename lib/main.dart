import 'package:farmersmarketplace/screens/auth/login.dart';
import 'package:farmersmarketplace/screens/auth/register.dart';
import 'package:farmersmarketplace/screens/auth/reset_password.dart';
import 'package:farmersmarketplace/screens/customerDashboard/contact.dart';
import 'package:farmersmarketplace/screens/customerDashboard/customer_dashboard.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/add_product.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/add_special.dart';
import 'package:farmersmarketplace/screens/farmerDashboard/farmer_dashboard.dart';
import 'package:farmersmarketplace/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
         scaffoldBackgroundColor: Colors.grey[200], 
          primarySwatch: Colors.blue,
          // fontFamily: 'Georgia',
          fontFamily: 'Georgia'),
      // theme: TAppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/register': (context) => const RegisterPage(),
        '/loginpage': (context) => const LoginScreen(),
        '/resetPassword': (context) => const ResetPasswordScreen(),
        '/farmersDashboard': (context) => const DashboardPage(),
        '/customerDashboard': (context) => const CustomerDashboardPage(),
        '/addProduct' : (context) => const BookingScreen(),
        '/addSpecial' : (context) => const AddSpecialScreen(),
        '/help' : (context) => const ContactPage(),
      },
    );
  }
}
