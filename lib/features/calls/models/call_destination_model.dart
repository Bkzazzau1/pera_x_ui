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

  CallDestinationModel copyWith({
    String? country,
    String? flag,
    String? code,
    double? ratePerMinute,
    bool? isLocal,
  }) {
    return CallDestinationModel(
      country: country ?? this.country,
      flag: flag ?? this.flag,
      code: code ?? this.code,
      ratePerMinute: ratePerMinute ?? this.ratePerMinute,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  String get displayRate {
    return '${ratePerMinute.toStringAsFixed(2)} Credits/min';
  }
}
