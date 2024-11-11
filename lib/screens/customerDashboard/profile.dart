import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmersmarketplace/screens/auth/login.dart';
import 'package:farmersmarketplace/screens/customerDashboard/customer_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile "),
      ),
      body: const Center(child: Text("Profile Page")),
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userId;

  TextEditingController emailController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController namesController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;
  String? namesErrorText;
  String? phoneErrorText;
  String? countryErrorText;
  String? locationErrorText;
  bool isLoading = false;
  String userfullname = 'John Doe';
  String phoneNumber = '+266 78901234';

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
        namesController.text = userData['names'] ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        locationController.text = userData['location'] ?? '';

        setState(() {
          userfullname = userData['names'] ?? 'John Doe';
          phoneNumber = userData['phone'] ?? '+266 78123412';
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
      // Fetch user data from Firestore
      fetchUserData();
    } else if (_user == null) {
      Navigator.pushNamed(context, '/loginpage');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigate to login page or any other page you want after logout
      // Clear the navigation stack and replace it with the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _register() async {
    String email = emailController.text;
    String names = namesController.text;
    String phone = phoneController.text;
    String location = locationController.text;

    // Validate email field
    if (email.isEmpty) {
      setState(() {
        emailErrorText = 'Email is required';
      });
    } else {
      setState(() {
        phoneErrorText = null;
      });
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

    // Validate names field
    if (names.isEmpty) {
      setState(() {
        namesErrorText = 'Full names are required';
      });
    } else {
      setState(() {
        namesErrorText = null;
      });
    }

    // Validate names field
    if (phone.isEmpty) {
      setState(() {
        phoneErrorText = 'Phone number is required';
      });
    } else if (phone.length != 8) {
      phoneErrorText = 'Phone number should be 8 digits';
    } else {
      setState(() {
        phoneErrorText = null;
      });
    }

    // Proceed with registration if both fields are valid
    if (emailErrorText == null &&
        passwordErrorText == null &&
        namesErrorText == null &&
        phoneErrorText == null &&
        locationErrorText == null &&
        countryErrorText == null) {
      try {
        // Start Loading
        setState(() {
          isLoading = true;
        });
        // Find the user document based on their email
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _user!.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Get the document reference and update the fields
          DocumentReference userDocRef = snapshot.docs.first.reference;
          await userDocRef.update({
            'names': names,
            'phone': phone,
            'location': location,
          });

          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              isLoading = false;
            });
          });

          // Display success message or navigate to a success screen
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Profile Updated'),
                content: Text('Your profile has been updated successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        //Stop loading
        setState(() {
          isLoading = false;
        });

        print('Error updating profile: $e');
        // Handle error: Display an error message or take appropriate action
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboardPage()),
        );
        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  _signOut();
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(27.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),
                Image.asset(
                  'assets/images/user.png',
                  height: 140,
                ),
                Text(
                  userfullname,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 7.0),
                Text(
                  phoneNumber,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 40.0),
                TextField(
                  controller: namesController,
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        namesErrorText = 'Full names are required';
                      });
                    } else {
                      setState(() {
                        namesErrorText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Full Names',
                    hintText: 'Enter Full name',
                    errorText: namesErrorText,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        phoneErrorText = 'Phone number is required';
                      });
                    } else {
                      setState(() {
                        phoneErrorText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                      labelText: 'Phone Numbers',
                      hintText: 'Enter phone Number',
                      errorText: phoneErrorText),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: locationController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        phoneErrorText = 'Physical address is required';
                      });
                    } else {
                      setState(() {
                        phoneErrorText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      errorText: locationErrorText),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        emailErrorText = 'Email is required';
                      });
                    } else {
                      setState(() {
                        emailErrorText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter email address',
                    errorText: emailErrorText,
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      const Size(310, 40),
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
                          'Update',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
