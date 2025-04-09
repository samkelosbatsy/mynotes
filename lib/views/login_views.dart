import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
              return Padding(
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
                      decoration: const InputDecoration(labelText: 'Password'),
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
                              .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                          _showSnackBar(
                            "Logged in successfully: ${userCredential.user?.email}",
                          );

                          // Navigate to another page if needed
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardPage()));
                        } on FirebaseAuthException catch (e) {
                          String message = 'Login failed: ${e.message}';
                          if (e.code == 'user-not-found') {
                            message = 'No user found with this email';
                          } else if (e.code == 'wrong-password') {
                            message = 'Incorrect password';
                          } else if (e.code == 'invalid-email') {
                            message = 'Invalid email address';
                          }
                          _showSnackBar(message);
                        } catch (e) {
                          _showSnackBar('Error: $e');
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ],
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
