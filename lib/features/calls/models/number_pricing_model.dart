class NumberPricingModel {
  final String country;
  final String numberType;
  final double setupFeeCredits;
  final double monthlyFeeCredits;
  final double annualFeeCredits;
  final String currency;

  const NumberPricingModel({
    required this.country,
    required this.numberType,
    required this.setupFeeCredits,
    required this.monthlyFeeCredits,
    required this.annualFeeCredits,
    required this.currency,
  });

  factory NumberPricingModel.fromJson(Map<String, dynamic> json) {
    return NumberPricingModel(
      country: json['country']?.toString() ?? '',
      numberType: json['numberType']?.toString() ?? 'local',
      setupFeeCredits: (json['setupFeeCredits'] as num?)?.toDouble() ?? 0,
      monthlyFeeCredits: (json['monthlyFeeCredits'] as num?)?.toDouble() ?? 0,
      annualFeeCredits: (json['annualFeeCredits'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'CREDITS',
    );
  }

  double totalForPlan(String plan) {
    final subscriptionFee = plan.toLowerCase() == 'annual'
        ? annualFeeCredits
        : monthlyFeeCredits;
    return setupFeeCredits + subscriptionFee;
  }
}
