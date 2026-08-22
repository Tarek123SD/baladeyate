// ignore_for_file: constant_identifier_names

/// Urban Services API endpoints (Postman: Urban Services API).
class EndPoints {
  /// Production API host (Postman: Urban Services API).
  static const String baseUrl = 'https://baladeyate.me/api/';

  // Auth
  static const String signup = 'v1/signup';
  static const String login = 'v1/login';
  static const String logout = 'v1/logout';
  static const String forgotPassword = 'v1/auth/forgot-password';
  static const String verifyOtp = 'v1/auth/verify-otp';
  static const String resetPassword = 'v1/auth/reset-password';

  // Citizen
  static const String profile = 'v1/profile';
  static const String verifyIdentity = 'v1/citizen/verify-identity';
  static const String myHousehold = 'v1/citizen/my-household';
  static const String complaints = 'v1/complaints';
  static String complaintById(int id) => 'v1/complaints/$id';
  static const String transactionTypes = 'v1/citizen/transaction-types';
  static const String transactions = 'v1/citizen/transactions';
  static String transactionById(int id) => 'v1/citizen/transactions/$id';
  static String transactionDocuments(int id) =>
      'v1/citizen/transactions/$id/documents';
  static String transactionCancel(int id) =>
      'v1/citizen/transactions/$id/cancel';
  static const String digitalDocuments = 'v1/citizen/digital-documents';
  static const String graveReservations = 'v1/citizen/grave-reservations';
  static String graveReservationById(int id) =>
      'v1/citizen/grave-reservations/$id';
  static String graveReservationCancel(int id) =>
      'v1/citizen/grave-reservations/$id/cancel';

  // Delegate
  static const String buildings = 'v1/buildings';
  static String buildingById(int id) => 'v1/buildings/$id';
  static const String apartments = 'v1/apartments';
  static String apartmentById(int id) => 'v1/apartments/$id';
  static const String families = 'v1/families';
  static String familyById(int id) => 'v1/families/$id';
  static const String households = 'v1/households';
  static const String delegateMyTasks = 'v1/delegate/my-tasks';
  static String delegateMyTaskById(int id) => 'v1/delegate/my-tasks/$id';
  static String delegateMyTaskStatus(int id) =>
      'v1/delegate/my-tasks/$id/status';
  static const String delegateTransactions = 'v1/delegate/transactions';
  static String delegateTransactionById(int id) =>
      'v1/delegate/transactions/$id';
  static String delegateTransactionInspect(int id) =>
      'v1/delegate/transactions/$id/inspect';
  static const String delegateComplaints = 'v1/delegate/complaints';
  static String delegateComplaintById(int id) => 'v1/delegate/complaints/$id';
  static String delegateComplaintInspect(int id) =>
      'v1/delegate/complaints/$id/inspect';
  static const String verifyDocument = 'v1/delegate/verify-document';

  // Admin
  static const String shops = 'v1/shops';
  static String shopById(int id) => 'v1/shops/$id';
  static const String graves = 'v1/graves';
  static String graveById(int id) => 'v1/graves/$id';
  static String cemeteryMap(int id) => 'v1/cemeteries/$id/map';

  // Shared (auth:sanctum)
  static const String notifications = 'v1/notifications';
  static String notificationRead(String id) => 'v1/notifications/$id/read';
  static const String notificationsReadAll = 'v1/notifications/read-all';
  static const String fcmToken = 'v1/notifications/update-fcm-token';

  // Donations & Special Cases (our API — cases managed from the dashboard)
  static const String donations = 'v1/donations';
  static String donationById(int id) => 'v1/donations/$id';
  static String donationDonate(int id) => 'v1/donations/$id/donate';
}
