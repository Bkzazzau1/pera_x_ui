import 'package:flutter/material.dart';

import '../data/call_service.dart';
import '../models/call_destination_model.dart';
import '../models/recent_call_model.dart';

class CallController extends ChangeNotifier {
  final CallService service;

  CallController({CallService? service}) : service = service ?? CallService();

  bool isLoading = false;
  bool isInternational = false;

  double creditBalance = 0.00;
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

  int get estimatedMinutes {
    if (selectedDestination.ratePerMinute <= 0) return 0;
    return (creditBalance / selectedDestination.ratePerMinute).floor();
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    creditBalance = await service.getCreditBalance();
    localDestinations = await service.getLocalDestinations();
    internationalDestinations = await service.getInternationalDestinations();
    recentCalls = await service.getRecentCalls();

    selectedDestination = localDestinations.first;
    phoneNumber = '${selectedDestination.code} ';

    isLoading = false;
    notifyListeners();
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
      ratePerMinute: selectedDestination.ratePerMinute,
      creditBalance: creditBalance,
    );

    if (!response.accepted) {
      lastError = response.message;
      notifyListeners();
      return false;
    }

    activeCall = response;
    notifyListeners();
    return true;
  }
}
