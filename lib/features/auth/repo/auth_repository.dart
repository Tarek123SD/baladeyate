import 'package:baladeyate/features/auth/models/user.dart';

/// Handles authentication API and mock data access.
class AuthRepository {
  /// Mock login; returns a [User] on success.
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (!email.contains('@') && email.length < 3) {
      throw Exception('Invalid credentials');
    }

    return User(
      id: 1,
      name: 'John Doe',
      email: email.contains('@') ? email : '$email@baladeyate.local',
    );
  }
}
