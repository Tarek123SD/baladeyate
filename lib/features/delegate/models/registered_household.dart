class HouseholdMember {
  const HouseholdMember({
    required this.fullName,
    required this.nationalId,
    this.relationship,
    this.gender,
    this.birthDate,
  });

  final String fullName;
  final String nationalId;
  final String? relationship;
  final String? gender;
  final String? birthDate;

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      fullName: json['full_name'] as String? ??
          json['name'] as String? ??
          'عضو',
      nationalId: json['national_id'] as String? ??
          json['national_number'] as String? ??
          '',
      relationship: json['relationship'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] as String?,
    );
  }

  String get roleLabel {
    switch (relationship) {
      case 'head':
        return 'رب الأسرة';
      case 'spouse':
      case 'wife':
      case 'husband':
        return 'الزوج/الزوجة';
      case 'son':
        return 'ابن';
      case 'daughter':
        return 'ابنة';
      default:
        return relationship ?? 'فرد';
    }
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '؟';
    }
    return parts.first[0];
  }
}

class RegisteredHousehold {
  const RegisteredHousehold({
    required this.id,
    required this.address,
    required this.members,
    this.electricityMeterNumber,
    this.waterMeterNumber,
  });

  final int id;
  final String address;
  final List<HouseholdMember> members;
  final String? electricityMeterNumber;
  final String? waterMeterNumber;

  factory RegisteredHousehold.fromJson(Map<String, dynamic> json) {
    final membersRaw = json['members'];
    final members = membersRaw is List
        ? membersRaw
            .whereType<Map<String, dynamic>>()
            .map(HouseholdMember.fromJson)
            .toList()
        : <HouseholdMember>[];

    return RegisteredHousehold(
      id: json['id'] as int? ?? 0,
      address: json['address'] as String? ?? '',
      members: members,
      electricityMeterNumber: json['electricity_meter_number'] as String?,
      waterMeterNumber: json['water_meter_number'] as String?,
    );
  }
}

class HouseholdMemberInput {
  const HouseholdMemberInput({
    required this.nationalId,
    required this.fullName,
  });

  final String nationalId;
  final String fullName;

  Map<String, dynamic> toJson() => {
        'national_id': nationalId,
        'full_name': fullName,
      };
}
