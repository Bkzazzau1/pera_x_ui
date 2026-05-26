import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../wallet/state/wallet_provider.dart';
import '../data/call_service.dart';
import '../routes/call_routes.dart';

class ActiveCallView extends ConsumerStatefulWidget {
  final String callId;
  final String phoneNumber;
  final String destination;
  final bool isInternational;
  final double ratePerMinute;

  const ActiveCallView({
    super.key,
    required this.callId,
    required this.phoneNumber,
    required this.destination,
    required this.isInternational,
    required this.ratePerMinute,
  });

  @override
  ConsumerState<ActiveCallView> createState() => _ActiveCallViewState();
}

class _ActiveCallViewState extends ConsumerState<ActiveCallView> {
  final CallService service = CallService();
  Timer? timer;
  int seconds = 0;

  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isOnHold = false;
  bool showKeypad = false;
  bool isEndingCall = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isOnHold) {
        setState(() => seconds++);
      }
    });
  }

  String get formattedDuration {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get estimatedCharge {
    final minutesUsed = seconds / 60;
    return minutesUsed * widget.ratePerMinute;
  }

  Future<void> endCall() async {
    if (isEndingCall) return;

    timer?.cancel();
    setState(() => isEndingCall = true);

    final wallet = ref.read(walletProvider);

    try {
      final response = await service.endCallSession(
        callId: widget.callId,
        phoneNumber: widget.phoneNumber,
        durationSeconds: seconds,
        ratePerMinute: widget.ratePerMinute,
        creditBalance: wallet.credits,
        isInternational: widget.isInternational,
      );

      if (!mounted) return;

      if (!response.completed) {
        setState(() => isEndingCall = false);
        startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isEmpty
                  ? 'Call could not be completed. The final charge was not approved.'
                  : response.message,
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
        return;
      }

      ref.read(walletProvider.notifier).spendCredits(response.creditCost);

      context.go(
        CallRoutes.callReceipt,
        extra: CallReceiptArgs(
          phoneNumber: widget.phoneNumber,
          destination: widget.destination,
          duration: formattedDuration,
          charge: response.creditCost,
          isInternational: widget.isInternational,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => isEndingCall = false);
      startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not confirm final call charge. No Credits were deducted. ${error.toString()}',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 28),
                _buildCallerInfo(),
                const SizedBox(height: 24),
                _buildCallStatusCard(),
                const SizedBox(height: 28),
                if (showKeypad) _buildMiniKeypad() else _buildControls(),
                const SizedBox(height: 28),
                _buildEndCallButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PeraCall Secure Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.isInternational ? 'International call' : 'Local call',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            isEndingCall ? 'ENDING' : 'LIVE',
            style: const TextStyle(
              color: Color(0xFF5EEAD4),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        Container(
          height: 112,
          width: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 54,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.phoneNumber,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.destination,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          formattedDuration,
          style: const TextStyle(
            color: Color(0xFF5EEAD4),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCallStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _InfoItem(
            title: 'Rate',
            value: '${widget.ratePerMinute.toStringAsFixed(2)} Credits/min',
          ),
          Container(width: 1, height: 36, color: Colors.white10),
          _InfoItem(
            title: 'Estimated',
            value: '${estimatedCharge.toStringAsFixed(4)} Credits',
          ),
          Container(width: 1, height: 36, color: Colors.white10),
          _InfoItem(
            title: 'Status',
            value: isEndingCall
                ? 'Confirming'
                : isOnHold
                ? 'On hold'
                : 'Connected',
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CallControlButton(
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: isMuted ? 'Muted' : 'Mute',
              active: isMuted,
              onTap: () => setState(() => isMuted = !isMuted),
            ),
            _CallControlButton(
              icon: isSpeakerOn
                  ? Icons.volume_up_rounded
                  : Icons.volume_down_rounded,
              label: 'Speaker',
              active: isSpeakerOn,
              onTap: () => setState(() => isSpeakerOn = !isSpeakerOn),
            ),
            _CallControlButton(
              icon: Icons.dialpad_rounded,
              label: 'Keypad',
              active: showKeypad,
              onTap: () => setState(() => showKeypad = true),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CallControlButton(
              icon: Icons.pause_rounded,
              label: isOnHold ? 'Resume' : 'Hold',
              active: isOnHold,
              onTap: () => setState(() => isOnHold = !isOnHold),
            ),
            _CallControlButton(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Add',
              active: false,
              onTap: () {},
            ),
            _CallControlButton(
              icon: Icons.security_rounded,
              label: 'Secure',
              active: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          itemCount: keys.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (_, index) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF07111F).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Center(
                child: Text(
                  keys[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () => setState(() => showKeypad = false),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          label: const Text('Hide keypad'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF5EEAD4)),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return InkWell(
      onTap: isEndingCall ? null : endCall,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 74,
        width: 74,
        decoration: BoxDecoration(
          color: isEndingCall ? Colors.white24 : const Color(0xFFDC2626),
          shape: BoxShape.circle,
          boxShadow: [
            if (!isEndingCall)
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
          ],
        ),
        child: isEndingCall
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.call_end_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
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

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF14B8A6).withValues(alpha: 0.16)
                  : const Color(0xFF07111F).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active
                    ? const Color(0xFF14B8A6).withValues(alpha: 0.65)
                    : Colors.white10,
              ),
            ),
            child: Icon(
              icon,
              color: active ? const Color(0xFF5EEAD4) : Colors.white70,
              size: 25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
