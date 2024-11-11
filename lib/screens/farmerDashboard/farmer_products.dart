import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_order.dart';
import 'farmer_dashboard.dart';

class CustomerBookings extends StatefulWidget {
  const CustomerBookings({super.key});

  @override
  State<CustomerBookings> createState() => _CustomerBookingsState();
}

class _CustomerBookingsState extends State<CustomerBookings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // Function to delete a booking document from Firestore
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('products').doc(bookingId).delete();
      print('Product deleted successfully');
    } catch (e) {
      print('Error deleting booking: $e');
    }
  }

  // Show an alert dialog to confirm deletion
  Future<void> _showDeleteConfirmationDialog(String bookingId) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the deleteBooking function when the "Delete" button is pressed
                deleteBooking(bookingId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Products"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pngtree-chicken.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('products')
                  .where('userId', isEqualTo: _user?.uid)
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
                          'No Products found for this user.', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),)); // Handle no data
                } else {
                  final List<DocumentSnapshot> bookingDocs =
                      snapshot.data!.docs;
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
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                                                                   if (bookingData['productImage'] != null)
                                Container(
                                  height: 150,
                                  width: double.infinity, // Full width
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    image: DecorationImage(
                                      image: NetworkImage(bookingData[
                                          'productImage']), // Load from URL
                                      fit: BoxFit
                                          .cover, // Make image cover the container
                                    ),
                                  ),
                                ),
                                         const SizedBox(
                                      height: 5,
                                    ),
                                             Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                  
                                      Text(
                                        '${bookingData['productName']}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                     
                                               Text(
                                        'M${bookingData['price']}.00 / ${bookingData['pricingUnit']}',
                                        style: const TextStyle(fontSize: 18,  fontWeight: FontWeight.w600),
                                      ),
                                
                                        ],
                                     ),
                                      const SizedBox(height: 10),
                              Text(
                                'Location: ${bookingData['location']}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'Quantity: ${bookingData['quantity']}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditBooking(
                                            docId: booking.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Edit Product',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(bookingId);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 17),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/addProduct');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
