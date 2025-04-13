// ignore: depend_on_referenced_packages
//import 'package:projects/services/auth/auth_user.dart';
import 'package:my_flutter_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser> logIn({required String email, required String password});

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

  // Recommended additional methods
  // Future<void> sendPasswordResetEmail(String email);
  //Future<void> reloadUser();
}
