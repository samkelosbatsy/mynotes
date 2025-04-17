import 'package:flutter/material.dart';

import 'package:my_flutter_app/constant.dart';
import 'package:my_flutter_app/services/auth/auth_services.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          children: [
            const Text('Please verify your email address.'),
            TextButton(
              onPressed: () async {
                AuthService.firebase().sendEmailVerification();
              },
              child: const Text('Resend verification email'),
            ),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(LoginRoute, (route) => false);
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
