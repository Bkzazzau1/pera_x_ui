import 'package:flutter/material.dart';

import '../models/recent_call_model.dart';

class RecentCallTile extends StatelessWidget {
  final RecentCallModel call;
  final VoidCallback onCallTap;

  const RecentCallTile({
    super.key,
    required this.call,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = call.isLocal
        ? const Color(0xFF22C55E)
        : const Color(0xFF38BDF8);

    final tagBackground = call.isLocal
        ? const Color(0xFF22C55E).withValues(alpha: 0.14)
        : const Color(0xFF38BDF8).withValues(alpha: 0.14);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white70),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        call.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tagBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        call.typeLabel,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${call.number} • ${call.time}',
                  style: const TextStyle(
                    color: Color(0x73FFFFFF),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          InkWell(
            onTap: onCallTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.call_rounded,
                color: Color(0xFF22C55E),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
