import 'package:farmersmarketplace/screens/customerDashboard/customer_dashboard.dart';
import 'package:farmersmarketplace/screens/customerDashboard/edit_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:toggle_switch/toggle_switch.dart';

// import 'edit_order.dart';

class CustomerOrders extends StatefulWidget {
  const CustomerOrders({super.key});

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final List<String> status = ['All', 'PENDING', 'Approved', 'Rejected'];
  int selectedStatus = 0;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // Function to delete a booking document from Firestore
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('orders').doc(bookingId).delete();
      print('Order deleted successfully');
    } catch (e) {
      print('Error deleting Order: $e');
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
          content: const Text('Are you sure you want to delete this order?'),
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
            MaterialPageRoute(
                builder: (context) => const CustomerDashboardPage()),
          );
          // Prevent the default back button behavior
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("My Orders"),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToggleSwitch(
                      minWidth: 160.0,
                      initialLabelIndex: selectedStatus,
                      cornerRadius: 10.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 4,
                      labels: status,
                      activeBgColors: [
                        [Colors.green],
                        [Colors.blue],
                        [Colors.green],
                        [Colors.red],
                      ],
                      onToggle: (index) {
                        setState(() {
                          selectedStatus = index!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('orders')
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
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text(
                              'No Orders found for this user.')); // Handle no data
                    } else {
                      // final List<DocumentSnapshot> bookingDocs = snapshot.data!.docs
                      final List<DocumentSnapshot> bookingDocs =
                          snapshot.data!.docs.where((doc) {
                        final orderstatus =
                            doc.data().toString().contains('orderStatus')
                                ? doc['orderStatus'].toString().toLowerCase()
                                : '';

                        // Apply filter based on the selected category and product name
                        return (selectedStatus == 0 ||
                            orderstatus ==
                                status[selectedStatus].toLowerCase());
                      }).toList();

                      if (bookingDocs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No orders available ',
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
                          final bookingId = booking.id; // Get the document ID
                          final status = {bookingData['orderStatus']};

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
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
                                    height: 10,
                                  ),
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
                                        'M${bookingData['price']}.00',
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
                                  Text(
                                    'Quantity: ${bookingData['quantity']}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    'Status: ${bookingData['orderStatus']}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (bookingData['orderStatus'] !=
                                          'Approved')
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditOrder(
                                                  docId: booking.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Edit Order',
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      TextButton(
                                        onPressed: () {
                                          FlutterPhoneDirectCaller.callNumber(
                                              bookingData['farmerPhone']);
                                        },
                                        child: const Text(
                                          'Call Farmer',
                                          style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 17),
                                        ),
                                      ),
                                      // TextButton(
                                      //   onPressed: () {
                                      //     _showDeleteConfirmationDialog(bookingId);
                                      //   },
                                      //   child: const Text(
                                      //     'Cancel',
                                      //     style: TextStyle(
                                      //         color: Colors.red, fontSize: 17),
                                      //   ),
                                      // ),
                                      if (bookingData['orderStatus'] !=
                                          'Approved')
                                        TextButton(
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                                bookingId);
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 17),
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
              ),
            ],
          ),
        ));
  }
}
