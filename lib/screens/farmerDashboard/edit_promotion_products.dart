import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditPromotion extends StatefulWidget {
  final String docId;

  const EditPromotion({
    super.key,
    required this.docId,
  });

  @override
  State<EditPromotion> createState() => _EditPromotionState();
}

class _EditPromotionState extends State<EditPromotion> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userId;

  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController pricingUnitController = TextEditingController();

  String? quantityErrorText;
  String? priceErrorText;
  String? pricingUnitErrorText;
  String? productNameErrorText;
  String? categoryNameErrorText;
  String? locationErrorText;
  String? startDateErrorText;
  String? endDateErrorText;
  String? statusErrorText;
  bool isLoading = false;

  Map<String, dynamic>? productData;

  void fetchPropertyData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('specials')
          .doc(widget.docId) // Use the provided docId
          .get();
      setState(() {
        productData = snapshot.data() as Map<String, dynamic>;

        phoneController.text = productData?['phone'] ?? '';
        locationController.text = productData?['location'] ?? '';
        priceController.text = productData?['price'] ?? '';
        productNameController.text = productData?['productName'] ?? '';
        quantityController.text = productData?['quantity'] ?? '';
        categoryController.text = productData?['category'] ?? '';
        pricingUnitController.text = productData?['pricingUnit'] ?? '';
        startDateController.text = productData?['startDate'] ?? '';
        endDateController.text = productData?['endDate'] ?? '';
        statusController.text = productData?['status'] ?? '';
      });
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      userId = _user!.uid;
      // Fetch user data from Firestore
      fetchPropertyData();
    } else if (_user == null) {
      Navigator.pushNamed(context, '/loginpage');
    }
  }

  Future<void> _register() async {
    String productName = productNameController.text;
    String price = priceController.text;
    String phone = phoneController.text;
    String location = locationController.text;
    String quantity = quantityController.text;
    String category = categoryController.text;
    String startDate = startDateController.text;
    String endDate = endDateController.text;
    String status = statusController.text;
    String pricingUnit = pricingUnitController.text;

    // Validate email field
    if (productName.isEmpty) {
      setState(() {
        productNameErrorText = 'Product name is required';
      });
    } else {
      setState(() {
        productNameErrorText = null;
      });
    }
    if (pricingUnit.isEmpty) {
      setState(() {
        pricingUnitErrorText = 'Pricing unit is required';
      });
    } else {
      setState(() {
        pricingUnitErrorText = null;
      });
    }
    if (endDate.isEmpty) {
      setState(() {
        endDateErrorText = 'End date is required';
      });
    } else {
      setState(() {
        endDateErrorText = null;
      });
    }
    if (startDate.isEmpty) {
      setState(() {
        startDateErrorText = 'Start date is required';
      });
    } else {
      setState(() {
        startDateErrorText = null;
      });
    }
    if (status.isEmpty) {
      setState(() {
        statusErrorText = 'Status is required';
      });
    } else {
      setState(() {
        statusErrorText = null;
      });
    }
    if (category.isEmpty) {
      setState(() {
        categoryNameErrorText = 'Category is required';
      });
    } else {
      setState(() {
        categoryNameErrorText = null;
      });
    }
    if (location.isEmpty) {
      setState(() {
        locationErrorText = 'Location is required';
      });
    } else {
      setState(() {
        locationErrorText = null;
      });
    }

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

    if (price.isEmpty) {
      setState(() {
        priceErrorText = 'Price is required';
      });
    } else if (price.length == 0) {
      setState(() {
        priceErrorText = "Price can not be less than 0";
      });
    } else {
      setState(() {
        priceErrorText = null;
      });
    }

    // Proceed with registration if both fields are valid
    if (priceErrorText == null &&
        quantityErrorText == null &&
        categoryNameErrorText == null &&
        startDateErrorText == null &&
        pricingUnitErrorText == null &&
        endDateErrorText == null &&
        statusErrorText == null &&
        productNameErrorText == null) {
      try {
        //start loading
        setState(() {
          isLoading = true;
        });

        // Get the newly created user's ID
        String userId = _user!.uid;
        print(userId);
        //Create a map of the data you want to send

        //Send the data to Firestore
        await FirebaseFirestore.instance
            .collection('specials')
            .doc(widget.docId)
            .update({
          'quantity': quantity,
          'productName': productName,
          'price': price,
          'phone': "+266$phone",
          'category': category,
          'location': location,
          'startDate': startDate,
          'endDate': endDate,
          'status': status,
          'pricingUnit': pricingUnit,
          'userId': userId,
        });

        // Clear fields
        productNameController.clear();
        quantityController.clear();
        priceController.clear();
        phoneController.clear();
        locationController.clear();
        categoryController.clear();
        statusController.clear();
        startDateController.clear();
        endDateController.clear();

        setState(() {
          isLoading = false; // Stop loading
        });

        Fluttertoast.showToast(
          msg: "Product updated Sucessfully",
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast will be visible
          gravity: ToastGravity
              .CENTER, // Position of the toast message on the screen
          backgroundColor:
              Colors.black54, // Background color of the toast message
          textColor: Colors.blue, // Text color of the toast message
        );
        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Handle any errors that occur during the data submission

        setState(() {
          isLoading = false; // Stop loading
        });

        print('Error submitting data: $e');
        Fluttertoast.showToast(
          msg: "Something went wrong please try again",
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast will be visible
          gravity: ToastGravity
              .CENTER, // Position of the toast message on the screen
          backgroundColor:
              Colors.black54, // Background color of the toast message
          textColor: Colors.red, // Text color of the toast message
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Promotional Product"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(27.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              const Text(
                'Product Information ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      priceErrorText = 'Price is required';
                    });
                  } else {
                    setState(() {
                      priceErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Price (M)',
                    hintText: '4500',
                    errorText: priceErrorText),
              ),
              const SizedBox(height: 20.0),
              
              TextField(
                controller: pricingUnitController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      pricingUnitErrorText = 'Pricing unit is required';
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Pricing Unit (Per)',
                    hintText: 'kg, tray, bag',
                    errorText: pricingUnitErrorText),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: categoryController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      categoryNameErrorText = 'Category is required';
                    });
                  } else {
                    setState(() {
                      categoryNameErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Meat',
                    errorText: categoryNameErrorText),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: productNameController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      productNameErrorText = 'Product is required';
                    });
                  } else {
                    setState(() {
                      productNameErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Eggs',
                  errorText: productNameErrorText,
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: locationController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      locationErrorText = 'Address is required';
                    });
                  } else {
                    setState(() {
                      locationErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter your address',
                    errorText: locationErrorText),
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
                  hintText: 'Enter quantity',
                  errorText: quantityErrorText,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: startDateController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      startDateErrorText = 'Start date is required';
                    });
                  } else {
                    setState(() {
                      startDateErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  hintText: '20 June 2024',
                  errorText: startDateErrorText,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: endDateController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      endDateErrorText = 'End date is required';
                    });
                  } else {
                    setState(() {
                      endDateErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'End Date',
                  hintText: '20 May 2024',
                  errorText: endDateErrorText,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: statusController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      statusErrorText = 'Status is required';
                    });
                  } else {
                    setState(() {
                      statusErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Status',
                  hintText: 'Enter status',
                  errorText: statusErrorText,
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    const Size(350, 40),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : _register, // Disable button during loading
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Update Product',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
