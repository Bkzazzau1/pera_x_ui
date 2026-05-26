class MyNumberModel {
  final String id;
  final String phoneNumber;
  final String? country;
  final String? plan;
  final String status;
  final double? setupFeeCredits;
  final double? monthlyFeeCredits;
  final DateTime? nextRenewalAt;
  final String? billingStatus;
  final DateTime createdAt;

  const MyNumberModel({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.country,
    this.plan,
    this.setupFeeCredits,
    this.monthlyFeeCredits,
    this.nextRenewalAt,
    this.billingStatus,
  });

  factory MyNumberModel.fromJson(Map<String, dynamic> json) {
    return MyNumberModel(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      country: json['country']?.toString(),
      plan: json['plan']?.toString(),
      status: json['status']?.toString() ?? 'reserved',
      setupFeeCredits: (json['setupFeeCredits'] as num?)?.toDouble(),
      monthlyFeeCredits: (json['monthlyFeeCredits'] as num?)?.toDouble(),
      nextRenewalAt:
          DateTime.tryParse(json['nextRenewalAt']?.toString() ?? ''),
      billingStatus: json['billingStatus']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
