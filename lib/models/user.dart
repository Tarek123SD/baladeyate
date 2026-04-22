/// Simple User model to represent an authenticated user
class User {
  final int id;
  final String name;
  final String email;

  // Constructor
  User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
