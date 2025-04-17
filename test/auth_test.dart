import 'package:my_flutter_app/services/auth/auth_exceptions.dart';
import 'package:my_flutter_app/services/auth/auth_provider.dart';
import 'package:my_flutter_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized at start', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(() => provider.logOut(), throwsA(isA<NotInitializedException>()));
    });

    test('Cannot get current user if not initialized', () {
      expect(
        () => provider.currentUser,
        throwsA(isA<NotInitializedException>()),
      );
    });

    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Create user should delegate to logIn', () async {
      final user = await provider.createUser(
        email: 'test@example.com',
        password: 'password',
      );
      expect(user, provider.currentUser);
      expect(user.isEmailVerified, false);
    });

    test('Login should throw if not initialized', () {
      final uninitializedProvider = MockAuthProvider();
      expect(
        () => uninitializedProvider.logIn(email: 'a', password: 'b'),
        throwsA(isA<NotInitializedException>()),
      );
    });

    test(
      'Login with wrong password should throw UserNotFoundAuthException',
      () async {
        await provider.initialize();
        expect(
          () => provider.logIn(email: 'test@test.com', password: 'sbatsy'),
          throwsA(isA<UserNotFoundAuthException>()),
        );
      },
    );

    test('Login with fail email should throw generic exception', () async {
      await provider.initialize();
      expect(
        () => provider.logIn(email: 'fail@test.com', password: 'pass'),
        throwsA(isA<Exception>()),
      );
    });

    test('Valid login should set current user', () async {
      final user = await provider.logIn(
        email: 'sam@test.com',
        password: 'validpass',
      );
      expect(provider.currentUser, isNotNull);
      expect(user.isEmailVerified, false);
    });

    test('Logout should clear user', () async {
      await provider.logOut();
      expect(provider.currentUser, null);
    });

    test('Logout should throw if user already logged out', () async {
      expect(
        () => provider.logOut(),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test('Send email verification should update user to verified', () async {
      await provider.logIn(email: 'verify@test.com', password: 'validpass');
      expect(provider.currentUser?.isEmailVerified, false);
      await provider.sendEmailVerification();
      expect(provider.currentUser?.isEmailVerified, true);
    });

    test('Send email verification should throw if user is null', () async {
      await provider.logOut();
      expect(
        () => provider.sendEmailVerification(),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test('Send password reset should not throw when initialized', () async {
      await provider.initialize();
      expect(
        () => provider.sendPasswordReset(toEmail: 'reset@test.com'),
        returnsNormally,
      );
    });

    test('Send password reset should throw if not initialized', () {
      final uninitializedProvider = MockAuthProvider();
      expect(
        () =>
            uninitializedProvider.sendPasswordReset(toEmail: 'reset@test.com'),
        throwsA(isA<NotInitializedException>()),
      );
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  AuthUser? _user;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    await Future.delayed(Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  AuthUser? get currentUser {
    if (!_isInitialized) throw NotInitializedException();
    return _user;
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(milliseconds: 1000));
    return logIn(email: email, password: password);
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) throw NotInitializedException();
    if (password == 'sbatsy') throw UserNotFoundAuthException();
    if (email == 'fail@test.com') throw Exception('Invalid credentials');
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(milliseconds: 1000));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!_isInitialized) throw NotInitializedException();
    // Simulate sending email
  }
}
