import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/constant.dart';
import 'package:my_flutter_app/firebase_options.dart';
import 'package:my_flutter_app/utilites/show_error_dialog.log.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final email = _email.text.trim();
                          final password = _password.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            _showSnackBar('Please fill in all fields');
                            return;
                          }

                          try {
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                            _showSnackBar(
                              "Registered successfully: ${userCredential.user?.email}",
                            );
                            Navigator.of(context).pushNamed(VerifyEmailRoute);
                          } on FirebaseAuthException catch (e) {
                            String message =
                                'Registration failed: ${e.message}';
                            if (e.code == 'weak-password') {
                              message =
                                  'Password must be at least 6 characters';
                            } else if (e.code == 'email-already-in-use') {
                              message = 'Email already in use';
                            } else if (e.code == 'invalid-email') {
                              message = 'Invalid email address';
                            }
                            await showErrorDialog(context, message);
                          } catch (e) {
                            await showErrorDialog(context, 'Error: $e');
                          }
                        },
                        child: const Text('Register'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginRoute,
                            (route) => false,
                          );
                        },
                        child: const Text('Already registed? Login here'),
                      ),
                    ],
                  ),
                ),
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
