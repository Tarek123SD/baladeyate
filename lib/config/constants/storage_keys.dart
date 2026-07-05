/// Centralized storage keys for SharedPreferences and secure storage.
class StorageKeys {
  StorageKeys._();

  static const String token = 'token';
  static const String role = 'role';
  static const String user = 'user';
  static const String signupVerificationNoticeShown =
      'signup_verification_notice_shown';
  static const String pendingSignupVerificationNotice =
      'pending_signup_verification_notice';
  static const String delegateDraftPins = 'delegate_draft_pins';
}
