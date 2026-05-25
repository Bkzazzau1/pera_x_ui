import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class CheckoutResultDto {
  final String orderId;
  final String status;
  final double creditCost;
  final double remainingCredits;

  const CheckoutResultDto({
    required this.orderId,
    required this.status,
    required this.creditCost,
    required this.remainingCredits,
  });

  factory CheckoutResultDto.fromJson(Map<String, dynamic> json) {
    return CheckoutResultDto(
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      remainingCredits: (json['remainingCredits'] as num?)?.toDouble() ?? 0,
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
    required double creditCost,
    required double creditBalance,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      return CheckoutResultDto(
        orderId: 'demo_order_${DateTime.now().millisecondsSinceEpoch}',
        status: creditBalance >= creditCost ? 'confirmed' : 'rejected',
        creditCost: creditCost,
        remainingCredits: creditBalance - creditCost,
      );
    }

    final response = await _apiClient.post(
      '/checkout/confirm',
      body: {
        'productId': productId,
        'productName': productName,
        'creditCost': creditCost,
        'creditBalance': creditBalance,
      },
    );

    return CheckoutResultDto.fromJson(response as Map<String, dynamic>);
  }
}
