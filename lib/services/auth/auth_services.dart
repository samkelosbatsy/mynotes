import 'package:my_flutter_app/services/auth/auth_provider.dart';
import 'package:my_flutter_app/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    return await provider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    return await provider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() async {
    await provider.logOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    await provider.sendEmailVerification();
  }
}
