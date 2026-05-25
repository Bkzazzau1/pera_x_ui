import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state/checkout_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../market/models/product.dart';
import '../market/state/market_provider.dart';

class BillPaymentsView extends ConsumerStatefulWidget {
  const BillPaymentsView({super.key});

  @override
  ConsumerState<BillPaymentsView> createState() => _BillPaymentsViewState();
}

class _BillPaymentsViewState extends ConsumerState<BillPaymentsView> {
  String selectedBillCategory = 'Data';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final billProducts = products
        .where((product) => product.category == 'Bill Credits')
        .where((product) => _billCategoryFor(product) == selectedBillCategory)
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
                  selectedCategory: selectedBillCategory,
                  onCategorySelected: (category) {
                    setState(() => selectedBillCategory = category);
                  },
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
                          'No bill products are available in this category yet.',
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

String _billCategoryFor(Product product) {
  final id = product.id.toLowerCase();

  if (id.contains('airtime')) return 'Airtime';
  if (id.contains('electricity')) return 'Electricity';
  if (id.contains('tv')) return 'TV';
  if (id.contains('internet')) return 'Internet';
  return 'Data';
}

class _BillsHeader extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onEligibleCountrySelected;

  const _BillsHeader({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onEligibleCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('Data', Icons.signal_cellular_alt_outlined),
      ('Airtime', Icons.phone_android_outlined),
      ('Electricity', Icons.bolt_outlined),
      ('TV', Icons.live_tv_outlined),
      ('Internet', Icons.wifi_outlined),
    ];

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
          'Pay data, airtime, electricity, TV, and internet bills in eligible countries. Buy Credits with PEX, card, stablecoin, or eligible-country VA, then spend Credits on services.',
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
                  'Bill payment rails are enabled only for eligible countries. Checkout remains Pera-X branded, while service spending uses Credits.',
                  style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isActive = selectedCategory == category.$1;

              return GestureDetector(
                onTap: () => onCategorySelected(category.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: isActive
                        ? PeraXColors.cyan
                        : PeraXColors.surfaceBlue.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isActive ? Colors.white24 : PeraXColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.$2,
                        color: isActive ? PeraXColors.darkBlue : Colors.white60,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.$1,
                        style: TextStyle(
                          color: isActive ? PeraXColors.darkBlue : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
                  'Spend Credits for this service. Buy Credits using PEX or other supported payment methods.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  '${product.price.toStringAsFixed(0)} Credits',
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
