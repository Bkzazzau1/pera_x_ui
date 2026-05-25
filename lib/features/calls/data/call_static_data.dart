import '../models/call_destination_model.dart';
import '../models/international_number_model.dart';
import '../models/recent_call_model.dart';

class CallStaticData {
  CallStaticData._();

  static const List<CallDestinationModel> localDestinations = [
    CallDestinationModel(
      country: 'Nigeria',
      flag: '🇳🇬',
      code: '+234',
      ratePerMinute: 0.12,
      isLocal: true,
    ),
  ];

  static const List<CallDestinationModel> internationalDestinations = [
    CallDestinationModel(
      country: 'United States',
      flag: '🇺🇸',
      code: '+1',
      ratePerMinute: 0.45,
      isLocal: false,
    ),
    CallDestinationModel(
      country: 'United Kingdom',
      flag: '🇬🇧',
      code: '+44',
      ratePerMinute: 0.55,
      isLocal: false,
    ),
    CallDestinationModel(
      country: 'Saudi Arabia',
      flag: '🇸🇦',
      code: '+966',
      ratePerMinute: 0.65,
      isLocal: false,
    ),
    CallDestinationModel(
      country: 'India',
      flag: '🇮🇳',
      code: '+91',
      ratePerMinute: 0.25,
      isLocal: false,
    ),
    CallDestinationModel(
      country: 'Ghana',
      flag: '🇬🇭',
      code: '+233',
      ratePerMinute: 0.30,
      isLocal: false,
    ),
    CallDestinationModel(
      country: 'Kenya',
      flag: '🇰🇪',
      code: '+254',
      ratePerMinute: 0.32,
      isLocal: false,
    ),
  ];

  static const List<RecentCallModel> recentCalls = [
    RecentCallModel(
      name: 'Utility Provider',
      number: '+234 700 100 2000',
      time: '12 min ago',
      isLocal: true,
    ),
  ];

  static final List<Map<String, dynamic>> callHistory = [
    {
      'name': 'Utility Provider',
      'number': '+234 700 100 2000',
      'type': 'outgoing',
      'status': 'completed',
      'destination': 'Nigeria',
      'duration': '03:24',
      'charge': 0.41,
      'time': 'Today, 10:24',
      'isLocal': true,
    },
  ];

  static final List<Map<String, dynamic>> creditPackages = [
    {'credits': 25, 'price': 5, 'label': 'Starter'},
    {'credits': 75, 'price': 15, 'label': 'Everyday'},
    {'credits': 150, 'price': 30, 'label': 'Business'},
  ];

  static const List<InternationalNumberModel> internationalNumbers = [
    InternationalNumberModel(
      country: 'United States',
      flag: '🇺🇸',
      code: '+1',
      sampleNumber: '+1 415 555 0198',
      setupFeeCredit: 18,
      monthlyFeeCredit: 42,
      capabilities: ['Voice', 'SMS', 'Caller ID'],
      popular: true,
    ),
    InternationalNumberModel(
      country: 'United Kingdom',
      flag: '🇬🇧',
      code: '+44',
      sampleNumber: '+44 20 7946 0821',
      setupFeeCredit: 22,
      monthlyFeeCredit: 48,
      capabilities: ['Voice', 'SMS', 'Business ID'],
    ),
    InternationalNumberModel(
      country: 'Canada',
      flag: '🇨🇦',
      code: '+1',
      sampleNumber: '+1 647 555 0142',
      setupFeeCredit: 18,
      monthlyFeeCredit: 40,
      capabilities: ['Voice', 'SMS', 'Forwarding'],
    ),
    InternationalNumberModel(
      country: 'Ghana',
      flag: '🇬🇭',
      code: '+233',
      sampleNumber: '+233 30 555 0184',
      setupFeeCredit: 14,
      monthlyFeeCredit: 32,
      capabilities: ['Voice', 'Caller ID', 'Forwarding'],
    ),
  ];

  static const List<String> paymentMethods = [
    'Pera-X Wallet',
    'USDC',
    'Bank Transfer',
  ];
}
