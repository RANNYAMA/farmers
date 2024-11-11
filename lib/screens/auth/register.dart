import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController namesController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // Variable to store toggle selection (0 for 'Customer', 1 for 'Farmer')
  int selectedUser = 0; // Default to 'Customer'
  int selectedFarmType = 0;
  bool _obscureText = true;

  // Farmer-specific controllers
  TextEditingController farmNameController = TextEditingController();
  TextEditingController farmSizeController = TextEditingController();
  TextEditingController farmdescriptionController = TextEditingController();
  TextEditingController customFarmTypeController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;
  String? namesErrorText;
  String? phoneErrorText;
  String? locationErrorText;
  String? farmdescriptionErrorText;
  bool isLoading = false;

  String _getFarmTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return 'Livestock';
      case 1:
        return 'Crop';
      case 2:
        return 'Mixed';
      default:
        return 'Other';
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
    String email = emailController.text;
    String password = passwordController.text;
    String names = namesController.text;
    String phone = phoneController.text;
    String location = locationController.text;

    // Farmer-specific details
    String farmName = farmNameController.text;
    String farmSize = farmSizeController.text;
    String farmdescription = farmdescriptionController.text;

    names = capitalizeFirstLetters(names);
    location = capitalizeFirstLetters(location);
    farmName = capitalizeFirstLetters(farmSize);

    String farmType = selectedFarmType == 3
        ? customFarmTypeController
            .text // If "Other" is selected, use custom farm type
        : _getFarmTypeFromIndex(selectedFarmType);

    // Validate email field
    if (email.isEmpty) {
      setState(() {
        emailErrorText = 'Email is required';
      });
    } else {
      setState(() {
        emailErrorText = null;
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

    // Validate password field
    if (password.isEmpty) {
      setState(() {
        passwordErrorText = 'Password is required';
      });
    } else if (password.length < 8) {
      setState(() {
        passwordErrorText = 'Password should be at least 8 characters long';
      });
    } else {
      setState(() {
        passwordErrorText = null;
      });
    }

    if (selectedUser == 1) {
      if (farmdescription.isEmpty) {
        setState(() {
          farmdescriptionErrorText = 'Farm description is required';
        });
      } else {
        setState(() {
          farmdescriptionErrorText = null;
        });
      }
      // Only for farmers
      if (farmName.isEmpty) {
        Fluttertoast.showToast(
          msg: "Farm name is required for farmers",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }
      if (farmSize.isEmpty) {
        Fluttertoast.showToast(
          msg: "Farm size is required for farmers",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }
    }

    // Proceed with registration if both fields are valid
    if (emailErrorText == null &&
        passwordErrorText == null &&
        namesErrorText == null &&
        phoneErrorText == null &&
        locationErrorText == null) {
      try {
        //start loading
        setState(() {
          isLoading = true;
        });
        // Create user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get the newly created user's ID
        String userId = userCredential.user!.uid;
        print(userId);
        //Create a map of the data you want to send

        Map<String, dynamic> userData = {
          'email': email,
          'names': names,
          'phone': "+266$phone",
          'location': location,
          'userType':
              selectedUser == 0 ? 'Customer' : 'Farmer', // Toggle value,
          'userId': userId,
        };

        // Add farmer-specific data
        if (selectedUser == 1) {
          // Farmer
          userData['farmName'] = farmName;
          userData['farmType'] = farmType;
          userData['farmSize'] = farmSize;
          userData['farmdescription'] = farmdescription;
        }
        // Send the data to Firestore
        await FirebaseFirestore.instance.collection('users').add(userData);

        // // Subscribe the user to the topic
        // FirebaseMessaging.instance.subscribeToTopic('all_users');

        // Clear fields
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        namesController.clear();
        locationController.clear();

        setState(() {
          isLoading = false; // Stop loading
        });

        Fluttertoast.showToast(
          msg: "Account created Sucessfully",
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast will be visible
          gravity: ToastGravity
              .CENTER, // Position of the toast message on the screen
          backgroundColor:
              Colors.black54, // Background color of the toast message
          textColor: Colors.green, // Text color of the toast message
        );
        // Navigate to login
        Navigator.pushNamed(context, '/loginpage');
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
      // appBar: AppBar(
      //   title: const Text("Create an Account"),
      //   centerTitle: true,
      // ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/meat.avif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(27.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70.0),
                    const Text(
                      'Create an account!',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w400,
                      ),
                      // style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 7.0),
                    const Text(
                      'Create your profile to join our MarketPlace today.',
                      style: TextStyle(fontSize: 15.0),
                    ),
                    const SizedBox(height: 40.0),
                          
                    ToggleSwitch(
                      minWidth: 160.0,
                      initialLabelIndex:
                          selectedUser, // Set initial value to match current selection
                      cornerRadius: 20.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      labels: ['Customer', 'Farmer'],
                      activeBgColors: [
                        [Colors.blue],
                        [Colors.pink]
                      ],
                      onToggle: (index) {
                        setState(() {
                          selectedUser =
                              index!; // Update selectedUser when toggled
                        });
                        print(
                            'UserType switched to: ${selectedUser == 0 ? 'Customer' : 'Farmer'}');
                      },
                    ),
                         const SizedBox(height: 16.0),
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
         
                    if (selectedUser == 1) ...[
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: farmNameController,
                        decoration: const InputDecoration(
                          labelText: 'Farm Name',
                          hintText: 'Enter your farm name',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Farming Type',
                        style: TextStyle(fontSize: 15.0),
                      ),
                      const SizedBox(height: 10.0),
                      ToggleSwitch(
                        minWidth: 160.0,
                        initialLabelIndex:
                            selectedFarmType, // Set initial value to match current selection
                        cornerRadius: 20.0,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        totalSwitches: 4,
                        labels: ['Livestock', 'Crop', 'Mixed', 'Other'],
                        activeBgColors: [
                          [Colors.blue],
                          [Colors.pink],
                          [Colors.green],
                          [Colors.lime],
                        ],
                        onToggle: (index) {
                          setState(() {
                            selectedFarmType =
                                index!; // Update selectedUser when toggled
                          });
                        },
                      ),
                      if (selectedFarmType == 3) ...[
                        const SizedBox(height: 10.0),
                        TextField(
                          controller: customFarmTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Other Farm Type',
                            hintText: 'Enter custom farm type',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: farmSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Farm Size',
                          hintText: 'Enter farm size (e.g., 50 acres)',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: farmdescriptionController,
                        maxLines: 3,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              farmdescriptionErrorText =
                                  'Farm description is required';
                            });
                          } else {
                            setState(() {
                              farmdescriptionErrorText = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Description of Farm',
                          hintText: 'Describe what your farm offres',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                                BorderRadius.all(Radius.circular(9.0)),
                          ),
                          errorText: farmdescriptionErrorText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0),
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
                          hintText: 'Masowe Maseru',
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
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            passwordErrorText = 'Password is required';
                          });
                        } else if (value.length < 8) {
                          setState(() {
                            passwordErrorText =
                                'Password should be at least 8 characters long';
                          });
                        } else {
                          setState(() {
                            passwordErrorText = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        errorText: passwordErrorText,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(fontSize: 16.0),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account ?',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(width: 5),
                        TextButton(
                          child: const Text(
                            'Login',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 18.0),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/loginpage');
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
