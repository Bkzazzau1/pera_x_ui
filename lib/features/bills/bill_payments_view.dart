import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state/checkout_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../market/models/product.dart';
import '../market/state/market_provider.dart';

class BillPaymentsView extends ConsumerWidget {
  const BillPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final billProducts = products
        .where((product) => product.category == 'Bill Credits')
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _BillsHeader(
                  onEligibleCountrySelected: () {
                    ref.read(checkoutCountryCodeProvider.notifier).state = 'NG';
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              sliver: billProducts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: GlassCard(
                        padding: EdgeInsets.all(18),
                        radius: 28,
                        child: Text(
                          'Bill payment products are not available yet.',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    )
                  : SliverList.separated(
                      itemCount: billProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final product = billProducts[index];
                        return _BillProductCard(
                          product: product,
                          onPay: () {
                            ref.read(checkoutCountryCodeProvider.notifier).state =
                                'NG';
                            ref.read(selectedProductProvider.notifier).state =
                                product;
                            context.go('/checkout');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillsHeader extends StatelessWidget {
  final VoidCallback onEligibleCountrySelected;

  const _BillsHeader({required this.onEligibleCountrySelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bill Payments',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pay data, airtime, electricity, TV, and internet bills in eligible countries. Use card, stablecoin, eligible-country VA, or Pera-X for discounts.',
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 22),
        _EligibleCountrySelector(onSelected: onEligibleCountrySelected),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(18),
          radius: 28,
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: PeraXColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PeraXColors.glassBorder),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: PeraXColors.cyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Bill payment rails are enabled only for eligible countries, while checkout remains Pera-X branded and payment-method flexible.',
                  style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EligibleCountrySelector extends StatelessWidget {
  final VoidCallback onSelected;

  const _EligibleCountrySelector({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eligible Country',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bill products and VA payment are shown only where rails are available.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onSelected,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PeraXColors.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PeraXColors.cyan.withValues(alpha: 0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.public_rounded, color: PeraXColors.cyan),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Eligible Country',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.check_circle_rounded, color: PeraXColors.cyan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onPay;

  const _BillProductCard({required this.product, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 32,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: PeraXColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: PeraXColors.glassBorder),
            ),
            child: Icon(product.icon, color: PeraXColors.cyan, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pay normally or use Pera-X for discount and rewards.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: PeraXColors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onPay,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: PeraXColors.cyan,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  color: PeraXColors.darkBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
