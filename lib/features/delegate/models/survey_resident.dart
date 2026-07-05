class SurveyResident {
  const SurveyResident({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
      };

  factory SurveyResident.fromJson(Map<String, dynamic> json) {
    return SurveyResident(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'تابع',
    );
  }
}
