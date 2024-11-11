import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userId;

  String? emailErrorText;
  String? messageErrorText;
  bool isLoading = false;

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
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['phone'] ?? '';
  


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

  Future<void> _sendForm() async {
    String email = emailController.text;
    String message = messageController.text;


    if (message.isEmpty) {
      setState(() {
        messageErrorText = 'Message is required';
      });
    } else {
      setState(() {
        messageErrorText = null;
      });
    }

    if (messageErrorText == null && emailErrorText == null) {
      Map<String, dynamic> userContact = {
        'emailAddress': email,
        'message': message,
        'phone' : phoneController.text,
      };
      try {
        setState(() {
          isLoading = true;
        });
        // Send the data to Firestore
        await FirebaseFirestore.instance
            .collection('userContacts')
            .add(userContact);

        // Clear fields
        messageController.clear();

        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            isLoading = false;
          });
        });

        Fluttertoast.showToast(
          msg: "Message Sent! We'll be in touch soon.",
          toastLength: Toast
              .LENGTH_LONG, // Duration for which the toast will be visible
          gravity: ToastGravity
              .CENTER, // Position of the toast message on the screen
          backgroundColor:
              Colors.black54, // Background color of the toast message
          textColor: Colors.green, // Text color of the toast message
        );
        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Stop loading
        setState(() {
          isLoading = false;
        });
        // Handle any errors that occur during the data submission

        print('Error submitting data: $e');
        Fluttertoast.showToast(
          msg: "Something went wrong please try again",
          // msg: '$e',
          toastLength: Toast
              .LENGTH_LONG, // Duration for which the toast will be visible
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Contact'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(27.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0),
            const Text(
              'If you have questions or queries, we re here to help! Feel free to reach out to us through the provided contact options. Whether you need assistance with app features, privacy concerns, or any other inquiries, our dedicated support team is ready to assist you',
              style: TextStyle(fontSize: 16.0),
            ),

            const SizedBox(height: 16.0),
            TextField(
              controller: messageController,
              maxLines: 3,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    messageErrorText = 'Message is required';
                  });
                } else {
                  setState(() {
                    messageErrorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: ' Enter your message',
                errorText: messageErrorText,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  const Size(310, 42),
                ),
              ),
              onPressed: () {
                if (!isLoading) {
                  _sendForm();
                }
              },
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
                  : const Text('Submit', style: TextStyle(fontSize: 16.0)),
            ),
          ],
        ),
      ),
    );
  }
}
