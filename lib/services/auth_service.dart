import 'package:baladeyate/models/user.dart';

/// AuthService handles authentication logic
/// In a real app, this would call an API
class AuthService {
  /// Mock login function that simulates a network request
  /// Takes email and password, returns a User on success
  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple mock validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    // Return a mock user (in real app, this would come from an API)
    return User(
      id: 1,
      name: 'John Doe',
      email: email,
    );
  }
}
