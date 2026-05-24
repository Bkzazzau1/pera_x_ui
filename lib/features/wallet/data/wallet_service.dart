import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class WalletSummaryDto {
  final double sol;
  final double usdc;
  final double pex;
  final double pexUsdRate;
  final double burnedPex;

  const WalletSummaryDto({
    required this.sol,
    required this.usdc,
    required this.pex,
    required this.pexUsdRate,
    required this.burnedPex,
  });

  double get pexUsdValue => pex * pexUsdRate;

  factory WalletSummaryDto.fromJson(Map<String, dynamic> json) {
    return WalletSummaryDto(
      sol: (json['sol'] as num?)?.toDouble() ?? 0,
      usdc: (json['usdc'] as num?)?.toDouble() ?? 0,
      pex: (json['PEX'] as num?)?.toDouble() ?? 0,
      pexUsdRate: (json['pexUsdRate'] as num?)?.toDouble() ?? 0.10,
      burnedPex: (json['burnedPex'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SwapQuoteDto {
  final String fromAsset;
  final String toAsset;
  final double inputAmount;
  final double outputAmount;
  final double rate;

  const SwapQuoteDto({
    required this.fromAsset,
    required this.toAsset,
    required this.inputAmount,
    required this.outputAmount,
    required this.rate,
  });

  factory SwapQuoteDto.fromJson(Map<String, dynamic> json) {
    return SwapQuoteDto(
      fromAsset: json['fromAsset']?.toString() ?? 'SOL',
      toAsset: json['toAsset']?.toString() ?? 'PEX',
      inputAmount: (json['inputAmount'] as num?)?.toDouble() ?? 0,
      outputAmount: (json['outputAmount'] as num?)?.toDouble() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WalletService {
  final ApiClient _apiClient;

  WalletService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<WalletSummaryDto> fetchWalletSummary() async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 350));

      return const WalletSummaryDto(
        sol: 12.45,
        usdc: 850.00,
        pex: 24850,
        pexUsdRate: 0.10,
        burnedPex: 120430,
      );
    }

    final response = await _apiClient.get('/wallet/summary');

    return WalletSummaryDto.fromJson(response as Map<String, dynamic>);
  }

  Future<SwapQuoteDto> getSwapQuote({
    required String fromAsset,
    required String toAsset,
    required double amount,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final rate = fromAsset == 'SOL' && toAsset == 'PEX' ? 2000.0 : 1 / 2000.0;

      return SwapQuoteDto(
        fromAsset: fromAsset,
        toAsset: toAsset,
        inputAmount: amount,
        outputAmount: amount * rate,
        rate: rate,
      );
    }

    final response = await _apiClient.get(
      '/wallet/swap/quote',
      queryParameters: {
        'fromAsset': fromAsset,
        'toAsset': toAsset,
        'amount': amount,
      },
    );

    return SwapQuoteDto.fromJson(response as Map<String, dynamic>);
  }

  Future<void> executeSwap({
    required String fromAsset,
    required String toAsset,
    required double amount,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return;
    }

    await _apiClient.post(
      '/wallet/swap',
      body: {'fromAsset': fromAsset, 'toAsset': toAsset, 'amount': amount},
    );
  }
}
