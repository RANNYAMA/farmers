import 'package:farmersmarketplace/screens/customerDashboard/customer_dashboard.dart';
import 'package:farmersmarketplace/screens/customerDashboard/product_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'add_Order.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String product = '';
  String? userId;
  final List<String> categories = ['All', 'Vegetables', 'Meat', 'Eggs'];
  int selectedCategory = 0;
  TextEditingController namesController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  Future<void> fetchUserData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _user!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming that email is a unique field, you can access the first document
        DocumentSnapshot userDoc = snapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        phoneController.text = userData['phone'] ?? '';
        namesController.text = userData['names'] ?? '';
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      userId = _user!.uid;
      fetchUserData(); // Fetch user-specific data like phone, if needed
    } else if (_user == null) {
      Navigator.pushNamed(context, '/loginpage');
    }
  }

  Future<void> _showRateDialog(String productId) async {
    double _ratingValue = 3.0; // Initialize default rating value

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const Text('Please rate the product:'),
                  const SizedBox(height: 10),
                  PannableRatingBar(
                    rate: _ratingValue,
                    spacing: 5,
                    maxRating: 5, // Maximum rating is 5
                    onChanged: (rating) {
                      setState(() {
                        _ratingValue = rating; // Update the rating value
                      });
                    },
                    items: List.generate(
                      5,
                      (index) => const RatingWidget(
                        selectedColor: Colors.yellow,
                        unSelectedColor: Colors.grey,
                        child: Icon(
                          Icons.star,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Rating: ${_ratingValue.toStringAsFixed(1)} / 5'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _submitRating(productId, _ratingValue);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(String productId, double value) async {
    if (userId != null) {
      try {
        // Check if the user has already rated this product
        QuerySnapshot existingRating = await FirebaseFirestore.instance
            .collection('ratings')
            .where('userId', isEqualTo: userId)
            .where('productId', isEqualTo: productId)
            .get();

        if (existingRating.docs.isNotEmpty) {
          // If a rating already exists, show a message and don't allow another rating
          Fluttertoast.showToast(
            msg: "You have already rated this product.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black54,
            textColor: Colors.yellow,
          );
          return; // Stop the function here
        }

        // If no rating exists, proceed with submitting the new rating
        Map<String, dynamic> ratingData = {
          'userId': userId,
          'productId': productId,
          'name': namesController.text,
          'value': value,
        };

        // Save the rating to Firestore
        await FirebaseFirestore.instance.collection('ratings').add(ratingData);

        Fluttertoast.showToast(
          msg: "Rating submitted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.blue,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error submitting rating: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.red,
        );
      }
    }
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
          title: const Text("Explore"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.help),
              onPressed: () {
                Navigator.pushNamed(context, '/help');
              },
            ),
          ],
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
                    .collection('products')
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
                            'No Products available at the moment')); // Handle no data
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
                          'No product available.',
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
                        final bookingId = booking.id; // Get the document ID

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

                                // Product Description Section
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                ProductDetailsScreen(
                                              productId: booking.id,
                                              productName:
                                                  bookingData['productName'],
                                              farmerId: bookingData['userId'],
                                              farmerPhone: bookingData['phone'],
                                              productImage:
                                                  bookingData['productImage'],
                                              price: bookingData['price'],
                                                pricingUnit: bookingData['pricingUnit'],
                                              quantity: bookingData['quantity'],
                                              location: bookingData['location'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'View',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 17),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _showRateDialog(bookingId);
                                      },
                                      child: const Text(
                                        'Rate',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 17),
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

