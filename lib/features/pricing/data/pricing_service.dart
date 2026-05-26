import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class UtilityPriceModel {
  final String serviceCode;
  final String serviceName;
  final String category;
  final double creditCost;
  final String billingUnit;

  const UtilityPriceModel({
    required this.serviceCode,
    required this.serviceName,
    required this.category,
    required this.creditCost,
    required this.billingUnit,
  });

  factory UtilityPriceModel.fromJson(Map<String, dynamic> json) {
    return UtilityPriceModel(
      serviceCode: json['serviceCode']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      billingUnit: json['billingUnit']?.toString() ?? 'per_action',
    );
  }
}

class CreditExchangeRateModel {
  final String assetCode;
  final String assetName;
  final double creditsPerUnit;
  final String unitLabel;

  const CreditExchangeRateModel({
    required this.assetCode,
    required this.assetName,
    required this.creditsPerUnit,
    required this.unitLabel,
  });

  factory CreditExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return CreditExchangeRateModel(
      assetCode: json['assetCode']?.toString() ?? '',
      assetName: json['assetName']?.toString() ?? '',
      creditsPerUnit: (json['creditsPerUnit'] as num?)?.toDouble() ?? 0,
      unitLabel: json['unitLabel']?.toString() ?? '1',
    );
  }
}

class PricingService {
  final ApiClient _apiClient;

  PricingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<UtilityPriceModel>> getUtilityPricing() async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return const [
        UtilityPriceModel(serviceCode: 'ai_detector', serviceName: 'AI Detector', category: 'ai', creditCost: 6, billingUnit: 'per_request'),
        UtilityPriceModel(serviceCode: 'plagiarism_checker', serviceName: 'Plagiarism Checker', category: 'ai', creditCost: 8, billingUnit: 'per_request'),
        UtilityPriceModel(serviceCode: 'humanizer', serviceName: 'Humanizer AI', category: 'ai', creditCost: 10, billingUnit: 'per_request'),
        UtilityPriceModel(serviceCode: 'local_call', serviceName: 'Local Call', category: 'call', creditCost: 1, billingUnit: 'per_minute'),
        UtilityPriceModel(serviceCode: 'global_call', serviceName: 'Global Call', category: 'call', creditCost: 3, billingUnit: 'per_minute'),
        UtilityPriceModel(serviceCode: 'sms_outbound', serviceName: 'Outbound SMS', category: 'sms', creditCost: 0.02, billingUnit: 'per_segment'),
      ];
    }

    final response = await _apiClient.get('/pricing/utilities');
    final payload = response as Map<String, dynamic>;
    final pricing = payload['pricing'] as List? ?? const [];

    return pricing
        .map((item) => UtilityPriceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CreditExchangeRateModel>> getCreditExchangeRates() async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return const [
        CreditExchangeRateModel(assetCode: 'PEX', assetName: 'Pera-X Token', creditsPerUnit: 100, unitLabel: '1 PEX'),
        CreditExchangeRateModel(assetCode: 'USDT', assetName: 'Tether USD', creditsPerUnit: 100, unitLabel: '1 USDT'),
        CreditExchangeRateModel(assetCode: 'USDC', assetName: 'USD Coin', creditsPerUnit: 100, unitLabel: '1 USDC'),
        CreditExchangeRateModel(assetCode: 'FIAT_USD', assetName: 'US Dollar', creditsPerUnit: 100, unitLabel: '1 USD'),
      ];
    }

    final response = await _apiClient.get('/pricing/credit-rates');
    final payload = response as Map<String, dynamic>;
    final rates = payload['rates'] as List? ?? const [];

    return rates
        .map((item) => CreditExchangeRateModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

extension UtilityPricingLookup on List<UtilityPriceModel> {
  double costFor(String serviceCode, double fallback) {
    for (final item in this) {
      if (item.serviceCode == serviceCode) return item.creditCost;
    }
    return fallback;
  }
}
