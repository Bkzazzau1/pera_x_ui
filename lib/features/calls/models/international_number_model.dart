class InternationalNumberModel {
  final String country;
  final String flag;
  final String code;
  final String sampleNumber;
  final double setupFeeCredit;
  final double monthlyFeeCredit;
  final List<String> capabilities;
  final bool popular;

  const InternationalNumberModel({
    required this.country,
    required this.flag,
    required this.code,
    required this.sampleNumber,
    required this.setupFeeCredit,
    required this.monthlyFeeCredit,
    required this.capabilities,
    this.popular = false,
  });

  double get firstMonthTotal => setupFeeCredit + monthlyFeeCredit;
}
