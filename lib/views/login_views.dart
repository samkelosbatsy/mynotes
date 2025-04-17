import 'package:flutter/material.dart';
import 'package:my_flutter_app/constant.dart';
import 'package:my_flutter_app/services/auth/auth_exceptions.dart';
import 'package:my_flutter_app/services/auth/auth_services.dart';
import 'package:my_flutter_app/utilites/show_error_dialog.log.dart';

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
        future: AuthService.firebase().initialize(),
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
                          await AuthService.firebase().logIn(
                            email: email,
                            password: password,
                          );

                          final user = AuthService.firebase().currentUser;
                          if (user?.isEmailVerified ?? false) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              NotesRoute,
                              (route) => false,
                            );
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              VerifyEmailRoute,
                              (route) => false,
                            );
                          }

                          // Your registration logic here
                        } on UserNotFoundAuthException {
                          await showErrorDialog(
                            context,
                            'No user found with that email',
                          );
                        } on WrongPasswordAuthException {
                          await showErrorDialog(context, 'Incorrect password');
                        } on InvalidEmailAuthException {
                          await showErrorDialog(
                            context,
                            'Invalid email address',
                          );
                        } on GenericAuthException catch (e) {
                          await showErrorDialog(
                            context,
                            'Login failed: ${e.toString()}',
                          );
                        }
                      },

                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          RegisterRoute,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Don\'t have the account? Register here',
                      ),
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
