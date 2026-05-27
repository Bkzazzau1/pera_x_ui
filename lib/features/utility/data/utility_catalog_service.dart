import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class UtilityCatalogModel {
  final String title;
  final String description;
  final List<UtilityServiceModel> services;

  const UtilityCatalogModel({
    required this.title,
    required this.description,
    required this.services,
  });

  factory UtilityCatalogModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    return UtilityCatalogModel(
      title: json['title']?.toString() ?? 'Pera-X Utility Services',
      description: json['description']?.toString() ?? '',
      services: rawServices is List
          ? rawServices
              .whereType<Map<String, dynamic>>()
              .map(UtilityServiceModel.fromJson)
              .toList()
          : const [],
    );
  }

  factory UtilityCatalogModel.mock() {
    return const UtilityCatalogModel(
      title: 'Pera-X Utility Services',
      description:
          'Service catalog for the Pera-X app. Users spend Credits on supported utilities while PEX remains the ecosystem asset.',
      services: [
        UtilityServiceModel(
          code: 'AI_LAB',
          name: 'AI Lab',
          category: 'AI Tools',
          description:
              'AI detection, plagiarism checks, humanizer tools, document intelligence, and future AI services.',
          route: '/ai-lab',
          creditUnit: 'AI Credits',
          status: 'active',
        ),
        UtilityServiceModel(
          code: 'CALLS',
          name: 'International Calls',
          category: 'Communication',
          description:
              'App-to-phone calls where receivers do not need the Pera-X app or internet access.',
          route: '/pera-x/calls',
          creditUnit: 'Call Credits',
          status: 'active',
        ),
        UtilityServiceModel(
          code: 'SMS',
          name: 'SMS Messaging',
          category: 'Communication',
          description:
              'Personal SMS, OTP, bulk messaging, alerts, campaigns, and developer SMS APIs.',
          route: '/pera-x/sms-inbox',
          creditUnit: 'SMS Units',
          status: 'active',
        ),
        UtilityServiceModel(
          code: 'NUMBERS',
          name: 'Foreign Numbers',
          category: 'Communication',
          description:
              'Buy, manage, renew, cancel, and reactivate international phone numbers.',
          route: '/pera-x/buy-number',
          creditUnit: 'Number Credits',
          status: 'active',
        ),
        UtilityServiceModel(
          code: 'BILLS',
          name: 'Bills Payment',
          category: 'Utilities',
          description:
              'Electricity, TV, internet, water, waste, institutional bills, and other approved bill payments.',
          route: '/bills',
          creditUnit: 'Bill Credits',
          status: 'planned',
        ),
        UtilityServiceModel(
          code: 'WEB_TOOLS',
          name: 'Website Tools',
          category: 'Web Services',
          description:
              'AI-generated websites, landing pages, and build-credit tools for small businesses and creators.',
          route: '/market',
          creditUnit: 'Build Credits',
          status: 'planned',
        ),
      ],
    );
  }
}

class UtilityServiceModel {
  final String code;
  final String name;
  final String category;
  final String description;
  final String route;
  final String creditUnit;
  final String status;

  const UtilityServiceModel({
    required this.code,
    required this.name,
    required this.category,
    required this.description,
    required this.route,
    required this.creditUnit,
    required this.status,
  });

  factory UtilityServiceModel.fromJson(Map<String, dynamic> json) {
    return UtilityServiceModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      route: json['route']?.toString() ?? '/dashboard',
      creditUnit: json['creditUnit']?.toString() ?? 'Credits',
      status: json['status']?.toString() ?? 'planned',
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}

class UtilityCatalogService {
  final ApiClient _apiClient;

  UtilityCatalogService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<UtilityCatalogModel> fetchCatalog() async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return UtilityCatalogModel.mock();
    }

    final response = await _apiClient.get('/utility/catalog');
    return UtilityCatalogModel.fromJson(response as Map<String, dynamic>);
  }
}
