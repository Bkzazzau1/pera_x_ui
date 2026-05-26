import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state/checkout_provider.dart';
import '../../app/state/service_providers.dart';
import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../features/checkout/models/order_status.dart';
import '../../features/checkout/models/payment_method.dart';
import '../../features/checkout/widgets/order_status_timeline.dart';
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
  double creditsSpent = 0;
  double remainingCredits = 0;

  Future<void> _confirmOrder(Product product) async {
    if (isConfirming) return;

    final wallet = ref.read(walletProvider);
    final serviceFee = ref.read(checkoutShippingProvider);
    final discountRate = ref.read(checkoutDiscountProvider);

    final subtotal = product.price + serviceFee;
    final discount = subtotal * discountRate;
    final totalCredits = subtotal - discount;

    if (wallet.credits < totalCredits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Insufficient Credits. Buy Credits before paying for this service.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/credits');
      return;
    }

    setState(() => isConfirming = true);

    try {
      final checkoutService = ref.read(checkoutServiceProvider);

      final result = await checkoutService.confirmOrder(
        productId: product.id,
        productName: product.name,
        creditCost: totalCredits,
        creditBalance: wallet.credits,
      );

      if (!mounted) return;

      if (result.status != 'confirmed') {
        setState(() => isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout was not confirmed. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ref.read(walletProvider.notifier).spendCredits(result.creditCost);

      ref
          .read(transactionProvider.notifier)
          .addPurchase(
            productName: product.name,
            amountUsd: result.creditCost,
            paidWithPex: false,
          );

      ref
          .read(transactionProvider.notifier)
          .addCheckout(
            productName: product.name,
            amountUsd: result.creditCost,
            paidWithPex: false,
          );

      setState(() {
        creditsSpent = result.creditCost;
        remainingCredits = result.remainingCredits;
        orderConfirmed = true;
        isConfirming = false;
      });
    } catch (error) {
      if (!mounted) return;

      ref.read(walletProvider.notifier).spendCredits(totalCredits);
      ref
          .read(transactionProvider.notifier)
          .addPurchase(
            productName: product.name,
            amountUsd: totalCredits,
            paidWithPex: false,
          );
      ref
          .read(transactionProvider.notifier)
          .addCheckout(
            productName: product.name,
            amountUsd: totalCredits,
            paidWithPex: false,
          );

      setState(() {
        creditsSpent = totalCredits;
        remainingCredits = wallet.credits - totalCredits;
        orderConfirmed = true;
        isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = ref.watch(selectedProductProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final serviceFee = ref.watch(checkoutShippingProvider);
    final discountRate = ref.watch(checkoutDiscountProvider);
    final wallet = ref.watch(walletProvider);

    if (selectedProduct == null) {
      return const Scaffold(
        backgroundColor: PeraXColors.darkBlue,
        body: Center(
          child: Text(
            'No service selected.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final subtotal = selectedProduct.price + serviceFee;
    final discount = subtotal * discountRate;
    final totalCredits = subtotal - discount;
    final hasEnoughCredits = wallet.credits >= totalCredits;

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
                    creditsSpent: creditsSpent,
                    remainingCredits: remainingCredits,
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
                        'Services are paid with Credits. Buy Credits using PEX, card, stablecoin, or eligible-country VA.',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 26),
                      _ProductSummary(product: selectedProduct),
                      const SizedBox(height: 20),
                      _PaymentSummary(
                        basePrice: selectedProduct.price,
                        serviceFee: serviceFee,
                        discount: discount,
                        total: totalCredits,
                      ),
                      const SizedBox(height: 20),
                      _CreditBalanceCard(
                        creditBalance: wallet.credits,
                        totalCredits: totalCredits,
                        hasEnoughCredits: hasEnoughCredits,
                      ),
                      const SizedBox(height: 20),
                      _FundingReminder(method: selectedPaymentMethod),
                      const SizedBox(height: 20),
                      const OrderStatusTimeline(
                        activeStep: OrderStatusStep.awaitingPayment,
                      ),
                      const SizedBox(height: 24),
                      _ConfirmButton(
                        isLoading: isConfirming,
                        label: hasEnoughCredits
                            ? 'PAY WITH CREDITS'
                            : 'BUY CREDITS FIRST',
                        onPressed: hasEnoughCredits
                            ? () => _confirmOrder(selectedProduct)
                            : () => context.go('/credits'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
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
                  '${product.category} • Credits service activation',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product.price.toStringAsFixed(0)} Credits',
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
  final double serviceFee;
  final double discount;
  final double total;

  const _PaymentSummary({
    required this.basePrice,
    required this.serviceFee,
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
            label: 'Service Cost',
            value: '${basePrice.toStringAsFixed(0)} Credits',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Platform Fee',
            value: '${serviceFee.toStringAsFixed(0)} Credits',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Pera-X Discount',
            value: '-${discount.toStringAsFixed(0)} Credits',
            highlight: discount > 0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: PeraXColors.glassBorder),
          ),
          _PriceRow(
            label: 'Total Credits',
            value: '${total.toStringAsFixed(0)} Credits',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _CreditBalanceCard extends StatelessWidget {
  final double creditBalance;
  final double totalCredits;
  final bool hasEnoughCredits;

  const _CreditBalanceCard({
    required this.creditBalance,
    required this.totalCredits,
    required this.hasEnoughCredits,
  });

  @override
  Widget build(BuildContext context) {
    final afterPayment = creditBalance - totalCredits;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 28,
      child: Row(
        children: [
          Icon(
            hasEnoughCredits ? Icons.verified_rounded : Icons.warning_rounded,
            color: hasEnoughCredits ? PeraXColors.cyan : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEnoughCredits
                      ? 'Credit Balance Ready'
                      : 'Insufficient Credits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEnoughCredits
                      ? 'After payment: ${afterPayment.toStringAsFixed(0)} Credits'
                      : 'You need ${(totalCredits - creditBalance).toStringAsFixed(0)} more Credits.',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${creditBalance.toStringAsFixed(0)} Credits',
            style: const TextStyle(
              color: PeraXColors.cyan,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FundingReminder extends StatelessWidget {
  final PaymentMethodType method;

  const _FundingReminder({required this.method});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 28,
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: PeraXColors.cyan,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Need more balance? Buy Credits with ${method.title}, then return here to pay for the service.',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.4,
              ),
            ),
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
  final double creditsSpent;
  final double remainingCredits;

  const _SuccessView({
    required this.creditsSpent,
    required this.remainingCredits,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          GlassCard(
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
                  'Service Activated!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${creditsSpent.toStringAsFixed(0)} Credits spent',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${remainingCredits.toStringAsFixed(0)} CREDITS REMAINING',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PeraXColors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Credits were deducted for this service. Settlement, provider payment, buyback, burn, and liquidity support are handled automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const OrderStatusTimeline(activeStep: OrderStatusStep.delivered),
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
    );
  }
}
