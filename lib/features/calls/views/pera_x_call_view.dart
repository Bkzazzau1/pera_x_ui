import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../wallet/state/wallet_provider.dart';
import '../controllers/call_controller.dart';
import '../models/call_destination_model.dart';
import '../routes/call_routes.dart';
import '../widgets/call_destination_card.dart';
import '../widgets/call_dial_pad.dart';
import '../widgets/call_mode_selector.dart';
import '../widgets/call_number_display.dart';
import '../widgets/recent_call_tile.dart';

class PeraXCallView extends ConsumerStatefulWidget {
  const PeraXCallView({super.key});

  @override
  ConsumerState<PeraXCallView> createState() => _PeraXCallViewState();
}

class _PeraXCallViewState extends ConsumerState<PeraXCallView> {
  late final CallController controller;
  bool isStartingCall = false;

  @override
  void initState() {
    super.initState();
    controller = CallController();
    controller.addListener(_refresh);
    controller.init().then((_) {
      if (!mounted) return;
      controller.syncCreditBalance(ref.read(walletProvider).credits);
    });
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  controller.isInternational
                      ? 'Choose international destination'
                      : 'Choose local destination',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Select where you want to call. Rates are shown in Credits per minute.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                ...controller.currentDestinations.map((destination) {
                  final active =
                      controller.selectedDestination.country ==
                      destination.country;

                  return _DestinationBottomSheetTile(
                    destination: destination,
                    active: active,
                    onTap: () {
                      controller.selectDestination(destination);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startCall() async {
    final number = controller.phoneNumber.trim();

    if (isStartingCall) return;

    if (number.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    controller.syncCreditBalance(ref.read(walletProvider).credits);

    if (controller.creditBalance < controller.selectedDestination.ratePerMinute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient Credits. Buy Credits before starting a call.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      context.go('/credits');
      return;
    }

    setState(() => isStartingCall = true);

    try {
      final accepted = await controller.startCall();

      if (!mounted) return;

      setState(() => isStartingCall = false);

      if (!accepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.lastError ?? 'Call rejected. Please check your Credits.',
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
        return;
      }

      final activeCall = controller.activeCall;
      if (activeCall == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activeCall.message.isNotEmpty
                ? activeCall.message
                : controller.isInternational
                    ? 'Starting international call to $number'
                    : 'Starting local call to $number',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );

      context.push(
        CallRoutes.activeCall,
        extra: ActiveCallArgs(
          callId: activeCall.callId,
          phoneNumber: number,
          destination: controller.selectedDestination.country,
          isInternational: controller.isInternational,
          ratePerMinute: controller.selectedDestination.ratePerMinute,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => isStartingCall = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    if (!controller.isLoading && controller.creditBalance != wallet.credits) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.syncCreditBalance(wallet.credits);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF020617),
              Color(0xFF071A35),
              Color(0xFF052E2B),
              Color(0xFF020617),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 18),

                      _buildDashboardHero(),

                      const SizedBox(height: 18),

                      _buildDialerPanel(),

                      const SizedBox(height: 24),

                      _buildRecentCalls(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF07111F).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Image.asset(
              'assets/icon.png',
              fit: BoxFit.contain,
              semanticLabel: 'PeraCall logo',
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PeraCall',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Secure local and global calls',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        PopupMenuButton<String>(
          color: const Color(0xFF0F172A),
          icon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          onSelected: (value) {
            if (value == 'buy_credit') {
              context.go('/credits');
            }

            if (value == 'my_numbers') {
              context.push(CallRoutes.myNumbers);
            }

            if (value == 'buy_number') {
              context.push(CallRoutes.buyInternationalNumber);
            }

            if (value == 'settings') {
              context.push(CallRoutes.settings);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'buy_credit',
              child: Text(
                'Buy Credits',
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem(
              value: 'my_numbers',
              child: Text(
                'My Numbers',
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem(
              value: 'buy_number',
              child: Text(
                'Buy Global Number',
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Text(
                'Call Settings',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF123D5A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _HeroBadge(),
              const Spacer(),
              InkWell(
                onTap: () => context.go('/credits'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => context.push(CallRoutes.myNumbers),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    Icons.dialer_sip_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => context.push(CallRoutes.buyInternationalNumber),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    Icons.sim_card_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Available Credits',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.creditBalance.toStringAsFixed(2)} Credits',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.timer_rounded,
                  label: 'Talk time',
                  value: '${controller.estimatedMinutes} mins',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.place_rounded,
                  label: 'Route',
                  value: controller.selectedDestination.country,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.payments_rounded,
                  label: 'Rate',
                  value: controller.selectedDestination.displayRate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialerPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dial a number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.isInternational ? 'Global' : 'Local',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CallModeSelector(
            isInternational: controller.isInternational,
            onChanged: controller.switchCallMode,
          ),
          const SizedBox(height: 14),
          CallDestinationCard(
            isInternational: controller.isInternational,
            destination: controller.selectedDestination,
            onTap: _showDestinationPicker,
          ),
          const SizedBox(height: 14),
          CallNumberDisplay(
            isInternational: controller.isInternational,
            phoneNumber: controller.phoneNumber,
          ),
          const SizedBox(height: 14),
          CallDialPad(onDigitTap: controller.addDigit),
          const SizedBox(height: 14),
          _buildCallAction(),
        ],
      ),
    );
  }

  Widget _buildCallAction() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isStartingCall ? null : _startCall,
            icon: isStartingCall
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.call_rounded),
            label: Text(
              isStartingCall
                  ? 'Confirming Credits...'
                  : controller.isInternational
                      ? 'Start Global Call'
                      : 'Start Local Call',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.45),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        InkWell(
          onTap: isStartingCall ? null : controller.deleteDigit,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 56,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.backspace_outlined, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCalls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.push(CallRoutes.callHistory);
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (controller.recentCalls.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF07111F).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              children: [
                Icon(Icons.history_rounded, color: Colors.white38, size: 36),
                SizedBox(height: 10),
                Text(
                  'No recent calls yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Completed calls will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

        ...controller.recentCalls.map((call) {
          return RecentCallTile(
            call: call,
            onCallTap: () => controller.useRecentCall(call),
          );
        }),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, color: Color(0xFF5EEAD4), size: 15),
          SizedBox(width: 7),
          Text(
            'Secure balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DashboardMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFBAE6FD), size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationBottomSheetTile extends StatelessWidget {
  final CallDestinationModel destination;
  final bool active;
  final VoidCallback onTap;

  const _DestinationBottomSheetTile({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.white10,
        child: Text(destination.flag, style: const TextStyle(fontSize: 22)),
      ),
      title: Text(
        destination.country,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${destination.code} • ${destination.displayRate}',
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      trailing: active
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E))
          : const Icon(Icons.chevron_right_rounded, color: Colors.white38),
    );
  }
}
