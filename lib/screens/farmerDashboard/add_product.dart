import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userId;

  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController pricingUnitController = TextEditingController();

  String? quantityErrorText;
  String? priceErrorText;
  String? pricingUnitErrorText;
  String? productNameErrorText;
  String? locationErrorText;
  String? categoryErrorText;
  int selectedDeliveryOption = 0; // Default to 'Customer'
  int selectedCategory = 0; // To track the selected category index

  // List of categories
  final List<String> categories = [
    'Vegetables',
    'Grains',
    'Fruits',
    'Meat',
    'Eggs'
  ];
  bool isLoading = false;
  bool isImageProcessing = false;

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
        locationController.text = userData['location'] ?? '';
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
      // Fetch user data from Firestore
      fetchUserData();
    } else if (_user == null) {
      Navigator.pushNamed(context, '/loginpage');
    }
  }

  File? _selectedImage;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      setState(() {
        isImageProcessing = true;
      });
      try {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final filePath = _selectedImage!.path;
        final extension = filePath.split('.').last; // Get the file extension
        final destination = 'productImage/$fileName.$extension';

        final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
        final uploadTask = ref.putFile(_selectedImage!);

        final snapshot = await uploadTask.whenComplete(() {});

        if (snapshot.state == firebase_storage.TaskState.success) {
          final downloadUrl = await ref.getDownloadURL();
          setState(() {
            _imageUrl = downloadUrl;
            isImageProcessing = false;
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
        setState(() {
          isImageProcessing = false;
        });
        Fluttertoast.showToast(
          msg: "Something went wrong, please try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.red,
        );
      }
    }
  }

  String capitalizeFirstLetters(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _register() async {
    String phone = phoneController.text;
    String location = locationController.text;
    String productName = productNameController.text;
    String quantity = quantityController.text;
    String price = priceController.text;
    String pricingUnit = pricingUnitController.text;
    String category = categoryController.text;

    productName = capitalizeFirstLetters(productName);
    location = capitalizeFirstLetters(location);

    // Validate email field
    if (price.isEmpty) {
      setState(() {
        priceErrorText = 'Price is required';
      });
    } else {
      setState(() {
        priceErrorText = null;
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
    if (category.isEmpty) {
      setState(() {
        categoryErrorText = 'Category is required';
      });
    } else {
      setState(() {
        categoryErrorText = null;
      });
    }
    if (productName.isEmpty) {
      setState(() {
        productNameErrorText = 'Product name is required';
      });
    } else {
      setState(() {
        productNameErrorText = null;
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

    //validate Image
    if (_selectedImage == null) {
      Fluttertoast.showToast(
        msg: "Please select an image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.red,
      );
      return; // Exit the function without sending data
    }

    if (location.isEmpty) {
      setState(() {
        locationErrorText = 'Address is required';
      });
    } else {
      setState(() {
        locationErrorText = null;
      });
    }

    // Call _uploadImage to upload the selected image
    await _uploadImage();

    // Proceed with registration if both fields are valid
    if (priceErrorText == null &&
        quantityErrorText == null &&
        pricingUnitErrorText == null &&
        // categoryErrorText == null &&
        locationErrorText == null) {
      try {
        //start loading
        setState(() {
          isLoading = true;
        });

        // Get the newly created user's ID
        String userId = _user!.uid;
        print(userId);
        //Create a map of the data you want to send

        // Use the selectedCategory index to map the corresponding category
        String selectedCategoryName = categories[selectedCategory];

        Map<String, dynamic> userData = {
          'productName': productName,
          'quantity': quantity,
          'price': price,
          'phone': phone,
          'location': location,
          'category': selectedCategoryName,
          'delivery':
              selectedDeliveryOption == 0 ? 'Yes' : 'No', // Toggle value,
          'userId': userId,
          'productImage': _imageUrl,
          'pricingUnit': pricingUnit,
        };
        //Send the data to Firestore
        await FirebaseFirestore.instance.collection('products').add(userData);

        // // Subscribe the user to the topic
        // FirebaseMessaging.instance.subscribeToTopic('all_users');

        // Clear fields
        quantityController.clear();
        priceController.clear();
        priceController.clear();
        productNameController.clear();
        phoneController.clear();
        categoryController.clear();
        locationController.clear();

        setState(() {
          isLoading = false; // Stop loading
        });

        Fluttertoast.showToast(
          msg: "Product added was Sucessfully",
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast will be visible
          gravity: ToastGravity
              .CENTER, // Position of the toast message on the screen
          backgroundColor:
              Colors.black54, // Background color of the toast message
          textColor: Colors.green, // Text color of the toast message
        );
        // Navigate back
        // Navigator.pop(context);
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
        title: const Text("Add Product"),
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
              const Text(
                'Upload your Product to the market.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.w400,
                ),
                // style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 30.0),
              const Text(
                'Product Information ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10.0),
              const SizedBox(height: 16.0),
              TextField(
                controller: productNameController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      productNameErrorText = 'Product name is required';
                    });
                  } else {
                    setState(() {
                      productNameErrorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Cabbage',
                  errorText: productNameErrorText,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Category',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4.0),
              ToggleSwitch(
                minWidth: 160.0,
                initialLabelIndex:
                    selectedCategory, // Set initial value to match current selection
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 5,
                labels: categories,
                activeBgColors: [
                  [Colors.blue],
                  [Colors.pink],
                  [Colors.blue],
                  [Colors.blue],
                  [Colors.pink],
                ],
                onToggle: (index) {
                  setState(() {
                    selectedCategory =
                        index!; // Update selectedUser when toggled
                  });
                },
              ),

              const SizedBox(height: 16.0),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      priceErrorText = 'Price is required';
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: 'M250.00',
                    errorText: priceErrorText),
              ),
              const SizedBox(height: 16.0),

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
                    labelText: 'Pricing Unit',
                    hintText: 'Per kg, Per tray, per bag',
                    errorText: pricingUnitErrorText),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Delivery',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4.0),
              ToggleSwitch(
                minWidth: 160.0,
                initialLabelIndex:
                    selectedDeliveryOption, // Set initial value to match current selection
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                labels: ['Yes', 'No'],
                activeBgColors: [
                  [Colors.blue],
                  [Colors.pink]
                ],
                onToggle: (index) {
                  setState(() {
                    selectedDeliveryOption =
                        index!; // Update selectedUser when toggled
                  });
                  print(
                      'UserType switched to: ${selectedDeliveryOption == 0 ? 'Yes' : 'No'}');
                },
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
              const SizedBox(height: 8.0),
              _selectedImage != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
              const SizedBox(height: 6.0),
              TextButton(
                onPressed: () {
                  _pickImage();
                },
                child: Text(
                    _selectedImage != null
                        ? 'Change Product Image'
                        : 'Select Product Image',
                    style: const TextStyle(fontSize: 17.0)),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    const Size(350, 40),
                  ),
                ),
                onPressed: isLoading || isImageProcessing
                    ? null
                    : _register, // Disable button during loading
                child: isLoading || isImageProcessing
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
                        'Submit',
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
