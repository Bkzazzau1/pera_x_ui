import 'package:flutter/material.dart';

import '../../pricing/data/pricing_service.dart';
import '../data/call_service.dart';
import '../models/call_destination_model.dart';
import '../models/recent_call_model.dart';

class CallController extends ChangeNotifier {
  final CallService service;
  final PricingService pricingService;

  CallController({CallService? service, PricingService? pricingService})
      : service = service ?? CallService(),
        pricingService = pricingService ?? PricingService();

  bool isLoading = false;
  bool isInternational = false;
  bool usingFallbackRates = false;

  double creditBalance = 0.00;
  double localCallRate = 1.00;
  double globalCallRate = 3.00;
  String phoneNumber = '+234 ';
  StartCallResultDto? activeCall;
  String? lastError;

  late CallDestinationModel selectedDestination;

  List<CallDestinationModel> localDestinations = [];
  List<CallDestinationModel> internationalDestinations = [];
  List<RecentCallModel> recentCalls = [];

  List<CallDestinationModel> get currentDestinations {
    return isInternational ? internationalDestinations : localDestinations;
  }

  double get currentAdminRate {
    return isInternational ? globalCallRate : localCallRate;
  }

  int get estimatedMinutes {
    if (currentAdminRate <= 0) return 0;
    return (creditBalance / currentAdminRate).floor();
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    creditBalance = await service.getCreditBalance();
    localDestinations = await service.getLocalDestinations();
    internationalDestinations = await service.getInternationalDestinations();
    recentCalls = await service.getRecentCalls();

    try {
      final prices = await pricingService
          .getUtilityPricing()
          .timeout(const Duration(seconds: 4));
      localCallRate = prices.costFor('local_call', localCallRate);
      globalCallRate = prices.costFor('global_call', globalCallRate);
      usingFallbackRates = false;
    } catch (_) {
      usingFallbackRates = true;
    }

    localDestinations = _applyRate(localDestinations, localCallRate);
    internationalDestinations = _applyRate(internationalDestinations, globalCallRate);

    selectedDestination = localDestinations.first;
    phoneNumber = '${selectedDestination.code} ';

    isLoading = false;
    notifyListeners();
  }

  List<CallDestinationModel> _applyRate(
    List<CallDestinationModel> destinations,
    double rate,
  ) {
    return destinations
        .map((destination) => destination.copyWith(ratePerMinute: rate))
        .toList();
  }

  void syncCreditBalance(double value) {
    creditBalance = value;
    notifyListeners();
  }

  void switchCallMode(bool international) {
    isInternational = international;

    selectedDestination = international
        ? internationalDestinations.first
        : localDestinations.first;

    phoneNumber = '${selectedDestination.code} ';

    notifyListeners();
  }

  void selectDestination(CallDestinationModel destination) {
    selectedDestination = destination;
    phoneNumber = '${destination.code} ';
    notifyListeners();
  }

  void addDigit(String digit) {
    phoneNumber += digit;
    notifyListeners();
  }

  void deleteDigit() {
    if (phoneNumber.isNotEmpty) {
      phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      notifyListeners();
    }
  }

  void useRecentCall(RecentCallModel call) {
    phoneNumber = call.number;
    notifyListeners();
  }

  Future<bool> startCall() async {
    lastError = null;

    final response = await service.startCallSession(
      phoneNumber: phoneNumber.trim(),
      destination: selectedDestination.country,
      isInternational: isInternational,
      ratePerMinute: currentAdminRate,
      creditBalance: creditBalance,
    );

    if (!response.accepted) {
      lastError = response.message;
      notifyListeners();
      return false;
    }

    selectedDestination = selectedDestination.copyWith(
      ratePerMinute: response.ratePerMinute,
    );
    activeCall = response;
    notifyListeners();
    return true;
  }
}
