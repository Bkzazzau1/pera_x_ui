import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../core/storage/local_storage.dart';
import '../../shared/widgets/glass_card.dart';
import '../market/models/product.dart';
import '../market/state/market_provider.dart';
import '../wallet/state/wallet_provider.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _introBalanceAnimation;

  Timer? _activityTimer;
  int _activityIndex = 0;
  bool _showPwaPrompt = true;

  static const double _introBalanceTarget = 24850;
  static const String _pwaDismissedKey = 'pera_x_pwa_prompt_dismissed';

  @override
  void initState() {
    super.initState();

    _showPwaPrompt = !LocalStorage.getBool(_pwaDismissedKey);

    // Premium Intro Engine: Drives the numerical count-up and background pulse
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _introBalanceAnimation = Tween<double>(
      begin: 0,
      end: _introBalanceTarget,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Dynamic Activity Rotation: Simulates a live data stream
    _activityTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _activityIndex++;
      });
    });
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismissPwaPrompt() async {
    setState(() => _showPwaPrompt = false);
    await LocalStorage.setBool(_pwaDismissedKey, true);
  }

  String _formatNumber(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final activities = ref.watch(recentTransactionsProvider);
    final utilityScore = ref.watch(utilityScoreProvider);
    final todayBurned = ref.watch(todayBurnedPexProvider);
    final todayAiSpend = ref.watch(todayAiSpendProvider);

    final products = ref.watch(productsProvider);
    final featuredProduct = products.isNotEmpty ? products.first : null;

    final rotatingActivity = activities.isEmpty
        ? null
        : activities[_activityIndex % activities.length];

    return Scaffold(
      backgroundColor: PeraXColors.darkBlue,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final balanceToShow = _controller.isCompleted
              ? wallet.pex
              : _introBalanceAnimation.value;

          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  0.7 - (_controller.value * 0.2),
                  -0.6 + (_controller.value * 0.2),
                ),
                radius: 1.5,
                colors: const [Color(0xFF0052D4), PeraXColors.darkBlue],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    if (_showPwaPrompt) ...[
                      const SizedBox(height: 16),
                      _PwaInstallPrompt(onDismiss: _dismissPwaPrompt),
                    ],
                    const SizedBox(height: 28),
                    _TokenBalanceCard(
                      balance: _formatNumber(balanceToShow),
                      usdValue: wallet.pexUsdValue,
                      burnedPex: wallet.burnedPex,
                    ),
                    const SizedBox(height: 24),
                    _DashboardInsightGrid(
                      utilityScore: utilityScore,
                      todayAiSpend: todayAiSpend,
                      todayBurned: todayBurned,
                      totalActivities: activities.length,
                    ),
                    const SizedBox(height: 32),
                    const _QuickActionSection(),
                    const SizedBox(height: 32),
                    _FeaturedMarketSlot(product: featuredProduct),
                    const SizedBox(height: 24),
                    _ActivityLiveTicker(activity: rotatingActivity),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- CORE DASHBOARD COMPONENTS ---

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Operator',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Command Center',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          radius: 18,
          child: const Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: PeraXColors.cyan),
              SizedBox(width: 8),
              Text(
                '1,200 TPS',
                style: TextStyle(
                  color: PeraXColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TokenBalanceCard extends StatelessWidget {
  final String balance;
  final double usdValue, burnedPex;

  const _TokenBalanceCard({
    required this.balance,
    required this.usdValue,
    required this.burnedPex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          colors: [PeraXColors.cyan, Color(0xFF0052D4)],
        ),
        boxShadow: [
          BoxShadow(
            color: PeraXColors.cyan.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GlassCard(
        radius: 34,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PEX HOLDINGS (SOLANA L1)',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$balance PEX',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '≈ \$${usdValue.toStringAsFixed(2)} USD',
              style: const TextStyle(
                color: PeraXColors.cyan,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _MiniStat(
                  title: 'Network',
                  value: 'Healthy',
                  icon: Icons.wifi_tethering,
                ),
                const SizedBox(width: 14),
                _MiniStat(
                  title: 'Burned',
                  value: '${burnedPex.toInt()} PEX',
                  icon: Icons.local_fire_department,
                  isAlert: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final bool isAlert;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.icon,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PeraXColors.darkBlue.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: PeraXColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isAlert ? Colors.orange : PeraXColors.cyan,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardInsightGrid extends StatelessWidget {
  final int utilityScore, totalActivities;
  final double todayAiSpend, todayBurned;

  const _DashboardInsightGrid({
    required this.utilityScore,
    required this.todayAiSpend,
    required this.todayBurned,
    required this.totalActivities,
  });

  @override
  Widget build(BuildContext context) {
    final insights = [
      ('Utility', '$utilityScore/100', Icons.speed),
      ('AI Credits', '${todayAiSpend.toInt()} PEX', Icons.auto_awesome),
      (
        'Ecosystem Burn',
        '${todayBurned.toInt()} PEX',
        Icons.local_fire_department,
      ),
      ('Transactions', '$totalActivities', Icons.timeline),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final item = insights[index];
        return GlassCard(
          padding: const EdgeInsets.all(14),
          radius: 24,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PeraXColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.$3, color: PeraXColors.cyan, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection();

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('AI Lab', Icons.document_scanner, '/ai-lab', true),
      ('Calls', Icons.call, '/pera-x/calls', false),
      (
        'Global Number',
        Icons.sim_card_rounded,
        '/pera-x/calls/buy-international-number',
        false,
      ),
      ('Asset Hub', Icons.account_balance_wallet, '/wallet', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK OPERATIONS',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _ActionButton(
              title: action.$1,
              icon: action.$2,
              route: action.$3,
              isPrimary: action.$4,
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String title, route;
  final IconData icon;
  final bool isPrimary;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.route,
    required this.isPrimary,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(widget.route),
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? PeraXColors.cyan
                : PeraXColors.surfaceBlue.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: PeraXColors.cyan.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? PeraXColors.darkBlue : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isPrimary ? PeraXColors.darkBlue : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- LIVE DATA TICKERS ---

class _ActivityLiveTicker extends StatelessWidget {
  final AppTransaction? activity;

  const _ActivityLiveTicker({required this.activity});

  @override
  Widget build(BuildContext context) {
    final message = activity == null
        ? '🔥 Monitoring PEX Ecosystem Activity...'
        : activity!.activityMessage;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: GlassCard(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        radius: 24,
        child: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.orange, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: PeraXColors.cyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PwaInstallPrompt extends StatelessWidget {
  final VoidCallback onDismiss;

  const _PwaInstallPrompt({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 28,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PeraXColors.cyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: PeraXColors.cyan, size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade Interface',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Add to Home Screen for better experience.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }
}

class _FeaturedMarketSlot extends ConsumerWidget {
  final Product? product;

  const _FeaturedMarketSlot({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SERVICE CREDIT FEATURE',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            ref.read(selectedProductProvider.notifier).state = product;
            context.go('/checkout');
          },
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            radius: 32,
            child: Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PeraXColors.cyan.withValues(alpha: 0.3),
                        const Color(0xFF0052D4).withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(product!.icon, color: PeraXColors.cyan, size: 36),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${product!.pexPrice.toStringAsFixed(2)} service value in PEX.',
                        style: const TextStyle(
                          color: PeraXColors.cyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
