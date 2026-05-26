class MyNumberModel {
  final String id;
  final String phoneNumber;
  final String? country;
  final String? plan;
  final String status;
  final DateTime createdAt;

  const MyNumberModel({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.country,
    this.plan,
  });

  factory MyNumberModel.fromJson(Map<String, dynamic> json) {
    return MyNumberModel(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      country: json['country']?.toString(),
      plan: json['plan']?.toString(),
      status: json['status']?.toString() ?? 'reserved',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
