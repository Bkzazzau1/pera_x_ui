import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state/service_providers.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import 'models/product.dart';
import 'state/market_provider.dart';

class MarketView extends ConsumerStatefulWidget {
  const MarketView({super.key});

  @override
  ConsumerState<MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends ConsumerState<MarketView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kineticController;

  List<Product>? _serviceProducts;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();

    _kineticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    Future.microtask(_loadProductsFromService);
  }

  Future<void> _loadProductsFromService() async {
    if (!mounted) return;

    setState(() => _isLoadingProducts = true);

    try {
      final productService = ref.read(productServiceProvider);
      final products = await productService.fetchProducts();

      if (!mounted) return;

      setState(() {
        _serviceProducts = products;
        _isLoadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoadingProducts = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to refresh products. Showing local catalog.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _kineticController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final fallbackProducts = ref.watch(productsProvider);
    final products = _serviceProducts ?? fallbackProducts;

    final categories = const [
      ('AI Credits', Icons.auto_awesome_outlined),
      ('Call Credits', Icons.call_outlined),
      ('SMS Units', Icons.sms_outlined),
      ('Website Credits', Icons.language_outlined),
      ('Bill Credits', Icons.receipt_long_outlined),
    ];

    final visibleProducts = products
        .where((product) => product.category == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProductsFromService,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _MarketHeader(
                    selectedCategory: selectedCategory,
                    categories: categories,
                    isLoadingProducts: _isLoadingProducts,
                    onCategorySelected: (value) {
                      ref.read(selectedCategoryProvider.notifier).state = value;
                    },
                  ),
                ),
              ),
              if (visibleProducts.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 120),
                  sliver: SliverToBoxAdapter(
                    child: GlassCard(
                      padding: EdgeInsets.all(18),
                      radius: 28,
                      child: Text(
                        'No service credits available in this category yet.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  sliver: SliverGrid.builder(
                    itemCount: visibleProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 330,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      final product = visibleProducts[index];

                      return _KineticProductCard(
                        product: product,
                        pulse: _kineticController,
                        onBuy: () {
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
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  final String selectedCategory;
  final List<(String, IconData)> categories;
  final bool isLoadingProducts;
  final ValueChanged<String> onCategorySelected;

  const _MarketHeader({
    required this.selectedCategory,
    required this.categories,
    required this.isLoadingProducts,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Credits',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Convert PEX into AI, call, SMS, website, and utility bill credits.',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),
            if (isLoadingProducts)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: PeraXColors.cyan,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
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
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isActive
                        ? PeraXColors.cyan
                        : PeraXColors.surfaceBlue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isActive
                          ? Colors.white24
                          : PeraXColors.glassBorder,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(
                          category.$2,
                          size: 18,
                          color: isActive ? PeraXColors.darkBlue : Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          category.$1,
                          style: TextStyle(
                            color: isActive
                                ? PeraXColors.darkBlue
                                : Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
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

class _KineticProductCard extends StatefulWidget {
  final Product product;
  final Animation<double> pulse;
  final VoidCallback onBuy;

  const _KineticProductCard({
    required this.product,
    required this.pulse,
    required this.onBuy,
  });

  @override
  State<_KineticProductCard> createState() => _KineticProductCardState();
}

class _KineticProductCardState extends State<_KineticProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          radius: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: widget.pulse,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PeraXColors.cyan.withValues(
                                  alpha: 0.1 + (widget.pulse.value * 0.1),
                                ),
                                const Color(0xFF0052D4).withValues(alpha: 0.2),
                              ],
                            ),
                            border: Border.all(
                              color: PeraXColors.cyan.withValues(
                                alpha: 0.05 + (widget.pulse.value * 0.1),
                              ),
                            ),
                          ),
                          child: Icon(
                            widget.product.icon,
                            size: 58,
                            color: PeraXColors.cyan,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PeraXColors.darkBlue.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.view_in_ar_rounded,
                          size: 16,
                          color: PeraXColors.cyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white38,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.bolt, color: Colors.orange, size: 14),
                  Text(
                    '${(widget.product.pexPrice / 0.1).toInt()} PEX',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '\$${widget.product.pexPrice.toStringAsFixed(2)} with PEX',
                style: const TextStyle(
                  color: PeraXColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.onBuy,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: PeraXColors.cyan,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: PeraXColors.cyan.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'CONVERT TO CREDITS',
                      style: TextStyle(
                        color: PeraXColors.darkBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
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
