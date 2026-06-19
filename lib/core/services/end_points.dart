// ignore_for_file: constant_identifier_names

/// Urban Services API endpoints (Postman: Urban Services API).
class EndPoints {
  /// Android emulator maps host localhost via 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8000/api/';

  // Auth
  static const String signup = 'v1/signup';
  static const String login = 'v1/login';
  static const String logout = 'v1/logout';

  // Citizen
  static const String profile = 'v1/profile';
  static const String verifyIdentity = 'v1/citizen/verify-identity';
  static const String myHousehold = 'v1/citizen/my-household';
  static const String complaints = 'v1/complaints';
  static String complaintById(int id) => 'v1/complaints/$id';

  // Delegate
  static const String buildings = 'v1/buildings';
  static String buildingById(int id) => 'v1/buildings/$id';
  static const String apartments = 'v1/apartments';
  static String apartmentById(int id) => 'v1/apartments/$id';
  static const String families = 'v1/families';
  static String familyById(int id) => 'v1/families/$id';
  static const String households = 'v1/households';

  // Admin
  static const String shops = 'v1/shops';
  static String shopById(int id) => 'v1/shops/$id';
  static const String graves = 'v1/graves';
  static String graveById(int id) => 'v1/graves/$id';

  // Shared
  static const String fcmToken = 'v1/notifications/fcm-token';
}
