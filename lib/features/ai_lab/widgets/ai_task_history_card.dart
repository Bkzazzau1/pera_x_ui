import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/ai_service.dart';

class AiTaskHistoryEntry {
  final AiDocumentTool tool;
  final String title;
  final double score;
  final double pexCost;
  final DateTime createdAt;

  const AiTaskHistoryEntry({
    required this.tool,
    required this.title,
    required this.score,
    required this.pexCost,
    required this.createdAt,
  });
}

class AiTaskHistoryCard extends StatelessWidget {
  final List<AiTaskHistoryEntry> entries;
  final VoidCallback onClear;

  const AiTaskHistoryCard({
    super.key,
    required this.entries,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'AI Task History',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
              if (entries.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PeraXColors.glassBorder),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Recent AI Detector, Humanizer AI, and Plagiarism Checker tasks. Backend will later persist full history.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PeraXColors.surfaceBlue.withValues(alpha: 0.54),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: PeraXColors.glassBorder),
              ),
              child: const Text(
                'No AI tasks yet. Run any AI tool and your recent result will appear here.',
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
              ),
            )
          else
            ...entries.take(5).map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryItem(entry: entry),
                  ),
                ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final AiTaskHistoryEntry entry;

  const _HistoryItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PeraXColors.surfaceBlue.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PeraXColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: PeraXColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconFor(entry.tool), color: PeraXColors.cyan, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.tool.label} • ${entry.pexCost.toStringAsFixed(0)} PEX • ${_timeLabel(entry.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${entry.score.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: PeraXColors.cyan,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(AiDocumentTool tool) {
    switch (tool) {
      case AiDocumentTool.detector:
        return Icons.radar_rounded;
      case AiDocumentTool.plagiarism:
        return Icons.fact_check_rounded;
      case AiDocumentTool.humanizer:
        return Icons.edit_note_rounded;
    }
  }

  String _timeLabel(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
