/// Represents an authenticated user.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
