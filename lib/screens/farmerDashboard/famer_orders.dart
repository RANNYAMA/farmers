import 'package:farmersmarketplace/screens/farmerDashboard/farmer_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';

// import 'edit_order.dart';

class FarmerOrders extends StatefulWidget {
  const FarmerOrders({super.key});

  @override
  State<FarmerOrders> createState() => _FarmerOrdersState();
}

class _FarmerOrdersState extends State<FarmerOrders> {
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
  // Future<void> deleteBooking(String bookingId) async {
  //   try {
  //     await _firestore.collection('orders').doc(bookingId).delete();
  //     print('Product deleted successfully');
  //   } catch (e) {
  //     print('Error deleting booking: $e');
  //   }
  // }

  // Future<void> approveOrder(String bookingId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('orders')
  //         .doc(bookingId)
  //         .update({
  //       'orderStatus': 'Approved',
  //     });
  //     Fluttertoast.showToast(
  //       msg: "Order approved successfully",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       backgroundColor: Colors.black54,
  //       textColor: Colors.blue,
  //     );
  //   } catch (e) {
  //     print('Error deleting booking: $e');
  //   }
  // }

  Future<void> approveOrder(String bookingId, String productId, int orderedQuantity) async {
  try {
    // Get the product document
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();

    if (productSnapshot.exists) {
      int currentQuantity = int.parse(productSnapshot['quantity']);
     

      // Check if the product has enough quantity to fulfill the order
      if (currentQuantity >= orderedQuantity) {
        // Reduce the product quantity
        await _firestore.collection('products').doc(productId).update({
          'quantity': (currentQuantity - orderedQuantity).toString(),
        });

        // Approve the order
        await _firestore.collection('orders').doc(bookingId).update({
          'orderStatus': 'Approved',
        });

        Fluttertoast.showToast(
          msg: "Order approved successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.blue,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Not enough product quantity to approve the order",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Product not found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  } catch (e) {
    print('Error approving order: $e');
    Fluttertoast.showToast(
      msg: "Error approving order",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
    );
  }
}


  Future<void> rejectOrder(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(bookingId)
          .update({
        'orderStatus': 'Rejected',
      });
      Fluttertoast.showToast(
        msg: "Order rejected successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.blue,
      );
      print('Product deleted successfully');
    } catch (e) {
      print('Error deleting booking: $e');
    }
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
          title: const Text("My Orders"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/growing.avif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
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
                        .where('farmerId', isEqualTo: _user?.uid)
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
                          'No Orders found for this user.',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        )); // Handle no data
                      } else {
                        // final List<DocumentSnapshot> bookingDocs = snapshot.data!.docs;
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
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: bookingDocs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final DocumentSnapshot booking = bookingDocs[index];
                            final Map<String, dynamic> bookingData =
                                booking.data()
                                    as Map<String, dynamic>; // Convert to Map
                            final bookingId = booking.id;
                            // Get the document ID

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
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Quantity: ${bookingData['quantity']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Status: ${bookingData['orderStatus']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            FlutterPhoneDirectCaller.callNumber(
                                                bookingData['phone']);
                                          },
                                          child: const Text(
                                            'Call Buyer',
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 17),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                              
                                            approveOrder(bookingId, bookingData['productId'],  int.parse(bookingData['quantity']));
                                          },
                                          child: const Text(
                                            'Approve',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 17),
                                          ),
                                        ),
                                        if (bookingData['orderStatus'] !=
                                            'Approved')
                                          TextButton(
                                            onPressed: () {
                                              rejectOrder(bookingId);
                                            },
                                            child: const Text(
                                              'Reject',
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
          ],
        ),
      ),
    );
  }
}
