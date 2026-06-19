/// Represents an authenticated user.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.nationalNumber,
    this.nationalId,
    this.phoneNumber,
    this.role,
    this.identityImageUrl,
    this.verificationStatus,
    this.verificationStatusLabel,
    this.hasFcmToken,
  });

  final int id;
  final String name;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nationalNumber;
  final String? nationalId;
  final String? phoneNumber;
  final String? role;
  final String? identityImageUrl;
  final String? verificationStatus;
  final String? verificationStatusLabel;
  final bool? hasFcmToken;

  bool get isVerified => verificationStatus == 'approved';
  bool get canSubmitVerification =>
      verificationStatus == null ||
      verificationStatus == 'unverified' ||
      verificationStatus == 'rejected';

  factory User.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final fullName = json['name'] as String? ??
        [firstName, lastName].where((part) => part?.isNotEmpty ?? false).join(' ');

    return User(
      id: json['id'] as int? ?? 0,
      name: fullName,
      email: json['email'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      nationalNumber: json['national_number'] as String?,
      nationalId: json['national_id'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String?,
      identityImageUrl: json['identity_image_url'] as String?,
      verificationStatus: json['verification_status'] as String?,
      verificationStatusLabel: json['verification_status_label'] as String?,
      hasFcmToken: json['has_fcm_token'] as bool?,
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? firstName,
    String? lastName,
    String? nationalNumber,
    String? nationalId,
    String? phoneNumber,
    String? role,
    String? identityImageUrl,
    String? verificationStatus,
    String? verificationStatusLabel,
    bool? hasFcmToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationalNumber: nationalNumber ?? this.nationalNumber,
      nationalId: nationalId ?? this.nationalId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      identityImageUrl: identityImageUrl ?? this.identityImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationStatusLabel:
          verificationStatusLabel ?? this.verificationStatusLabel,
      hasFcmToken: hasFcmToken ?? this.hasFcmToken,
    );
  }

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, role: $role, verificationStatus: $verificationStatus)';
}
