import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Product>> fetchProducts() async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 350));

      return const [
        Product(
          id: 'ai-credit-pack',
          name: 'AI Document Tools Pack',
          category: 'AI Credits',
          price: 15.00,
          pexPrice: 15.00,
          icon: Icons.psychology_alt_outlined,
        ),
        Product(
          id: 'call-credit-pack',
          name: 'App-to-Phone Call Credit',
          category: 'Call Credits',
          price: 10.00,
          pexPrice: 10.00,
          icon: Icons.call_outlined,
        ),
        Product(
          id: 'sms-bundle',
          name: 'SMS Unit Bundle',
          category: 'SMS Units',
          price: 8.00,
          pexPrice: 8.00,
          icon: Icons.sms_outlined,
        ),
        Product(
          id: 'website-builder',
          name: 'AI Website Builder Credits',
          category: 'Website Credits',
          price: 25.00,
          pexPrice: 25.00,
          icon: Icons.language_outlined,
        ),
        Product(
          id: 'utility-bill-credit',
          name: 'Utility Bill Credit',
          category: 'Bill Credits',
          price: 30.00,
          pexPrice: 27.00,
          icon: Icons.receipt_long_outlined,
        ),
      ];
    }

    final response = await _apiClient.get('/products');

    final list = response as List<dynamic>;

    return list.map((item) {
      final json = item as Map<String, dynamic>;

      return Product(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        pexPrice: (json['pexPrice'] as num?)?.toDouble() ?? 0,
        icon: _iconFromKey(json['icon']?.toString()),
      );
    }).toList();
  }

  IconData _iconFromKey(String? key) {
    switch (key) {
      case 'ev_station':
        return Icons.ev_station;
      case 'sms':
        return Icons.sms_outlined;
      case 'language':
        return Icons.language_outlined;
      case 'receipt':
        return Icons.receipt_long_outlined;
      case 'psychology':
        return Icons.psychology_alt_outlined;
      case 'electric_bolt':
      default:
        return Icons.electric_bolt;
    }
  }
}
