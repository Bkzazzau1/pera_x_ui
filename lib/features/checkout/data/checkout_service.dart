import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class CheckoutResultDto {
  final String orderId;
  final String status;
  final double burnedPex;

  const CheckoutResultDto({
    required this.orderId,
    required this.status,
    required this.burnedPex,
  });

  factory CheckoutResultDto.fromJson(Map<String, dynamic> json) {
    return CheckoutResultDto(
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      burnedPex: (json['burnedPex'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CheckoutService {
  final ApiClient _apiClient;

  CheckoutService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<CheckoutResultDto> confirmOrder({
    required String productId,
    required String productName,
    required double totalUsd,
    required bool payWithPex,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      return CheckoutResultDto(
        orderId: 'demo_order_${DateTime.now().millisecondsSinceEpoch}',
        status: 'confirmed',
        burnedPex: payWithPex ? 20 : 0,
      );
    }

    final response = await _apiClient.post(
      '/checkout/confirm',
      body: {
        'productId': productId,
        'productName': productName,
        'totalUsd': totalUsd,
        'payWithPex': payWithPex,
      },
    );

    return CheckoutResultDto.fromJson(response as Map<String, dynamic>);
  }
}
