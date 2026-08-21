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
    this.rejectionReason,
    this.hasFcmToken,
    this.fieldWorkTypes = const [],
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
  final String? rejectionReason;
  final bool? hasFcmToken;
  final List<String> fieldWorkTypes;

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
      rejectionReason: json['rejection_reason'] as String?,
      hasFcmToken: json['has_fcm_token'] as bool?,
      fieldWorkTypes: _stringList(json['field_work_types']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'national_number': nationalNumber,
        'national_id': nationalId,
        'phone_number': phoneNumber,
        'role': role,
        'identity_image_url': identityImageUrl,
        'verification_status': verificationStatus,
        'verification_status_label': verificationStatusLabel,
        'has_fcm_token': hasFcmToken,
        'field_work_types': fieldWorkTypes,
      };

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
    String? rejectionReason,
    bool? hasFcmToken,
    List<String>? fieldWorkTypes,
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
      rejectionReason: rejectionReason ?? this.rejectionReason,
      hasFcmToken: hasFcmToken ?? this.hasFcmToken,
      fieldWorkTypes: fieldWorkTypes ?? this.fieldWorkTypes,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, role: $role, verificationStatus: $verificationStatus, fieldWorkTypes: $fieldWorkTypes)';
}
