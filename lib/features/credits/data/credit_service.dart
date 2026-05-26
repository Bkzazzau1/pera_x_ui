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
  final String assetCode;
  final double assetRequired;
  final double pexRequired;
  final double? remainingPex;
  final double creditsPerUnit;
  final String status;
  final String message;

  const BuyCreditsResultDto({
    required this.accepted,
    required this.method,
    required this.creditAmount,
    required this.assetCode,
    required this.assetRequired,
    required this.pexRequired,
    required this.remainingPex,
    required this.creditsPerUnit,
    required this.status,
    required this.message,
  });

  factory BuyCreditsResultDto.fromJson(Map<String, dynamic> json) {
    return BuyCreditsResultDto(
      accepted: json['accepted'] == true,
      method: json['method']?.toString() ?? '',
      creditAmount: (json['creditAmount'] as num?)?.toDouble() ?? 0,
      assetCode: json['assetCode']?.toString() ?? '',
      assetRequired: (json['assetRequired'] as num?)?.toDouble() ?? 0,
      pexRequired: (json['pexRequired'] as num?)?.toDouble() ?? 0,
      remainingPex: (json['remainingPex'] as num?)?.toDouble(),
      creditsPerUnit: (json['creditsPerUnit'] as num?)?.toDouble() ?? 0,
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
      const creditsPerUnit = 100.0;
      final assetRequired = creditAmount / creditsPerUnit;
      final isPex = method == CreditFundingMethodDto.pex;
      return BuyCreditsResultDto(
        accepted: true,
        method: method.apiValue,
        creditAmount: creditAmount,
        assetCode: isPex ? 'PEX' : 'FIAT_USD',
        assetRequired: assetRequired,
        pexRequired: isPex ? assetRequired : 0,
        remainingPex: pexBalance == null ? null : pexBalance - (isPex ? assetRequired : 0),
        creditsPerUnit: creditsPerUnit,
        status: 'pending_settlement',
        message: 'Credit purchase request accepted using backend exchange rate.',
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
