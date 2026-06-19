import 'package:baladeyate/features/auth/models/user.dart';

/// Represents the API response from the signup endpoint
class SignupResponse {
  const SignupResponse({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  final bool success;
  final String message;
  final SignupData data;
  final dynamic errors;

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: SignupData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
        'errors': errors,
      };
}

/// Contains the token and user data from signup response
class SignupData {
  const SignupData({
    required this.token,
    required this.tokenType,
    required this.role,
    required this.user,
  });

  final String token;
  final String tokenType;
  final String role;
  final User user;

  factory SignupData.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return SignupData(
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      role: json['role'] as String? ?? '',
      user: userJson is Map<String, dynamic>
          ? User.fromJson(userJson)
          : const User(id: 0, name: '', email: ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'token_type': tokenType,
        'role': role,
        'user': {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'national_number': user.nationalNumber,
          'phone_number': user.phoneNumber,
          'role': user.role,
          'identity_image_url': user.identityImageUrl,
        },
      };
}
