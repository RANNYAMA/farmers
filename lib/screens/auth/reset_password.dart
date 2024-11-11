import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  String? emailErrorText;
  bool isLoading = false;

  void _resetPassword() async {
    String email = emailController.text;

    if (email.isEmpty) {
      setState(() {
        emailErrorText = 'Email is required';
      });
    } else {
      try {
        setState(() {
          isLoading = true;
        });
        // Send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            isLoading = false;
          });
        });

        // Clear fields
        emailController.clear();

        // Display success message or navigate to a success screen
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Password Reset Email Sent'),
              content: Text(
                'A password reset email has been sent to $email. Please check your email to reset your password.',
              ),
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
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error sending password reset email: $e');
        // Handle error: Display an error message or take appropriate action
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
                image: AssetImage('assets/images/purple.avif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(27.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Please enter your email address to recover your password',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 60.0),
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
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      const Size(330, 42),
                    ),
                  ),
                  onPressed: isLoading ? null : _resetPassword,
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
                      : const Text('Recover Password',
                          style: TextStyle(fontSize: 16.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
