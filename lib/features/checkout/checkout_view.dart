import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state/checkout_provider.dart';
import '../../app/state/service_providers.dart';
import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../features/checkout/models/payment_method.dart';
import '../../features/checkout/widgets/payment_instructions_card.dart';
import '../../features/checkout/widgets/payment_method_selector.dart';
import '../../features/market/models/product.dart';
import '../../features/market/state/market_provider.dart';
import '../../features/wallet/state/wallet_provider.dart';
import '../../shared/widgets/glass_card.dart';

class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  bool orderConfirmed = false;
  bool isConfirming = false;
  double burnedAmount = 0;
  PaymentMethodType? confirmedMethod;

  Future<void> _confirmOrder(
    Product product,
    PaymentMethodType paymentMethod,
  ) async {
    if (isConfirming) return;

    final shipping = ref.read(checkoutShippingProvider);
    final discountRate = ref.read(checkoutDiscountProvider);
    final payWithPex = paymentMethod == PaymentMethodType.pexToken;

    final subtotal = product.price + shipping;
    final discount = subtotal * discountRate;
    final total = subtotal - discount;

    setState(() => isConfirming = true);

    try {
      final checkoutService = ref.read(checkoutServiceProvider);

      final result = await checkoutService.confirmOrder(
        productId: product.id,
        productName: product.name,
        totalUsd: total,
        payWithPex: payWithPex,
      );

      if (!mounted) return;

      final burnAmount = result.burnedPex;

      ref
          .read(transactionProvider.notifier)
          .addPurchase(
            productName: product.name,
            amountUsd: total,
            paidWithPex: payWithPex,
          );

      ref
          .read(transactionProvider.notifier)
          .addCheckout(
            productName: product.name,
            amountUsd: total,
            paidWithPex: payWithPex,
          );

      if (burnAmount > 0) {
        ref.read(walletProvider.notifier).burnPex(burnAmount);

        ref
            .read(transactionProvider.notifier)
            .addBurn(reason: '${product.name} purchase', pexAmount: burnAmount);
      }

      setState(() {
        burnedAmount = burnAmount;
        confirmedMethod = paymentMethod;
        orderConfirmed = true;
        isConfirming = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => isConfirming = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = ref.watch(selectedProductProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final availableMethods = ref.watch(availablePaymentMethodsProvider);
    final shipping = ref.watch(checkoutShippingProvider);
    final discountRate = ref.watch(checkoutDiscountProvider);

    if (selectedProduct == null) {
      return const Scaffold(
        backgroundColor: PeraXColors.darkBlue,
        body: Center(
          child: Text(
            'No service credit selected.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final subtotal = selectedProduct.price + shipping;
    final discount = subtotal * discountRate;
    final total = subtotal - discount;

    return Scaffold(
      backgroundColor: PeraXColors.darkBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFF0052D4), PeraXColors.darkBlue],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: orderConfirmed
                ? _SuccessView(
                    burnedAmount: burnedAmount,
                    paymentMethod: confirmedMethod ?? selectedPaymentMethod,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose how to pay. Pera-X is optional, but gives better discounts and rewards.',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 26),
                      _ProductSummary(product: selectedProduct),
                      const SizedBox(height: 20),
                      _PaymentSummary(
                        basePrice: selectedProduct.price,
                        shipping: shipping,
                        discount: discount,
                        total: total,
                      ),
                      const SizedBox(height: 20),
                      PaymentMethodSelector(
                        methods: availableMethods,
                        selectedMethod: selectedPaymentMethod,
                        onChanged: isConfirming
                            ? (_) {}
                            : (method) {
                                ref
                                    .read(selectedPaymentMethodProvider.notifier)
                                    .state = method;
                              },
                      ),
                      const SizedBox(height: 20),
                      PaymentInstructionsCard(
                        method: selectedPaymentMethod,
                        totalUsd: total,
                      ),
                      const SizedBox(height: 24),
                      _ConfirmButton(
                        isLoading: isConfirming,
                        label: _buttonLabel(selectedPaymentMethod),
                        onPressed: () => _confirmOrder(
                          selectedProduct,
                          selectedPaymentMethod,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _buttonLabel(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.pexToken:
        return 'CONFIRM PEX PAYMENT';
      case PaymentMethodType.stablecoin:
        return 'CONTINUE WITH STABLECOIN';
      case PaymentMethodType.card:
        return 'CONTINUE WITH CARD';
      case PaymentMethodType.virtualAccountNg:
        return 'GENERATE VIRTUAL ACCOUNT';
    }
  }
}

class _ProductSummary extends StatelessWidget {
  final Product product;

  const _ProductSummary({required this.product});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 32,
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  PeraXColors.cyan.withValues(alpha: 0.3),
                  const Color(0xFF0052D4).withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Icon(product.icon, color: PeraXColors.cyan, size: 38),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.category} • service credit activation',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final double basePrice;
  final double shipping;
  final double discount;
  final double total;

  const _PaymentSummary({
    required this.basePrice,
    required this.shipping,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 32,
      child: Column(
        children: [
          _PriceRow(
            label: 'Unit Price',
            value: '\$${basePrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Service Fee',
            value: '\$${shipping.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Pera-X Discount',
            value: '-\$${discount.toStringAsFixed(2)}',
            highlight: discount > 0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: PeraXColors.glassBorder),
          ),
          _PriceRow(
            label: 'Total Payable',
            value: '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white60,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: highlight || isTotal ? PeraXColors.cyan : Colors.white,
            fontSize: isTotal ? 22 : 14,
            fontWeight: FontWeight.w900,
          ),
          child: Text(value),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isLoading ? Colors.white24 : PeraXColors.cyan,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (!isLoading)
              BoxShadow(
                color: PeraXColors.cyan.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: PeraXColors.cyan,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: PeraXColors.darkBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final double burnedAmount;
  final PaymentMethodType paymentMethod;

  const _SuccessView({
    required this.burnedAmount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final hasBurn = burnedAmount > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          radius: 36,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: PeraXColors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: PeraXColors.darkBlue,
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Paid via ${paymentMethod.title}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hasBurn
                    ? '${burnedAmount.toStringAsFixed(0)} PEX BURNED'
                    : 'SERVICE CREDITS ISSUED',
                style: TextStyle(
                  color: hasBurn ? Colors.orange : PeraXColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payment is recorded first. Delivery and policy actions are handled by the utility gateway.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text(
                  'RETURN TO HUB',
                  style: TextStyle(
                    color: PeraXColors.cyan,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
