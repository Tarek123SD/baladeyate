import 'package:baladeyate/features/profile/models/household.dart';

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
