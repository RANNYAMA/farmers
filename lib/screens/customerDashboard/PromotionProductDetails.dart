import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PromotionsProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String price;
  final String quantity;
  final String farmerId;
  final String location;
  final String productImage;
  final String farmerPhone;
  final String startDate;
  final String endDate;
  final String description;

  const PromotionsProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.farmerId,
    required this.quantity,
    required this.farmerPhone,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  @override
  State<PromotionsProductDetailsScreen> createState() =>
      _PromotionsProductDetailsScreenState();
}

class _PromotionsProductDetailsScreenState
    extends State<PromotionsProductDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userId;

  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController farmerphoneController = TextEditingController();
  TextEditingController farmNameController = TextEditingController();
  TextEditingController farmTypeController = TextEditingController();
  TextEditingController farmSizeController = TextEditingController();

  String? quantityErrorText;

  // Using Email to fetch Data
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
        // locationController.text = userData['location'] ?? '';
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Using Email to fetch Data
Future<void> fetctFarmerData() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.farmerId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = snapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        // Trigger a UI update by calling setState
        farmerphoneController.text = userData['phone'] ?? '';
        farmNameController.text = userData['farmName'] ?? '';
        farmTypeController.text = userData['farmType'] ?? '';
        farmSizeController.text = userData['farmSize'] ?? '';
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
    if (_user != null) {
      userId = _user!.uid;
      fetchUserData(); // Fetch user-specific data like phone, if needed
      fetctFarmerData();
    } else if (_user == null) {
      Navigator.pushNamed(context, '/loginpage');
    }

    // Initialize controllers with product data passed from the Products page
    productNameController.text = widget.productName;
    priceController.text = widget.price;
    // quantityController.text = widget.quantity;
    locationController.text = widget.location;
  }

  // Proceed with adding an order
  Future<void> _addOrder() async {
    String quantity = quantityController.text;
    // Ensure user is authenticated
    if (quantity.isEmpty) {
      setState(() {
        quantityErrorText = 'Quantity is required';
      });
    } else if (quantity.length == 0) {
      setState(() {
        quantityErrorText = "Quantity can not be less than 0";
      });
    } else {
      setState(() {
        quantityErrorText = null;
      });
    }
    if (userId != null && quantityErrorText == null) {
      try {
        Map<String, dynamic> orderData = {
          'userId': userId,
          'productId': widget.productId,
          'farmerId': widget.farmerId,
          'farmerPhone': widget.farmerPhone,
          'phone': phoneController.text,
          'productName': productNameController.text,
          'price': priceController.text,
          'quantity': quantityController.text,
          'location': locationController.text,
          'productImage': widget.productImage,
          'orderStatus': 'PENDING',
        };

        // Save order to Firestore
        await FirebaseFirestore.instance.collection('orders').add(orderData);

        Fluttertoast.showToast(
          msg: "Order placed successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.green,
        );

        Navigator.pop(context); // Go back to previous screen
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error placing order: $e",
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Container(
              height: 170,
              width: double.infinity, // Full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                image: DecorationImage(
                  image: NetworkImage(widget.productImage), // Load from URL
                  fit: BoxFit.cover, // Make image cover the container
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.productName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'M${widget.price}.00',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start On',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'End On',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.startDate}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
                Text(
                  '${widget.endDate}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Desciption',
              style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              '${widget.description}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
         
            const SizedBox(height: 16.0),
            Text(
              'Location',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              '${widget.location}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Farmer Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
      
                        const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Farm Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Text(
                  'Farm Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${farmNameController.text}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
                Text(
                  '${farmTypeController.text}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
        
            const SizedBox(
              height: 16,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Farm Size',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Text(
                  'Phone Numbers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${farmSizeController.text}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
                Text(
                  '${farmerphoneController.text}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
        
                           const SizedBox(height: 16.0),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    quantityErrorText = 'Quantity is required';
                  });
                } else {
                  setState(() {
                    quantityErrorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter your  quantity',
                errorText: quantityErrorText,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addOrder,
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  const Size(350, 40),
                ),
              ),
              child: const Text('Place Order', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 400,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('ratings')
                    .where('productId', isEqualTo: widget.productId)
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
                            'No  Product ratings available')); // Handle no data
                  } else {
                    final List<DocumentSnapshot> bookingDocs =
                        snapshot.data!.docs;

                    if (bookingDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No rating  available.',
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
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    height:
                                        10), // Space between image and description

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${bookingData['name']}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w200),
                                    ),
                                    // Text(
                                    //   '${bookingData['value']}',
                                    //   style: const TextStyle(
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.w200),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                PannableRatingBar(
                                  rate: double.tryParse(
                                          bookingData['value'].toString()) ??
                                      0.0,
                                  spacing: 5,
                                  maxRating: 5, // Maximum rating is 5
                                  onChanged: (rating) {},
                                  items: List.generate(
                                    5,
                                    (index) => const RatingWidget(
                                      selectedColor: Colors.yellow,
                                      unSelectedColor: Colors.grey,
                                      child: Icon(
                                        Icons.star,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),

                                // Text(
                                //   'Value: ${bookingData['value']}',
                                //   style: const TextStyle(fontSize: 14),
                                // ),
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
