import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/product.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'AI Credits');

final productsProvider = Provider<List<Product>>((ref) {
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
});

final selectedProductProvider = StateProvider<Product?>((ref) {
  final products = ref.read(productsProvider);
  return products.first;
});
