import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_lab/data/ai_service.dart';
import '../../features/checkout/data/checkout_service.dart';
import '../../features/market/data/product_service.dart';
import '../../features/pricing/data/pricing_service.dart';
import '../../features/wallet/data/wallet_service.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final pricingServiceProvider = Provider<PricingService>((ref) {
  return PricingService();
});

final utilityPricingProvider = FutureProvider<List<UtilityPriceModel>>((ref) {
  return ref.read(pricingServiceProvider).getUtilityPricing();
});

final creditExchangeRatesProvider = FutureProvider<List<CreditExchangeRateModel>>((ref) {
  return ref.read(pricingServiceProvider).getCreditExchangeRates();
});

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService();
});