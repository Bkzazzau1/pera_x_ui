import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pera_x_ui/shared/widgets/glass_card.dart';

import '../../app/theme.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    // Premium Ambient Engine: Pulsing background that drives the "Living UI"
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/ai-lab')) return 1;
    if (location.startsWith('/pera-x/calls')) return 2;
    if (location.startsWith('/bills')) return 3;
    if (location.startsWith('/wallet')) return 4;
    if (location.startsWith('/credits')) return 5;
    if (location.startsWith('/market')) return 6;
    if (location.startsWith('/checkout')) return 7;
    return 0;
  }

  void _goToTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/ai-lab');
        break;
      case 2:
        context.go('/pera-x/calls');
        break;
      case 3:
        context.go('/bills');
        break;
      case 4:
        context.go('/wallet');
        break;
      case 5:
        context.go('/credits');
        break;
      case 6:
        context.go('/market');
        break;
      case 7:
        context.go('/checkout');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      backgroundColor: PeraXColors.darkBlue,
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. The Living Radial Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.5 * _ambientController.value,
                        -0.5 * _ambientController.value,
                      ),
                      radius: 1.5,
                      colors: const [Color(0xFF0052D4), PeraXColors.darkBlue],
                    ),
                  ),
                ),
              ),

              // 2. The Exceptional Pera-X Neural Mesh Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: NeuralBackgroundPainter(
                    animationValue: _ambientController.value,
                  ),
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;
                  if (isDesktop) {
                    return Row(
                      children: [
                        _DesktopSidebar(
                          currentIndex: currentIndex,
                          onSelected: (index) => _goToTab(context, index),
                        ),
                        Expanded(child: widget.child),
                      ],
                    );
                  }
                  return Stack(
                    children: [
                      widget.child,
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _MobileBottomNav(
                          currentIndex: currentIndex,
                          onSelected: (index) => _goToTab(context, index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Exceptional Geometric Pattern inspired by neural nodes and circuit traces
class NeuralBackgroundPainter extends CustomPainter {
  final double animationValue;

  NeuralBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PeraXColors.cyan
          .withValues(alpha: 0.04) // Subtle institutional aesthetic
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final spacing = 44.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        // Breathing offset to simulate a living L1 ledger
        final offset = 5 * animationValue;

        if ((i / spacing).toInt() % 2 == 0) {
          canvas.drawCircle(Offset(i + offset, j + offset), 1.2, paint);
          canvas.drawLine(
            Offset(i + offset, j + offset),
            Offset(i + spacing + offset, j + spacing + offset),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(NeuralBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _DesktopSidebar({required this.currentIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: PeraXColors.surfaceBlue.withValues(alpha: 0.8),
        border: const Border(
          right: BorderSide(color: PeraXColors.glassBorder, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandHeader(),
          const SizedBox(height: 48),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SidebarItem(
                      icon: item.icon,
                      label: item.label,
                      isActive: currentIndex == index,
                      onTap: () => onSelected(index),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _NetworkStatusWidget(),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: PeraXColors.cyan,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: PeraXColors.cyan.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'PEX',
              style: TextStyle(
                color: PeraXColors.darkBlue,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Cleaned Header: "FINTECH 2050" removed per Request
        const Text(
          'Pera-X',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? PeraXColors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: PeraXColors.cyan.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? PeraXColors.darkBlue : Colors.white60,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isActive ? PeraXColors.darkBlue : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: PeraXColors.cyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Network Healthy',
                style: TextStyle(
                  color: PeraXColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Solana L1 Protocol',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const Text(
            '1,248 TPS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 85,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: PeraXColors.surfaceBlue.withValues(alpha: 0.7),
            border: const Border(
              top: BorderSide(color: PeraXColors.glassBorder, width: 0.5),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: PeraXColors.cyan.withValues(alpha: 0.2),
              destinations: _navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.outlinedIcon, color: Colors.white38),
                      selectedIcon: Icon(item.icon, color: PeraXColors.cyan),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon, outlinedIcon;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.outlinedIcon,
  });
}

const _navItems = [
  _NavItem(
    label: 'Home',
    icon: Icons.dashboard_rounded,
    outlinedIcon: Icons.dashboard_outlined,
  ),
  _NavItem(
    label: 'AI Lab',
    icon: Icons.auto_awesome_rounded,
    outlinedIcon: Icons.auto_awesome_outlined,
  ),
  _NavItem(
    label: 'Calls',
    icon: Icons.call_rounded,
    outlinedIcon: Icons.call_outlined,
  ),
  _NavItem(
    label: 'Bills',
    icon: Icons.receipt_long_rounded,
    outlinedIcon: Icons.receipt_long_outlined,
  ),
  _NavItem(
    label: 'Wallet',
    icon: Icons.account_balance_wallet_rounded,
    outlinedIcon: Icons.account_balance_wallet_outlined,
  ),
  _NavItem(
    label: 'Buy Credits',
    icon: Icons.add_card_rounded,
    outlinedIcon: Icons.add_card_outlined,
  ),
  _NavItem(
    label: 'Market',
    icon: Icons.shopping_bag_rounded,
    outlinedIcon: Icons.shopping_bag_outlined,
  ),
  _NavItem(
    label: 'Checkout',
    icon: Icons.payments_rounded,
    outlinedIcon: Icons.payments_outlined,
  ),
];
