class CallDestinationModel {
  final String country;
  final String flag;
  final String code;
  final double ratePerMinute;
  final bool isLocal;

  const CallDestinationModel({
    required this.country,
    required this.flag,
    required this.code,
    required this.ratePerMinute,
    required this.isLocal,
  });

  String get displayRate {
    return '${ratePerMinute.toStringAsFixed(2)} Credits/min';
  }
}
