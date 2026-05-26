import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import 'admin_auth_service.dart';

class AdminUtilityPrice {
  final String serviceCode;
  final String serviceName;
  final String category;
  final double creditCost;
  final String billingUnit;
  final bool isActive;

  const AdminUtilityPrice({
    required this.serviceCode,
    required this.serviceName,
    required this.category,
    required this.creditCost,
    required this.billingUnit,
    required this.isActive,
  });

  factory AdminUtilityPrice.fromJson(Map<String, dynamic> json) {
    return AdminUtilityPrice(
      serviceCode: json['serviceCode']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      billingUnit: json['billingUnit']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }
}

class AdminCreditRate {
  final String assetCode;
  final String assetName;
  final double creditsPerUnit;
  final String unitLabel;
  final bool isActive;

  const AdminCreditRate({
    required this.assetCode,
    required this.assetName,
    required this.creditsPerUnit,
    required this.unitLabel,
    required this.isActive,
  });

  factory AdminCreditRate.fromJson(Map<String, dynamic> json) {
    return AdminCreditRate(
      assetCode: json['assetCode']?.toString() ?? '',
      assetName: json['assetName']?.toString() ?? '',
      creditsPerUnit: (json['creditsPerUnit'] as num?)?.toDouble() ?? 0,
      unitLabel: json['unitLabel']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }
}

class AdminNumberPrice {
  final String id;
  final String country;
  final String numberType;
  final double setupFeeCredits;
  final double monthlyFeeCredits;
  final double annualFeeCredits;
  final String currency;
  final bool isActive;

  const AdminNumberPrice({
    required this.id,
    required this.country,
    required this.numberType,
    required this.setupFeeCredits,
    required this.monthlyFeeCredits,
    required this.annualFeeCredits,
    required this.currency,
    required this.isActive,
  });

  factory AdminNumberPrice.fromJson(Map<String, dynamic> json) {
    return AdminNumberPrice(
      id: json['id']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      numberType: json['numberType']?.toString() ?? '',
      setupFeeCredits: (json['setupFeeCredits'] as num?)?.toDouble() ?? 0,
      monthlyFeeCredits: (json['monthlyFeeCredits'] as num?)?.toDouble() ?? 0,
      annualFeeCredits: (json['annualFeeCredits'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'CREDITS',
      isActive: json['isActive'] == true,
    );
  }
}

class AdminPricingSnapshot {
  final List<AdminUtilityPrice> utilities;
  final List<AdminCreditRate> creditRates;
  final List<AdminNumberPrice> numberPrices;

  const AdminPricingSnapshot({
    required this.utilities,
    required this.creditRates,
    required this.numberPrices,
  });
}

class AdminPricingService {
  final ApiClient _apiClient;
  final http.Client _http;

  AdminPricingService({ApiClient? apiClient, http.Client? httpClient})
      : _apiClient = apiClient ?? ApiClient(),
        _http = httpClient ?? http.Client();

  String _requiredToken() {
    final token = AdminAuthService.token;
    if (token == null || token.isEmpty) {
      throw Exception('Admin session expired. Please login again.');
    }
    return token;
  }

  Future<AdminPricingSnapshot> getSnapshot() async {
    final token = _requiredToken();
    final responses = await Future.wait([
      _apiClient.get('/admin/api/pricing/utilities', token: token),
      _apiClient.get('/admin/api/pricing/credit-rates', token: token),
      _apiClient.get('/admin/api/telecom/number-pricing', token: token),
    ]);

    final utilitiesPayload = responses[0] as Map<String, dynamic>;
    final ratesPayload = responses[1] as Map<String, dynamic>;
    final numberPayload = responses[2] as Map<String, dynamic>;

    return AdminPricingSnapshot(
      utilities: (utilitiesPayload['pricing'] as List? ?? const [])
          .map((item) => AdminUtilityPrice.fromJson(item as Map<String, dynamic>))
          .toList(),
      creditRates: (ratesPayload['rates'] as List? ?? const [])
          .map((item) => AdminCreditRate.fromJson(item as Map<String, dynamic>))
          .toList(),
      numberPrices: (numberPayload['pricing'] as List? ?? const [])
          .map((item) => AdminNumberPrice.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> updateUtilityPrice({
    required String serviceCode,
    required double creditCost,
  }) async {
    await _patch('/admin/api/pricing/utilities/$serviceCode', {
      'creditCost': creditCost,
    });
  }

  Future<void> updateCreditRate({
    required String assetCode,
    required double creditsPerUnit,
  }) async {
    await _patch('/admin/api/pricing/credit-rates/$assetCode', {
      'creditsPerUnit': creditsPerUnit,
    });
  }

  Future<void> updateNumberPrice({
    required String id,
    required double setupFeeCredits,
    required double monthlyFeeCredits,
    required double annualFeeCredits,
  }) async {
    await _patch('/admin/api/telecom/number-pricing/$id', {
      'setupFeeCredits': setupFeeCredits,
      'monthlyFeeCredits': monthlyFeeCredits,
      'annualFeeCredits': annualFeeCredits,
    });
  }

  Future<void> _patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final token = _requiredToken();
    final response = await _http.patch(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(AppConfig.apiTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body.isEmpty ? 'Admin update failed.' : response.body);
    }
  }
}
