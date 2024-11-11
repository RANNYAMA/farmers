import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AddOrderScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String price;
  final String quantity;
  final String farmerId;
  final String location;
  final String productImage;
  final String farmerPhone;
  final String delivery;

  const AddOrderScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.farmerId,
    required this.quantity,
    required this.farmerPhone,
    required this.location,
    required this.delivery,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userId;

  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController userquantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  TextEditingController deliveryAddressController = TextEditingController();

  String? userquantityErrorText;
  String? deliveryErrorText;

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

    // Initialize controllers with product data passed from the Products page
    productNameController.text = widget.productName;
    priceController.text = widget.price;
    quantityController.text = widget.quantity;
    locationController.text = widget.location;
    deliveryController.text = widget.delivery;
  }

  // Proceed with adding an order
  Future<void> _addOrder() async {
    String quantity = userquantityController.text;
    String deliveryAddress = deliveryAddressController.text;
    // Ensure user is authenticated
    if (quantity.isEmpty) {
      setState(() {
        userquantityErrorText = 'Quantity is required';
      });
    } else if (quantity.length == 0) {
      setState(() {
        userquantityErrorText = "Quantity can not be less than 0";
      });
    } else {
      setState(() {
        userquantityErrorText = null;
      });
    }

    if (deliveryAddress.isEmpty) {
      setState(() {
        deliveryErrorText = 'Delivery address is required';
      });
    } else {
      setState(() {
        deliveryErrorText = null;
      });
    }
    if (userId != null && userquantityErrorText == null) {
      try {
        int userQuantityInt = int.parse(userquantityController.text);
        int availableQuantityInt = int.parse(quantityController.text);

        if (userQuantityInt <= availableQuantityInt) {
          Map<String, dynamic> orderData = {
            'userId': userId,
            'productId': widget.productId,
            'farmerId': widget.farmerId,
            'farmerPhone': widget.farmerPhone,
            'phone': phoneController.text,
            'productName': productNameController.text,
            'price': priceController.text,
            'quantity': userquantityController.text,
            'location': locationController.text,
            'deliveryAddress': deliveryAddress,
            'productImage': widget.productImage,
            'orderStatus': 'PENDING',
            'timestamp': FieldValue.serverTimestamp(),
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

          /// Go back to previous screen
          Navigator.pop(context);
        } else {
          // Show a message if the requested quantity exceeds the available stock
          Fluttertoast.showToast(
            msg: "Requested quantity exceeds available stock",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
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
        title: const Text("Add Order"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
              readOnly:
                  true, // Make it read-only since it comes from product data
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
              readOnly:
                  true, // Make it read-only since it comes from product data
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Product Quantity Available',
              ),
              readOnly:
                  true, // Make it read-only since it comes from product data
            ),
            const SizedBox(height: 16.0),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Product Location',
              ),
              readOnly: true,
              // User can modify the location if needed
            ),
                        const SizedBox(height: 16.0),

            TextField(
              controller: deliveryController,
              decoration: const InputDecoration(
                labelText: 'Delivery Available',
              ),
              readOnly: true,
              // User can modify the location if needed
            ),
            const SizedBox(height: 24.0),
            TextField(
              controller: userquantityController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    userquantityErrorText = 'Quantity is required';
                  });
                } else {
                  setState(() {
                    userquantityErrorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter your  quantity',
                errorText: userquantityErrorText,
              ),
            ),

            if (deliveryController.text == 'Yes') ...[
              const SizedBox(height: 24.0),
              TextField(
                controller: deliveryAddressController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      deliveryErrorText = 'Delivery is required';
                    });
                  } else {
                    setState(() {
                      deliveryErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter your  address',
                  errorText: deliveryErrorText,
                ),
              ),
            ],
            // const SizedBox(height: 24.0),
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
          ],
        ),
      ),
    );
  }
}
