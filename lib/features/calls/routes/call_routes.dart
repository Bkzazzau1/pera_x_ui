import 'package:flutter/material.dart';

import '../views/active_call_view.dart';
import '../views/buy_international_number_view.dart';
import '../views/call_history_view.dart';
import '../views/call_receipt_view.dart';
import '../views/call_settings_view.dart';
import '../views/pera_x_call_view.dart';

class CallRoutes {
  CallRoutes._();

  static const String callHome = '/pera-x/calls';
  static const String activeCall = '/pera-x/calls/active';
  static const String callReceipt = '/pera-x/calls/receipt';
  static const String callHistory = '/pera-x/calls/history';
  static const String buyCredits = '/credits';
  static const String buyInternationalNumber =
      '/pera-x/calls/buy-international-number';
  static const String settings = '/pera-x/calls/settings';

  static Map<String, WidgetBuilder> routes = {
    callHome: (_) => const PeraXCallView(),
    callHistory: (_) => const CallHistoryView(),
    buyInternationalNumber: (_) => const BuyInternationalNumberView(),
    settings: (_) => const CallSettingsView(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == activeCall) {
      final args = settings.arguments as ActiveCallArgs;

      return MaterialPageRoute(
        builder: (_) => ActiveCallView(
          callId: args.callId,
          phoneNumber: args.phoneNumber,
          destination: args.destination,
          isInternational: args.isInternational,
          ratePerMinute: args.ratePerMinute,
        ),
      );
    }

    if (settings.name == callReceipt) {
      final args = settings.arguments as CallReceiptArgs;

      return MaterialPageRoute(
        builder: (_) => CallReceiptView(
          phoneNumber: args.phoneNumber,
          destination: args.destination,
          duration: args.duration,
          charge: args.charge,
          isInternational: args.isInternational,
        ),
      );
    }

    return null;
  }
}

class ActiveCallArgs {
  final String callId;
  final String phoneNumber;
  final String destination;
  final bool isInternational;
  final double ratePerMinute;

  const ActiveCallArgs({
    required this.callId,
    required this.phoneNumber,
    required this.destination,
    required this.isInternational,
    required this.ratePerMinute,
  });
}

class CallReceiptArgs {
  final String phoneNumber;
  final String destination;
  final String duration;
  final double charge;
  final bool isInternational;

  const CallReceiptArgs({
    required this.phoneNumber,
    required this.destination,
    required this.duration,
    required this.charge,
    required this.isInternational,
  });
}
