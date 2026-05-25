import '../models/call_destination_model.dart';
import '../models/international_number_model.dart';
import '../models/recent_call_model.dart';
import 'call_static_data.dart';

class CallService {
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

  Future<bool> createCreditPurchaseRequest({
    required int creditAmount,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return true;
  }

  Future<bool> purchaseInternationalNumber({
    required String country,
    required String number,
    required String plan,
    required double creditAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));

    return true;
  }

  Future<bool> startCallSession({
    required String phoneNumber,
    required String destination,
    required bool isInternational,
    required double ratePerMinute,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return true;
  }

  Future<bool> endCallSession({
    required String phoneNumber,
    required String duration,
    required double charge,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return true;
  }
}
