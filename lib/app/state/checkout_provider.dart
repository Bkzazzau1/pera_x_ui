import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/checkout/models/payment_method.dart';

final checkoutCountryCodeProvider = StateProvider<String>((ref) => 'NG');

final selectedPaymentMethodProvider = StateProvider<PaymentMethodType>(
  (ref) => PaymentMethodType.pexToken,
);

final availablePaymentMethodsProvider = Provider<List<PaymentMethodType>>((ref) {
  final countryCode = ref.watch(checkoutCountryCodeProvider);
  return availablePaymentMethods(countryCode: countryCode);
});

final payWithPexProvider = Provider<bool>((ref) {
  return ref.watch(selectedPaymentMethodProvider) == PaymentMethodType.pexToken;
});

final checkoutShippingProvider = Provider<double>((ref) => 5.00);

final checkoutDiscountProvider = Provider<double>((ref) {
  final paymentMethod = ref.watch(selectedPaymentMethodProvider);

  if (!paymentMethod.earnsPexDiscount) return 0;

  return 0.10;
});
