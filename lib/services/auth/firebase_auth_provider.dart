import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:my_flutter_app/services/auth/auth_provider.dart';
import 'package:my_flutter_app/services/auth/auth_user.dart';
import 'package:my_flutter_app/services/auth/auth_exceptions.dart';

class FirebaseAuthProvider implements AuthProvider {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthProvider({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw GenericAuthException(
          'Login failed - no user returned',
          'no-user',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        throw GenericAuthException(
          'Email not verified - verification email resent',
          'email-not-verified',
        );
      }

      return AuthUser.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw GenericAuthException('Unexpected login error', 'unexpected-error');
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw GenericAuthException('User creation failed', 'creation-failed');
      }

      await user.sendEmailVerification();
      return AuthUser.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw GenericAuthException(
        'Unexpected registration error',
        'unexpected-error',
      );
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw GenericAuthException('Logout failed', 'logout-failed');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw GenericAuthException(
        'No authenticated user',
        'no-authenticated-user',
      );
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  GenericAuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return GenericAuthException(
          'Account already exists with this email',
          e.code,
        );
      case 'invalid-email':
        return GenericAuthException('Invalid email address', e.code);
      case 'operation-not-allowed':
        return GenericAuthException(
          'Email/password accounts are not enabled',
          e.code,
        );
      case 'weak-password':
        return GenericAuthException(
          'Password must be at least 6 characters',
          e.code,
        );
      case 'user-disabled':
        return GenericAuthException('This account has been disabled', e.code);
      case 'user-not-found':
        return GenericAuthException('No account found with this email', e.code);
      case 'wrong-password':
        return GenericAuthException('Incorrect password', e.code);
      case 'too-many-requests':
        return GenericAuthException(
          'Too many attempts - try again later',
          e.code,
        );
      default:
        return GenericAuthException(
          'Authentication error: ${e.message}',
          e.code,
        );
    }
  }
}
