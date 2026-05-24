import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final payWithPexProvider = StateProvider<bool>((ref) => false);

final checkoutShippingProvider = Provider<double>((ref) => 5.00);

final checkoutDiscountProvider = Provider<double>((ref) {
  final payWithPex = ref.watch(payWithPexProvider);

  if (!payWithPex) return 0;

  return 0.10;
});
