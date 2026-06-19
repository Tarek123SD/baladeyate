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

class Household {
  const Household({
    required this.address,
    required this.members,
    this.familyBook,
    this.buildingName,
    this.district,
    this.electricityMeterNumber,
    this.waterMeterNumber,
  });

  final String address;
  final List<HouseholdMember> members;
  final String? familyBook;
  final String? buildingName;
  final String? district;
  final String? electricityMeterNumber;
  final String? waterMeterNumber;

  factory Household.fromJson(Map<String, dynamic> json) {
    final membersRaw = json['members'];
    final members = membersRaw is List
        ? membersRaw
            .whereType<Map<String, dynamic>>()
            .map(HouseholdMember.fromJson)
            .toList()
        : <HouseholdMember>[];

    final apartment = json['apartment'];
    final building = json['building'];
    String? buildingName;
    if (building is Map<String, dynamic>) {
      buildingName = building['name'] as String?;
    } else if (apartment is Map<String, dynamic>) {
      final nestedBuilding = apartment['building'];
      if (nestedBuilding is Map<String, dynamic>) {
        buildingName = nestedBuilding['name'] as String?;
      }
    }

    final family = json['family'];
    String? familyBook;
    if (family is Map<String, dynamic>) {
      familyBook = family['family_book'] as String?;
    }

    return Household(
      address: json['address'] as String? ?? '—',
      members: members,
      familyBook: familyBook ?? json['family_book'] as String?,
      buildingName: buildingName ?? json['building_name'] as String?,
      district: json['district'] as String?,
      electricityMeterNumber: json['electricity_meter_number'] as String?,
      waterMeterNumber: json['water_meter_number'] as String?,
    );
  }
}
