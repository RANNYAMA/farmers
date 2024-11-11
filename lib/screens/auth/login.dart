import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  String? emailErrorText;
  String? passwordErrorText;
  String? loginErrorText; // New variable for login error message
  bool isLoading = false;

  void _login() {
    String email = emailController.text;
    String password = passwordController.text;

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

    // Validate password field
    if (password.isEmpty) {
      setState(() {
        passwordErrorText = 'Password is required';
      });
    } else {
      setState(() {
        passwordErrorText = null;
      });
    }

    // Proceed with registration if both fields are valid
    if (emailErrorText == null && passwordErrorText == null) {
      try {
        // Sign in the user with email and password
        setState(() {
          isLoading = true;
        });

        FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((userCredential) {
          // Clear fields

          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              isLoading = false;
            });
          });

          // Assuming you have the authenticated user's ID in a variable called 'userId'
          String userId = userCredential.user!.uid;

          // Navigator.pushNamed(context, '/customerDashboard');
          // emailController.clear();
          // passwordController.clear();

// Fetch user data from Firestore where 'userID' matches 'userId'
          FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: userId)
              .get()
              .then((QuerySnapshot customerSnapshot) {
          if (customerSnapshot.docs.isNotEmpty) {

            var customerData =
                customerSnapshot.docs.first.data() as Map<String, dynamic>;
            var role = customerData['userType'];


            if (role == 'Farmer') {

              Navigator.pushNamed(context, '/farmersDashboard');
              emailController.clear();
              passwordController.clear();
            } else {

              Navigator.pushNamed(context, '/customerDashboard');
              emailController.clear();
              passwordController.clear();
            }
          } else {

            print('No matching document found.');
          }

          setState(() {
            isLoading = false;
          });
          }).catchError((error) {
            // Handle Firestore errors
            setState(() {
              isLoading = false;
            });
            print('Firestore error: $error');
          });

          // Navigate to dashboard or home screen
          // Navigator.pushNamed(context, '/userdashboard');
          // Navigator.pushNamed(context, '/admin');
        }).catchError((error) {
          // Stop loading
          setState(() {
            isLoading = false;
          });
          // Handle login errors
          setState(() {
            loginErrorText =
                'Incorrect email or password'; // Set login error message
          });
          print('Login error: $error');
        });
      } catch (e) {
        // Handle any other errors that occur during login
        print('Error occurred during login: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/veg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(27.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                            ClipOval(
              child: Image.asset(
                'assets/images/agro.jpg',
                height: 170,
              ),
            ),
                const Text(
                  'FarmDeal',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w400,
                  ),
             
                ),
                  const SizedBox(height: 5.0),
                             const Text(
                  'Lets get Started',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                  ),
             
                ),
                const SizedBox(height: 50.0),
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
                const SizedBox(height: 8.0),
                Text(
                  loginErrorText ??
                      '', // Show login error message if it's not null, otherwise show an empty string
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/resetPassword');
                  },
                  child: Container(
                    width:
                        double.infinity, // Set the container's width to expand
                    alignment:
                        Alignment.centerRight, // Align the text to the right
                    child: const Text(
                      'Forgot password ?',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      const Size(310, 42),
                    ),
                  ),
                  onPressed: isLoading ? null : _login,
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
                      : const Text('Login', style: TextStyle(fontSize: 16.0)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Do not have an account yet ?',
                      style: TextStyle(fontSize: 15.0),
                    ),
                    TextButton(
                      child: const Text(
                        'Join now',
                        style: TextStyle(color: Colors.blue, fontSize: 17.0),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
