import 'package:flutter/material.dart';

class CallBalanceCard extends StatelessWidget {
  final double creditBalance;
  final int estimatedMinutes;
  final String destinationName;

  const CallBalanceCard({
    super.key,
    required this.creditBalance,
    required this.estimatedMinutes,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF172554), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SoftBadge(
                text: 'Available Call Credit',
                icon: Icons.bolt_rounded,
              ),
              const Spacer(),
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.token_rounded,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${creditBalance.toStringAsFixed(2)} Credits',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF22C55E),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Estimated talk time: $estimatedMinutes mins to $destinationName',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SoftBadge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
