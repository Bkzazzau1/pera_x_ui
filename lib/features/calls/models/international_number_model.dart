class InternationalNumberModel {
  final String country;
  final String flag;
  final String code;
  final String sampleNumber;
  final double setupFeePex;
  final double monthlyFeePex;
  final List<String> capabilities;
  final bool popular;

  const InternationalNumberModel({
    required this.country,
    required this.flag,
    required this.code,
    required this.sampleNumber,
    required this.setupFeePex,
    required this.monthlyFeePex,
    required this.capabilities,
    this.popular = false,
  });

  double get firstMonthTotal => setupFeePex + monthlyFeePex;
}
