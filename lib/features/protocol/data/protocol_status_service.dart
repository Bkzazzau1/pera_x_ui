import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class ProtocolStatusModel {
  final String protocolName;
  final String tokenSymbol;
  final String network;
  final String programId;
  final int totalSupply;
  final int decimals;
  final String utilityAppUrl;
  final bool tradingCompanyLockedAccountConfigured;
  final bool tradingCompanyRevenueAccountConfigured;
  final String burnExecutionMode;
  final double immediateBurnPercentage;
  final double monthlySellCapPercentage;
  final String status;
  final String note;

  const ProtocolStatusModel({
    required this.protocolName,
    required this.tokenSymbol,
    required this.network,
    required this.programId,
    required this.totalSupply,
    required this.decimals,
    required this.utilityAppUrl,
    required this.tradingCompanyLockedAccountConfigured,
    required this.tradingCompanyRevenueAccountConfigured,
    required this.burnExecutionMode,
    required this.immediateBurnPercentage,
    required this.monthlySellCapPercentage,
    required this.status,
    required this.note,
  });

  factory ProtocolStatusModel.fromJson(Map<String, dynamic> json) {
    return ProtocolStatusModel(
      protocolName: json['protocolName']?.toString() ?? 'Pera-X',
      tokenSymbol: json['tokenSymbol']?.toString() ?? 'PEX',
      network: json['network']?.toString() ?? 'unknown',
      programId: json['programId']?.toString() ?? '',
      totalSupply: (json['totalSupply'] as num?)?.toInt() ?? 0,
      decimals: (json['decimals'] as num?)?.toInt() ?? 0,
      utilityAppUrl: json['utilityAppUrl']?.toString() ?? '',
      tradingCompanyLockedAccountConfigured:
          json['tradingCompanyLockedAccountConfigured'] == true,
      tradingCompanyRevenueAccountConfigured:
          json['tradingCompanyRevenueAccountConfigured'] == true,
      burnExecutionMode: json['burnExecutionMode']?.toString() ?? 'manual',
      immediateBurnPercentage:
          (json['immediateBurnPercentage'] as num?)?.toDouble() ?? 0,
      monthlySellCapPercentage:
          (json['monthlySellCapPercentage'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'unknown',
      note: json['note']?.toString() ?? '',
    );
  }

  factory ProtocolStatusModel.mock() {
    return const ProtocolStatusModel(
      protocolName: 'Pera-X',
      tokenSymbol: 'PEX',
      network: 'solana-devnet',
      programId: 'FqEiSx5vujh2vi3yk12NaZMXhjMSaKovGUuzcKiAgshn',
      totalSupply: 1000000000,
      decimals: 6,
      utilityAppUrl: 'https://app.pera-x.xyz',
      tradingCompanyLockedAccountConfigured: true,
      tradingCompanyRevenueAccountConfigured: true,
      burnExecutionMode: 'manual',
      immediateBurnPercentage: 10,
      monthlySellCapPercentage: 50,
      status: 'configured',
      note: 'Mock protocol status for frontend preview.',
    );
  }
}

class ProtocolStatusService {
  final ApiClient _apiClient;

  ProtocolStatusService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ProtocolStatusModel> fetchStatus() async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return ProtocolStatusModel.mock();
    }

    final response = await _apiClient.get('/protocol/status');
    return ProtocolStatusModel.fromJson(response as Map<String, dynamic>);
  }
}
