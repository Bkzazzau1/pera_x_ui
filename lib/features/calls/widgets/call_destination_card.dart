import 'package:flutter/material.dart';

import '../models/call_destination_model.dart';

class CallDestinationCard extends StatelessWidget {
  final bool isInternational;
  final CallDestinationModel destination;
  final VoidCallback onTap;

  const CallDestinationCard({
    super.key,
    required this.isInternational,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isInternational
        ? 'International destination'
        : 'Local destination';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  destination.flag,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${destination.country}  ${destination.code}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    destination.displayRate,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
