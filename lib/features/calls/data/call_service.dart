import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../models/call_destination_model.dart';
import '../models/international_number_model.dart';
import '../models/my_number_model.dart';
import '../models/number_pricing_model.dart';
import '../models/recent_call_model.dart';
import '../models/sms_message_model.dart';
import 'call_static_data.dart';

class StartCallResultDto {
  final String callId;
  final String status;
  final String phoneNumber;
  final String destination;
  final double ratePerMinute;
  final double creditBalance;
  final int estimatedMinutes;
  final double reservedCredits;
  final String message;

  const StartCallResultDto({
    required this.callId,
    required this.status,
    required this.phoneNumber,
    required this.destination,
    required this.ratePerMinute,
    required this.creditBalance,
    required this.estimatedMinutes,
    required this.reservedCredits,
    required this.message,
  });

  bool get accepted => status == 'accepted';

  factory StartCallResultDto.fromJson(Map<String, dynamic> json) {
    return StartCallResultDto(
      callId: json['callId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'rejected',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      ratePerMinute: (json['ratePerMinute'] as num?)?.toDouble() ?? 0,
      creditBalance: (json['creditBalance'] as num?)?.toDouble() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
      reservedCredits: (json['reservedCredits'] as num?)?.toDouble() ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}

class EndCallResultDto {
  final String callId;
  final String status;
  final int durationSeconds;
  final double creditCost;
  final double remainingCredits;
  final String message;

  const EndCallResultDto({
    required this.callId,
    required this.status,
    required this.durationSeconds,
    required this.creditCost,
    required this.remainingCredits,
    required this.message,
  });

  bool get completed => status == 'completed';

  factory EndCallResultDto.fromJson(Map<String, dynamic> json) {
    return EndCallResultDto(
      callId: json['callId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'rejected',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      remainingCredits: (json['remainingCredits'] as num?)?.toDouble() ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}

class ReserveNumberResultDto {
  final String orderId;
  final String phoneNumber;
  final String country;
  final String plan;
  final String status;
  final double creditCost;
  final double setupFeeCredits;
  final double monthlyFeeCredits;
  final DateTime? nextRenewalAt;
  final double remainingCredits;
  final String message;

  const ReserveNumberResultDto({
    required this.orderId,
    required this.phoneNumber,
    required this.country,
    required this.plan,
    required this.status,
    required this.creditCost,
    required this.setupFeeCredits,
    required this.monthlyFeeCredits,
    required this.remainingCredits,
    required this.message,
    this.nextRenewalAt,
  });

  bool get reserved => status == 'reserved';

  factory ReserveNumberResultDto.fromJson(Map<String, dynamic> json) {
    return ReserveNumberResultDto(
      orderId: json['orderId']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
      status: json['status']?.toString() ?? 'rejected',
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      setupFeeCredits: (json['setupFeeCredits'] as num?)?.toDouble() ?? 0,
      monthlyFeeCredits: (json['monthlyFeeCredits'] as num?)?.toDouble() ?? 0,
      nextRenewalAt:
          DateTime.tryParse(json['nextRenewalAt']?.toString() ?? ''),
      remainingCredits: (json['remainingCredits'] as num?)?.toDouble() ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}

class NumberSubscriptionActionDto {
  final String id;
  final String phoneNumber;
  final String status;
  final String billingStatus;
  final double? monthlyFeeCredits;
  final DateTime? nextRenewalAt;
  final String message;

  const NumberSubscriptionActionDto({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.billingStatus,
    required this.message,
    this.monthlyFeeCredits,
    this.nextRenewalAt,
  });

  factory NumberSubscriptionActionDto.fromJson(Map<String, dynamic> json) {
    return NumberSubscriptionActionDto(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      billingStatus: json['billingStatus']?.toString() ?? '',
      monthlyFeeCredits: (json['monthlyFeeCredits'] as num?)?.toDouble(),
      nextRenewalAt:
          DateTime.tryParse(json['nextRenewalAt']?.toString() ?? ''),
      message: json['message']?.toString() ?? '',
    );
  }
}

class CallService {
  final ApiClient _apiClient;

  CallService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<double> getCreditBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 125.00;
  }

  Future<List<CallDestinationModel>> getLocalDestinations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return CallStaticData.localDestinations;
  }

  Future<List<CallDestinationModel>> getInternationalDestinations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return CallStaticData.internationalDestinations;
  }

  Future<List<RecentCallModel>> getRecentCalls() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return CallStaticData.recentCalls;
  }

  Future<List<Map<String, dynamic>>> getCallHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CallStaticData.callHistory;
  }

  Future<List<Map<String, dynamic>>> getCreditPackages() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return CallStaticData.creditPackages;
  }

  Future<List<String>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return CallStaticData.paymentMethods;
  }

  Future<List<InternationalNumberModel>> getInternationalNumbers() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return CallStaticData.internationalNumbers;
  }

  Future<List<NumberPricingModel>> getNumberPricing() async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 350));
      return const [
        NumberPricingModel(
          country: 'United States',
          numberType: 'local',
          setupFeeCredits: 10,
          monthlyFeeCredits: 30,
          annualFeeCredits: 300,
          currency: 'CREDITS',
        ),
        NumberPricingModel(
          country: 'United Kingdom',
          numberType: 'local',
          setupFeeCredits: 10,
          monthlyFeeCredits: 35,
          annualFeeCredits: 350,
          currency: 'CREDITS',
        ),
        NumberPricingModel(
          country: 'Canada',
          numberType: 'local',
          setupFeeCredits: 10,
          monthlyFeeCredits: 30,
          annualFeeCredits: 300,
          currency: 'CREDITS',
        ),
      ];
    }

    final response = await _apiClient.get('/telecom/numbers/pricing');
    final payload = response as Map<String, dynamic>;
    final pricing = payload['pricing'] as List? ?? const [];

    return pricing
        .map((item) => NumberPricingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<MyNumberModel>> getMyNumbers() async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 450));
      return [
        MyNumberModel(
          id: 'demo_number_1',
          phoneNumber: '+14155550198',
          country: 'United States',
          plan: 'Monthly',
          status: 'reserved',
          monthlyFeeCredits: 30,
          nextRenewalAt: DateTime.now().add(const Duration(days: 22)),
          billingStatus: 'active',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
    }

    final response = await _apiClient.get('/telecom/numbers/mine');
    final payload = response as Map<String, dynamic>;
    final numbers = payload['numbers'] as List? ?? const [];

    return numbers
        .map((item) => MyNumberModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<NumberSubscriptionActionDto> cancelNumberSubscription({
    required String numberId,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return NumberSubscriptionActionDto(
        id: numberId,
        phoneNumber: '+14155550198',
        status: 'cancelled',
        billingStatus: 'cancelled',
        monthlyFeeCredits: 30,
        message: 'Number subscription cancelled. Renewal billing has stopped.',
      );
    }

    final response = await _apiClient.post(
      '/telecom/numbers/$numberId/cancel',
      body: const {},
    );

    return NumberSubscriptionActionDto.fromJson(response as Map<String, dynamic>);
  }

  Future<NumberSubscriptionActionDto> reactivateNumberSubscription({
    required String numberId,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return NumberSubscriptionActionDto(
        id: numberId,
        phoneNumber: '+14155550198',
        status: 'reserved',
        billingStatus: 'active',
        monthlyFeeCredits: 30,
        nextRenewalAt: DateTime.now().add(const Duration(days: 30)),
        message: 'Number subscription reactivated.',
      );
    }

    final response = await _apiClient.post(
      '/telecom/numbers/$numberId/reactivate',
      body: const {},
    );

    return NumberSubscriptionActionDto.fromJson(response as Map<String, dynamic>);
  }

  Future<List<SmsMessageModel>> getSmsInbox({
    required String phoneNumber,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 450));
      return [
        SmsMessageModel(
          id: 'demo_sms_1',
          phoneNumber: phoneNumber,
          sender: '+447700900123',
          body: 'Welcome to your Pera-X global number inbox.',
          receivedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ];
    }

    final encodedNumber = Uri.encodeQueryComponent(phoneNumber);
    final response = await _apiClient.get(
      '/telecom/sms/inbox?phoneNumber=$encodedNumber',
    );

    final payload = response as Map<String, dynamic>;
    final messages = payload['messages'] as List? ?? const [];

    return messages
        .map((item) => SmsMessageModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> createCreditPurchaseRequest({
    required int creditAmount,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return true;
  }

  Future<ReserveNumberResultDto> purchaseInternationalNumber({
    required String country,
    required String number,
    required String plan,
    required double creditBalance,
    String numberType = 'local',
  }) async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 650));
      final pricing = (await getNumberPricing()).firstWhere(
        (item) => item.country == country && item.numberType == numberType,
        orElse: () => const NumberPricingModel(
          country: 'Default',
          numberType: 'local',
          setupFeeCredits: 10,
          monthlyFeeCredits: 30,
          annualFeeCredits: 300,
          currency: 'CREDITS',
        ),
      );
      final creditCost = pricing.totalForPlan(plan);
      final reserved = creditBalance >= creditCost;

      return ReserveNumberResultDto(
        orderId: 'demo_num_order_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: number,
        country: country,
        plan: plan,
        status: reserved ? 'reserved' : 'rejected',
        creditCost: reserved ? creditCost : 0,
        setupFeeCredits: pricing.setupFeeCredits,
        monthlyFeeCredits: pricing.monthlyFeeCredits,
        nextRenewalAt: DateTime.now().add(
          Duration(days: plan.toLowerCase() == 'annual' ? 365 : 30),
        ),
        remainingCredits: creditBalance - creditCost,
        message: reserved
            ? 'Global number reservation accepted. The number is a recurring subscription.'
            : 'Global number reservation rejected. Insufficient Credits.',
      );
    }

    final response = await _apiClient.post(
      '/telecom/numbers/reserve',
      body: {
        'country': country,
        'phoneNumber': number,
        'plan': plan,
        'creditBalance': creditBalance,
        'numberType': numberType,
      },
    );

    return ReserveNumberResultDto.fromJson(response as Map<String, dynamic>);
  }

  Future<StartCallResultDto> startCallSession({
    required String phoneNumber,
    required String destination,
    required bool isInternational,
    required double ratePerMinute,
    required double creditBalance,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final accepted = creditBalance >= ratePerMinute;

      return StartCallResultDto(
        callId: 'demo_call_${DateTime.now().millisecondsSinceEpoch}',
        status: accepted ? 'accepted' : 'rejected',
        phoneNumber: phoneNumber,
        destination: destination,
        ratePerMinute: ratePerMinute,
        creditBalance: creditBalance,
        estimatedMinutes: ratePerMinute <= 0
            ? 0
            : (creditBalance / ratePerMinute).floor(),
        reservedCredits: accepted ? ratePerMinute : 0,
        message: accepted
            ? 'Call session accepted. Credits will be charged by duration.'
            : 'Call rejected. Check available Credits.',
      );
    }

    final response = await _apiClient.post(
      '/telecom/calls/start',
      body: {
        'phoneNumber': phoneNumber,
        'destination': destination,
        'isInternational': isInternational,
        'ratePerMinute': ratePerMinute,
        'creditBalance': creditBalance,
      },
    );

    return StartCallResultDto.fromJson(response as Map<String, dynamic>);
  }

  Future<EndCallResultDto> endCallSession({
    required String callId,
    required String phoneNumber,
    required int durationSeconds,
    required double ratePerMinute,
    required double creditBalance,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final billedMinutes = (durationSeconds / 60).ceil().clamp(1, 999999);
      final creditCost = billedMinutes * ratePerMinute;
      final remainingCredits = creditBalance - creditCost;
      final completed = remainingCredits >= 0;

      return EndCallResultDto(
        callId: callId,
        status: completed ? 'completed' : 'rejected',
        durationSeconds: durationSeconds,
        creditCost: completed ? creditCost : 0,
        remainingCredits: remainingCredits,
        message: completed
            ? 'Call completed. Credits deducted by billed duration.'
            : 'Call completion rejected. Insufficient Credits.',
      );
    }

    final response = await _apiClient.post(
      '/telecom/calls/end',
      body: {
        'callId': callId,
        'phoneNumber': phoneNumber,
        'durationSeconds': durationSeconds,
        'ratePerMinute': ratePerMinute,
        'creditBalance': creditBalance,
      },
    );

    return EndCallResultDto.fromJson(response as Map<String, dynamic>);
  }
}
