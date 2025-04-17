import 'package:flutter/material.dart';
import 'package:my_flutter_app/constant.dart';
import 'package:my_flutter_app/services/auth/auth_services.dart';
import 'package:my_flutter_app/views/login_views.dart';
import 'package:my_flutter_app/views/notes_views.dart';
import 'package:my_flutter_app/views/register_view.dart';
import 'package:my_flutter_app/views/verify_email.dart';
//import 'dart:developer' as devtools show log;
//import 'package:my_flutter_app/views/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        NotesRoute: (context) => const NotesView(),
        RegisterRoute: (context) => const RegisterView(),
        LoginRoute: (context) => const LoginView(),
        VerifyEmailRoute: (context) => const VerifyEmail(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),

      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (!user.isEmailVerified) {
                return const VerifyEmail(); // Navigate to email verification page
              } else {
                return const NotesView(); // Change to your actual homepage widget
              }
            } else {
              return const LoginView(); // Redirect to login if no user is signed in
            }
          default:
            return const Center(child: Text('Checking authentication...'));
        }
      },
    );
  }
}
