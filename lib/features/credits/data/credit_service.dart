import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

enum CreditFundingMethodDto {
  pex('pex'),
  card('card'),
  stablecoin('stablecoin'),
  virtualAccount('virtual_account');

  final String apiValue;

  const CreditFundingMethodDto(this.apiValue);
}

class BuyCreditsResultDto {
  final bool accepted;
  final String method;
  final double creditAmount;
  final double pexRequired;
  final double? remainingPex;
  final String status;
  final String message;

  const BuyCreditsResultDto({
    required this.accepted,
    required this.method,
    required this.creditAmount,
    required this.pexRequired,
    required this.remainingPex,
    required this.status,
    required this.message,
  });

  factory BuyCreditsResultDto.fromJson(Map<String, dynamic> json) {
    return BuyCreditsResultDto(
      accepted: json['accepted'] == true,
      method: json['method']?.toString() ?? '',
      creditAmount: (json['creditAmount'] as num?)?.toDouble() ?? 0,
      pexRequired: (json['pexRequired'] as num?)?.toDouble() ?? 0,
      remainingPex: (json['remainingPex'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class CreditService {
  final ApiClient _apiClient;

  CreditService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<BuyCreditsResultDto> buyCredits({
    required CreditFundingMethodDto method,
    required double creditAmount,
    double? pexBalance,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      return BuyCreditsResultDto(
        accepted: true,
        method: method.apiValue,
        creditAmount: creditAmount,
        pexRequired: method == CreditFundingMethodDto.pex ? creditAmount : 0,
        remainingPex: pexBalance == null
            ? null
            : pexBalance - (method == CreditFundingMethodDto.pex ? creditAmount : 0),
        status: 'pending_settlement',
        message: 'Credit purchase request accepted.',
      );
    }

    final response = await _apiClient.post(
      '/credits/buy',
      body: {
        'method': method.apiValue,
        'creditAmount': creditAmount,
        'pexBalance': pexBalance,
      },
    );

    return BuyCreditsResultDto.fromJson(response as Map<String, dynamic>);
  }
}
