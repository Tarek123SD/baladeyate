/// Temporary identifier returned after a correct password, before OTP verify.
class LoginChallenge {
  const LoginChallenge({
    required this.email,
    required this.challengeToken,
    required this.message,
    this.expiresIn = 900,
  });

  final String email;
  final String challengeToken;
  final String message;
  final int expiresIn;
}
