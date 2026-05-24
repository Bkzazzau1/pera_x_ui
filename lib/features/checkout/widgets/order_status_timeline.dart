import 'package:flutter/material.dart';

import '../../../shared/widgets/glass_card.dart';
import '../models/order_status.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatusStep activeStep;

  const OrderStatusTimeline({
    super.key,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatusStep.values;
    final activeIndex = steps.indexOf(activeStep);

    return GlassCard(
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isDone = index < activeIndex;
            final isActive = index == activeIndex;
            final isLast = index == steps.length - 1;

            return _TimelineItem(
              step: step,
              isDone: isDone,
              isActive: isActive,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final OrderStatusStep step;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone || isActive ? step.color : Colors.white24;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: isActive ? 0.18 : 0.10),
                  border: Border.all(color: color, width: isActive ? 2 : 1),
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : step.icon,
                  color: color,
                  size: 22,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: isDone ? color.withValues(alpha: 0.65) : Colors.white12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: isActive || isDone ? Colors.white : Colors.white38,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: TextStyle(
                      color: isActive || isDone ? Colors.white60 : Colors.white30,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
