import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/constant.dart';
import 'package:my_flutter_app/firebase_options.dart';
import 'package:my_flutter_app/views/login_views.dart';
import 'package:my_flutter_app/views/register_view.dart';
import 'package:my_flutter_app/views/verify_email.dart';
import 'dart:developer' as devtools show log;
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
        NotesRoute: (context) => const NotesView(),
        RegisterRoute: (context) => const RegisterView(),
        LoginRoute: (context) => const LoginView(),
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

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

//enum MenuAction { logout }

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(LoginRoute, (_) => false);
                }
              }
              devtools.log(value.toString());
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: const Center(child: Text('Hello World')),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm logout
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // default to false if null
}
