import 'package:farmersmarketplace/screens/customerDashboard/customer_dashboard.dart';
import 'package:farmersmarketplace/screens/customerDashboard/farmer_products.dart';
import 'package:farmersmarketplace/screens/customerDashboard/product_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Farmers extends StatefulWidget {
  const Farmers({super.key});

  @override
  State<Farmers> createState() => _FarmersState();
}

class _FarmersState extends State<Farmers> {
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

  Future<void> _showRateDialog(String farmerId) async {
    double _ratingValue = 3.0; // Initialize default rating value

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Farmer'),
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
                    _submitRating(farmerId, _ratingValue);
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

  Future<void> _submitRating(String farmerId, double value) async {
    if (userId != null) {
      try {
        // Check if the user has already rated this farmer
        QuerySnapshot existingRatings = await _firestore
            .collection('farmersReviews')
            .where('userId', isEqualTo: userId)
            .where('farmerId', isEqualTo: farmerId)
            .get();

        if (existingRatings.docs.isNotEmpty) {
          // User has already rated this farmer, show a message
          Fluttertoast.showToast(
            msg: "You have already rated this farmer.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black54,
            textColor: Colors.orange,
          );
        } else {
          // Proceed to submit the rating
          Map<String, dynamic> ratingData = {
            'userId': userId,
            'farmerId': farmerId,
            'name': namesController.text,
            'value': value,
          };

          // Save the new rating to Firestore
          await FirebaseFirestore.instance
              .collection('farmersReviews')
              .add(ratingData);

          Fluttertoast.showToast(
            msg: "Rating submitted successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black54,
            textColor: Colors.blue,
          );
        }
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

  Future<double> _getFarmerAverageRating(String farmerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('farmersReviews')
          .where('farmerId', isEqualTo: farmerId)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0; // No ratings available, return 0
      }

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        var ratingData = doc.data() as Map<String, dynamic>;
        totalRating += ratingData['value']; // Add each rating value
      }
      return totalRating / snapshot.docs.length; // Calculate the average
    } catch (e) {
      print('Error fetching ratings: $e');
      return 0.0;
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
          title: const Text("Explore Farmers"),
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
                        labelText: 'Search Farmer',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('userType', isEqualTo: 'Farmer')
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
                            'No Farmers available at the moment')); // Handle no data
                  } else {
                    // final List<DocumentSnapshot> bookingDocs = snapshot
                    //     .data!.docs
                    //     .where((doc) => doc['farmName']
                    //         .toString()
                    //         .toLowerCase()
                    //         .contains(product.toLowerCase()))
                    //     .toList();
                    // Filter the list based on the search query for farmName
                    final List<DocumentSnapshot> bookingDocs =
                        snapshot.data!.docs.where((doc) {
                      final bookingData = doc.data() as Map<String, dynamic>;
                      final farmName =
                          bookingData['farmName']?.toString().toLowerCase() ??
                              '';
                      return farmName.contains(product.toLowerCase());
                    }).toList();

                    if (bookingDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No farmer available.',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                    return ListView.builder(
                        itemCount: bookingDocs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentSnapshot booking = bookingDocs[index];
                          final Map<String, dynamic> bookingData = booking
                              .data() as Map<String, dynamic>; // Convert to Map
                          final farmerId = booking.id;

                          return FutureBuilder<double>(
                            future: _getFarmerAverageRating(farmerId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error loading rating');
                              }

                              double averageRating = snapshot.data ?? 0.0;

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                          height:
                                              10), // Space between image and description

                                      Text(
                                        'Farm Name: ${bookingData['farmName'] ?? 'Unknown'}',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Farm Type: ${bookingData['farmType']}',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Phone: ${bookingData['phone']}',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Average Rating: ${averageRating.toStringAsFixed(1)} / 5',
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.orange),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              _showRateDialog(farmerId);
                                            },
                                            child: const Text(
                                              'Rate',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FarmerProducts(
                                                    farmerId:
                                                        bookingData['userId'],
                                                        farmName: bookingData['farmName'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'View Products',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              FlutterPhoneDirectCaller
                                                  .callNumber(
                                                      bookingData['phone']);
                                            },
                                            child: const Text('Call Farmer',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 17)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        });
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
