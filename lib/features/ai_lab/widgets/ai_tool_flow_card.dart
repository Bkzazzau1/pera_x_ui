import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/ai_service.dart';

class AiToolFlowCard extends StatelessWidget {
  final AiDocumentTool tool;
  final double walletBalance;

  const AiToolFlowCard({
    super.key,
    required this.tool,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = walletBalance >= tool.creditCost;
    final steps = _stepsFor(tool);

    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: PeraXColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PeraXColors.glassBorder),
                ),
                child: Icon(_iconFor(tool), color: PeraXColors.cyan, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleFor(tool),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitleFor(tool),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasAccess
                  ? PeraXColors.cyan.withValues(alpha: 0.10)
                  : Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasAccess
                    ? PeraXColors.cyan.withValues(alpha: 0.25)
                    : Colors.orange.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasAccess ? Icons.verified_rounded : Icons.lock_outline_rounded,
                  color: hasAccess ? PeraXColors.cyan : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasAccess
                        ? 'Credit access ready. Backend will confirm balance before processing.'
                        : 'More Credits are required before this AI task can run.',
                    style: TextStyle(
                      color: hasAccess ? PeraXColors.cyan : Colors.orange,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Best Flow',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map(
            (entry) => _FlowStep(
              index: entry.key + 1,
              text: entry.value,
              isLast: entry.key == steps.length - 1,
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

  String _titleFor(AiDocumentTool tool) {
    switch (tool) {
      case AiDocumentTool.detector:
        return 'AI Detector Flow';
      case AiDocumentTool.plagiarism:
        return 'Plagiarism Checker Flow';
      case AiDocumentTool.humanizer:
        return 'Humanizer AI Flow';
    }
  }

  String _subtitleFor(AiDocumentTool tool) {
    switch (tool) {
      case AiDocumentTool.detector:
        return 'Detect machine-written patterns and explain risky sections.';
      case AiDocumentTool.plagiarism:
        return 'Scan similarity risk and help users improve citations.';
      case AiDocumentTool.humanizer:
        return 'Rewrite text into a natural human tone while preserving meaning.';
    }
  }

  List<String> _stepsFor(AiDocumentTool tool) {
    switch (tool) {
      case AiDocumentTool.detector:
        return const [
          'Upload document or paste text.',
          'Backend confirms Credit access.',
          'AI scans predictability, repetition, and sentence pattern risk.',
          'Show AI probability score, flagged signals, and improvement advice.',
        ];
      case AiDocumentTool.plagiarism:
        return const [
          'Upload document or paste text.',
          'Backend confirms Credit access.',
          'Similarity engine checks matching and citation risk.',
          'Show similarity score, risky sections, and citation recommendations.',
        ];
      case AiDocumentTool.humanizer:
        return const [
          'Upload document or paste text.',
          'Backend confirms Credit access.',
          'User can add tone instructions before processing.',
          'Show humanized output with copy-ready rewritten text.',
        ];
    }
  }
}

class _FlowStep extends StatelessWidget {
  final int index;
  final String text;
  final bool isLast;

  const _FlowStep({
    required this.index,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PeraXColors.cyan.withValues(alpha: 0.12),
                  border: Border.all(color: PeraXColors.cyan.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: PeraXColors.cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: PeraXColors.glassBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
