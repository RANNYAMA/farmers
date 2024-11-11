import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';
import 'customer_dashboard.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigate to login page or any other page you want after logout
      // Clear the navigation stack and replace it with the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  User? _user;
  String? userId;
  String userfullname = 'John Doe';
  String address = 'Maseru';

  // Using Email to fetch Data
  Future<void> fetchUserData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: _user!.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming that email is a unique field, you can access the first document
        DocumentSnapshot userDoc = snapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          userfullname = userData['names'] ?? 'John Doe';
          address = userData['location'] ?? 'Maseru';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    // Fetch user data from Firestore
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboardPage()),
        );
        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 15, right: 15, left: 15, bottom: 10),
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.settings,
                          size: 35,
                          color: Colors.white,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/user3.png',
                            height: 50,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userfullname,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              address,
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                // Wrap the ListView in an Expanded widget
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    _buildListTile(
                      icon: Icons.info,
                      title: "About",
                      onTap: () {
                        // Handle the About item click here
                        // You can navigate to a new page or perform an action
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                    _buildListTile(
                      icon: Icons.email,
                      title: "Contact Us",
                      onTap: () {
                        // Handle the Contact Us item click here
                        // You can navigate to a new page or perform an action
                        Navigator.pushNamed(context, '/contact');
                      },
                    ),
                    _buildListTile(
                      icon: Icons.wallet,
                      title: "Payments",
                      onTap: () {
                        // Handle the Payments item click here
                        // You can navigate to a new page or perform an action
                        Navigator.pushNamed(context, '/payments');
                      },
                    ),
                    _buildListTile(
                      icon: Icons.wallet_giftcard_outlined,
                      title: "My Rewards",
                      onTap: () {
                        // Handle the My Rewards item click here
                        // You can navigate to a new page or perform an action
                        Navigator.pushNamed(context, '/rewards');
                      },
                    ),
                    _buildListTile(
                      icon: Icons.wallet_giftcard_rounded,
                      title: "Promotions",
                      onTap: () {
                        // Handle the My Rewards item click here
                        // You can navigate to a new page or perform an action
                        Navigator.pushNamed(context, '/promotions');
                      },
                    ),
                    _buildListTile(
                      icon: Icons.feedback,
                      title: "Send Feedback",
                      onTap: () {
                        // Navigate to login
                        Navigator.pushNamed(context, '/feedback');
                      },
                    ),
                    _buildListTile(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () {
                        _signOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build a ListTile with GestureDetector
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Colors.pink,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 19),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
