import 'package:farmersmarketplace/screens/customerDashboard/PromotionProductDetails.dart';
import 'package:farmersmarketplace/screens/customerDashboard/customer_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'add_Order.dart';

class PromotionProducts extends StatefulWidget {
  const PromotionProducts({super.key});

  @override
  State<PromotionProducts> createState() => _PromotionProductsState();
}

class _PromotionProductsState extends State<PromotionProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String product = '';
  final List<String> categories = ['All', 'Vegetables', 'Meat', 'Eggs'];
  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const CustomerDashboardPage()),
        );
        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Explore Hot Deals"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 46,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          product = value; // Update the serial number state
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search Product',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ToggleSwitch(
                    minWidth: 160.0,
                    initialLabelIndex: selectedCategory,
                    cornerRadius: 10.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 4,
                    labels: categories,
                    activeBgColors: [
                      [Colors.green],
                      [Colors.blue],
                      [Colors.red],
                      [Colors.orange],
                    ],
                    onToggle: (index) {
                      setState(() {
                        selectedCategory =
                            index!; // Update selectedUser when toggled
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('specials')
                    // .where('userId', isEqualTo: _user?.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Handle loading state
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error: ${snapshot.error}')); // Handle error state
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                            'No  Products on promotions available at the moment')); // Handle no data
                  } else {
                    // final List<DocumentSnapshot> bookingDocs = snapshot
                    //     .data!.docs
                    //     .where((doc) => doc['productName']
                    //         .toString()
                    //         .toLowerCase()
                    //         .contains(product.toLowerCase()))
                    //     .toList();
                    final List<DocumentSnapshot> bookingDocs =
                        snapshot.data!.docs.where((doc) {
                      final productName =
                          doc['productName'].toString().toLowerCase();
                      // final productCategory = doc['category'].toString().toLowerCase();

                      final productCategory =
                          doc.data().toString().contains('category')
                              ? doc['category'].toString().toLowerCase()
                              : '';

                      // Apply filter based on the selected category and product name
                      return productName.contains(product.toLowerCase()) &&
                          (selectedCategory ==
                                  0 || // Show all products if "All" is selected (index 0)
                              productCategory ==
                                  categories[selectedCategory].toLowerCase());
                    }).toList();

                    if (bookingDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No promotions available.',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: bookingDocs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot booking = bookingDocs[index];
                        final Map<String, dynamic> bookingData = booking.data()
                            as Map<String, dynamic>; // Convert to Map
                        // final bookingId = booking.id; // Get the document ID

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image Section
                                if (bookingData['productImage'] != null)
                                  Container(
                                    height: 150,
                                    width: double.infinity, // Full width
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            bookingData['productImage']),
                                        fit: BoxFit
                                            .cover, // Fit the image within the container
                                      ),
                                    ),
                                  ),

                                const SizedBox(
                                    height:
                                        10), // Space between image and description

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${bookingData['productName']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'M${bookingData['price']}.00 / ${bookingData['pricingUnit']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  'Location: ${bookingData['location']}',
                                  style: const TextStyle(fontSize: 15),
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${bookingData['quantity']}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Delivery: ${bookingData['delivery']}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddOrderScreen(
                                              productId: booking.id,
                                              productName:
                                                  bookingData['productName'],
                                              farmerId: bookingData['userId'],
                                              farmerPhone: bookingData['phone'],
                                              productImage:
                                                  bookingData['productImage'],
                                              price: bookingData['price'],
                                              quantity: bookingData['quantity'],
                                              location: bookingData['location'],
                                              delivery: bookingData['delivery'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Order',
                                          style: TextStyle(fontSize: 17)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PromotionsProductDetailsScreen(
                                              productId: booking.id,
                                              productName:
                                                  bookingData['productName'],
                                              farmerId: bookingData['userId'],
                                              farmerPhone: bookingData['phone'],
                                              productImage:
                                                  bookingData['productImage'],
                                              price: bookingData['price'],
                                              quantity: bookingData['quantity'],
                                              location: bookingData['location'],
                                              startDate:
                                                  bookingData['startDate'],
                                              endDate: bookingData['endDate'],
                                              description:
                                                  bookingData['description'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'View More',
                                        style: TextStyle(
                                            color: Colors.amberAccent,
                                            fontSize: 17),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FlutterPhoneDirectCaller.callNumber(
                                            bookingData['phone']);
                                      },
                                      child: const Text('Call Farmer',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 17)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
