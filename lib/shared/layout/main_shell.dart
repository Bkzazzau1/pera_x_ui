import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pera_x_ui/shared/widgets/glass_card.dart';

import '../../app/theme.dart';
import '../../core/config/app_config.dart';

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

  List<_NavItem> get _visibleNavItems {
    return AppConfig.enableAdminPanel ? _adminNavItems : _publicNavItems;
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final navItems = _visibleNavItems;
    final index = navItems.indexWhere((item) => location.startsWith(item.path));
    return index == -1 ? 0 : index;
  }

  void _goToTab(BuildContext context, int index) {
    final navItems = _visibleNavItems;
    if (index < 0 || index >= navItems.length) return;
    context.go(navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final navItems = _visibleNavItems;

    return Scaffold(
      backgroundColor: PeraXColors.darkBlue,
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          return Stack(
            children: [
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
                          navItems: navItems,
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
                          navItems: navItems,
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

class NeuralBackgroundPainter extends CustomPainter {
  final double animationValue;

  NeuralBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PeraXColors.cyan.withValues(alpha: 0.04)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 44.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
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
  final List<_NavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _DesktopSidebar({
    required this.navItems,
    required this.currentIndex,
    required this.onSelected,
  });

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
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _StatusDot(),
              SizedBox(width: 10),
              Text(
                'Protocol Synced',
                style: TextStyle(
                  color: PeraXColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Backend Source of Truth',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          Text(
            'Credits + Contract Status',
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

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: PeraXColors.cyan,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _MobileBottomNav({
    required this.navItems,
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
              destinations: navItems
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
  final String path;
  final IconData icon, outlinedIcon;

  const _NavItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.outlinedIcon,
  });
}

const _publicNavItems = [
  _NavItem(
    label: 'Home',
    path: '/dashboard',
    icon: Icons.dashboard_rounded,
    outlinedIcon: Icons.dashboard_outlined,
  ),
  _NavItem(
    label: 'Protocol',
    path: '/protocol',
    icon: Icons.verified_rounded,
    outlinedIcon: Icons.verified_outlined,
  ),
  _NavItem(
    label: 'AI Lab',
    path: '/ai-lab',
    icon: Icons.auto_awesome_rounded,
    outlinedIcon: Icons.auto_awesome_outlined,
  ),
  _NavItem(
    label: 'Calls',
    path: '/pera-x/calls',
    icon: Icons.call_rounded,
    outlinedIcon: Icons.call_outlined,
  ),
  _NavItem(
    label: 'Bills',
    path: '/bills',
    icon: Icons.receipt_long_rounded,
    outlinedIcon: Icons.receipt_long_outlined,
  ),
  _NavItem(
    label: 'Wallet',
    path: '/wallet',
    icon: Icons.account_balance_wallet_rounded,
    outlinedIcon: Icons.account_balance_wallet_outlined,
  ),
  _NavItem(
    label: 'Buy Credits',
    path: '/credits',
    icon: Icons.add_card_rounded,
    outlinedIcon: Icons.add_card_outlined,
  ),
  _NavItem(
    label: 'Market',
    path: '/market',
    icon: Icons.shopping_bag_rounded,
    outlinedIcon: Icons.shopping_bag_outlined,
  ),
  _NavItem(
    label: 'Checkout',
    path: '/checkout',
    icon: Icons.payments_rounded,
    outlinedIcon: Icons.payments_outlined,
  ),
];

const _adminNavItems = [
  ..._publicNavItems,
  _NavItem(
    label: 'Admin',
    path: '/admin-pricing',
    icon: Icons.admin_panel_settings_rounded,
    outlinedIcon: Icons.admin_panel_settings_outlined,
  ),
];
