import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/firebase_options.dart';
import 'package:my_flutter_app/views/login_views.dart';
import 'package:my_flutter_app/views/register_view.dart';
import 'package:my_flutter_app/views/verify_email.dart';
//import 'package:my_flutter_app/views/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        '/register/': (context) => const RegisterView(),
        "/login/": (context) => const LoginView(),
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
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (!user.emailVerified) {
                print('Email is not verified');
                return const VerifyEmail(); // Navigate to email verification page
              } else {
                print('Email is verified');
                return const HomePage(); // Change to your actual homepage widget
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
