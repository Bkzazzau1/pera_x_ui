import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/ai_service.dart';

class AiAccessStatusCard extends StatelessWidget {
  final double creditBalance;
  final AiDocumentTool selectedTool;
  final double creditCost;

  const AiAccessStatusCard({
    super.key,
    required this.creditBalance,
    required this.selectedTool,
    required this.creditCost,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = creditBalance - creditCost;
    final hasAccess = remaining >= 0;

    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasAccess
                      ? PeraXColors.cyan.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasAccess
                        ? PeraXColors.cyan.withValues(alpha: 0.28)
                        : Colors.orange.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  hasAccess
                      ? Icons.verified_user_rounded
                      : Icons.lock_outline_rounded,
                  color: hasAccess ? PeraXColors.cyan : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAccess ? 'Credit Access Ready' : 'Credits Required',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasAccess
                          ? 'Backend will confirm credit access before processing ${selectedTool.label}.'
                          : 'Buy Credits before running this AI tool.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AccessMetric(
                  label: 'Credits',
                  value: creditBalance.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AccessMetric(
                  label: 'Tool Cost',
                  value: '${creditCost.toStringAsFixed(0)} Credits',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AccessMetric(
                  label: 'After Run',
                  value: hasAccess
                      ? '${remaining.toStringAsFixed(0)} Credits'
                      : 'Insufficient',
                  isWarning: !hasAccess,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _AccessMetric({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? Colors.orange : PeraXColors.cyan;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PeraXColors.surfaceBlue.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PeraXColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
