import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/service_providers.dart';
import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../pricing/data/pricing_service.dart';
import '../wallet/state/wallet_provider.dart';
import 'data/ai_service.dart';
import 'utils/ai_score_color.dart';
import 'widgets/ai_access_status_card.dart';
import 'widgets/ai_task_history_card.dart';
import 'widgets/ai_tool_flow_card.dart';

class AiLabView extends ConsumerStatefulWidget {
  const AiLabView({super.key});

  @override
  ConsumerState<AiLabView> createState() => _AiLabViewState();
}

class _AiLabViewState extends ConsumerState<AiLabView> {
  final TextEditingController _notesController = TextEditingController();

  AiDocumentTool selectedTool = AiDocumentTool.detector;
  String selectedTone = 'Natural';
  PlatformFile? selectedFile;
  Uint8List? selectedBytes;
  AiDocumentResultDto? result;
  final List<AiTaskHistoryEntry> taskHistory = [];
  bool isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double _adminCostFor(List<UtilityPriceModel>? pricing, AiDocumentTool tool) {
    return pricing?.costFor(tool.apiValue, tool.fallbackCreditCost) ??
        tool.fallbackCreditCost;
  }

  Future<void> _pickDocument() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt'],
    );

    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;

    setState(() {
      selectedFile = file;
      selectedBytes = file.bytes;
      result = null;
    });
  }

  Future<void> _runTool() async {
    final file = selectedFile;
    final bytes = selectedBytes;
    final wallet = ref.read(walletProvider);
    final notes = _notesController.text.trim();
    final hasTextInput = notes.isNotEmpty;
    final hasDocumentInput = file != null && bytes != null;

    if (isProcessing || (!hasDocumentInput && !hasTextInput)) return;

    setState(() {
      isProcessing = true;
      result = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final access = await aiService.checkAccess(
        tool: selectedTool,
        creditBalance: wallet.credits,
      );

      if (!access.allowed) {
        if (!mounted) return;
        setState(() => isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(access.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final toolInstructions = selectedTool == AiDocumentTool.humanizer
          ? 'Humanizer tone: $selectedTone${notes.isEmpty ? '' : '\n$notes'}'
          : notes;

      final response = await aiService.analyzeDocument(
        tool: selectedTool,
        fileName: file?.name,
        fileBytes: bytes,
        pastedText:
            toolInstructions.trim().isEmpty ? null : toolInstructions.trim(),
      );

      if (!mounted) return;

      final finalCreditCost =
          response.creditCost > 0 ? response.creditCost : access.creditCost;

      ref.read(walletProvider.notifier).spendCredits(finalCreditCost);
      ref.read(transactionProvider.notifier).addAiPrompt(
            model: selectedTool.label,
            creditCost: finalCreditCost,
          );

      setState(() {
        result = AiDocumentResultDto(
          title: response.title,
          summary: response.summary,
          score: response.score,
          creditCost: finalCreditCost,
          findings: response.findings,
          output: response.output,
        );
        taskHistory.insert(
          0,
          AiTaskHistoryEntry(
            tool: selectedTool,
            title: response.title,
            score: response.score,
            creditCost: finalCreditCost,
            createdAt: DateTime.now(),
          ),
        );
        if (taskHistory.length > 10) {
          taskHistory.removeRange(10, taskHistory.length);
        }
        isProcessing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final utilityPricing = ref.watch(utilityPricingProvider);
    final pricing = utilityPricing.asData?.value;
    final selectedCreditCost = _adminCostFor(pricing, selectedTool);
    final hasInput =
        selectedFile != null || _notesController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _AiLabHeader(pexBalance: wallet.pex, creditBalance: wallet.credits),
            const SizedBox(height: 20),
            if (utilityPricing.isLoading) const _PricingLoadingBanner(),
            if (utilityPricing.hasError) const _PricingFallbackBanner(),
            if (utilityPricing.isLoading || utilityPricing.hasError)
              const SizedBox(height: 16),
            _ToolSelector(
              selectedTool: selectedTool,
              pricing: pricing,
              onSelected: (tool) => setState(() {
                selectedTool = tool;
                result = null;
              }),
            ),
            const SizedBox(height: 16),
            AiAccessStatusCard(
              creditBalance: wallet.credits,
              selectedTool: selectedTool,
              creditCost: selectedCreditCost,
            ),
            const SizedBox(height: 16),
            AiToolFlowCard(
              tool: selectedTool,
              walletBalance: wallet.credits,
              creditCost: selectedCreditCost,
            ),
            if (selectedTool == AiDocumentTool.humanizer) ...[
              const SizedBox(height: 16),
              _HumanizerToneSelector(
                selectedTone: selectedTone,
                onSelected: (tone) => setState(() {
                  selectedTone = tone;
                  result = null;
                }),
              ),
            ],
            const SizedBox(height: 16),
            _DocumentUploadCard(
              file: selectedFile,
              onPickDocument: _pickDocument,
              onClear: () => setState(() {
                selectedFile = null;
                selectedBytes = null;
                result = null;
              }),
            ),
            const SizedBox(height: 16),
            _OptionalNotes(
              controller: _notesController,
              selectedTool: selectedTool,
              selectedTone: selectedTone,
              onChanged: () => setState(() => result = null),
            ),
            const SizedBox(height: 16),
            _RunPanel(
              tool: selectedTool,
              creditCost: selectedCreditCost,
              hasInput: hasInput,
              isProcessing: isProcessing,
              onRun: _runTool,
            ),
            const SizedBox(height: 20),
            if (isProcessing) const _ProcessingState(),
            if (result != null) _ResultPanel(result: result!),
            const SizedBox(height: 20),
            AiTaskHistoryCard(
              entries: taskHistory,
              onClear: () => setState(taskHistory.clear),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingLoadingBanner extends StatelessWidget {
  const _PricingLoadingBanner();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      radius: 18,
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PeraXColors.cyan,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Loading admin-set AI prices...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingFallbackBanner extends StatelessWidget {
  const _PricingFallbackBanner();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      radius: 18,
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Displaying fallback prices. Backend will still confirm the final Credit charge.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiLabHeader extends StatelessWidget {
  final double pexBalance;
  final double creditBalance;

  const _AiLabHeader({required this.pexBalance, required this.creditBalance});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AGENTIC AI LAB',
                style: TextStyle(
                  color: PeraXColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Document Intelligence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'AI Detector, Humanizer AI, and Plagiarism Checker spend Credits. PEX remains the ecosystem token.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GlassCard(
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '${creditBalance.toInt()} Credits',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '${pexBalance.toInt()} PEX',
                style: const TextStyle(
                  color: PeraXColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolSelector extends StatelessWidget {
  final AiDocumentTool selectedTool;
  final List<UtilityPriceModel>? pricing;
  final ValueChanged<AiDocumentTool> onSelected;

  const _ToolSelector({
    required this.selectedTool,
    required this.pricing,
    required this.onSelected,
  });

  double _costFor(AiDocumentTool tool) {
    return pricing?.costFor(tool.apiValue, tool.fallbackCreditCost) ??
        tool.fallbackCreditCost;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AiDocumentTool.values.map((tool) {
        final isActive = selectedTool == tool;
        final creditCost = _costFor(tool);
        final icon = switch (tool) {
          AiDocumentTool.detector => Icons.radar_rounded,
          AiDocumentTool.plagiarism => Icons.fact_check_rounded,
          AiDocumentTool.humanizer => Icons.edit_note_rounded,
        };
        final subtitle = switch (tool) {
          AiDocumentTool.detector => 'Check whether text appears AI-generated',
          AiDocumentTool.plagiarism => 'Scan for similarity and citation risk',
          AiDocumentTool.humanizer => 'Rewrite for a natural human tone',
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onSelected(tool),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? PeraXColors.cyan.withValues(alpha: 0.14)
                    : PeraXColors.darkBlue.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? PeraXColors.cyan : PeraXColors.glassBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isActive ? PeraXColors.cyan : Colors.white54,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${creditCost.toStringAsFixed(creditCost % 1 == 0 ? 0 : 2)} Credits',
                    style: const TextStyle(
                      color: PeraXColors.cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HumanizerToneSelector extends StatelessWidget {
  final String selectedTone;
  final ValueChanged<String> onSelected;

  const _HumanizerToneSelector({
    required this.selectedTone,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const tones = [
      ('Natural', Icons.person_outline_rounded),
      ('Academic', Icons.school_outlined),
      ('Professional', Icons.business_center_outlined),
      ('Simple', Icons.lightbulb_outline_rounded),
      ('Formal', Icons.balance_outlined),
    ];

    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Humanizer Tone',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the tone before rewriting. Backend will receive this as part of the Humanizer AI instruction.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tones.map((tone) {
              final isActive = selectedTone == tone.$1;
              return GestureDetector(
                onTap: () => onSelected(tone.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? PeraXColors.cyan
                        : PeraXColors.surfaceBlue.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? Colors.white24
                          : PeraXColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tone.$2,
                        color: isActive ? PeraXColors.darkBlue : Colors.white60,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tone.$1,
                        style: TextStyle(
                          color: isActive ? PeraXColors.darkBlue : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final PlatformFile? file;
  final VoidCallback onPickDocument;
  final VoidCallback onClear;

  const _DocumentUploadCard({
    required this.file,
    required this.onPickDocument,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final selected = file;

    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: PeraXColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              color: PeraXColors.cyan,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected?.name ?? 'Upload document optional',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'PDF, Word, or TXT. You can also paste text below.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (selected == null)
            IconButton(
              onPressed: onPickDocument,
              icon: const Icon(Icons.add_rounded, color: PeraXColors.cyan),
            )
          else
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: Colors.orange),
            ),
        ],
      ),
    );
  }
}

class _OptionalNotes extends StatelessWidget {
  final TextEditingController controller;
  final AiDocumentTool selectedTool;
  final String selectedTone;
  final VoidCallback onChanged;

  const _OptionalNotes({
    required this.controller,
    required this.selectedTool,
    required this.selectedTone,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hint = selectedTool == AiDocumentTool.humanizer
        ? 'Paste text or add rewriting instruction. Tone: $selectedTone.'
        : 'Paste text here or add optional notes for the AI scan.';

    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        minLines: 4,
        maxLines: 8,
        style: const TextStyle(color: Colors.white, height: 1.4),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _RunPanel extends StatelessWidget {
  final AiDocumentTool tool;
  final double creditCost;
  final bool hasInput;
  final bool isProcessing;
  final VoidCallback onRun;

  const _RunPanel({
    required this.tool,
    required this.creditCost,
    required this.hasInput,
    required this.isProcessing,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: hasInput && !isProcessing ? onRun : null,
      icon: Icon(isProcessing ? Icons.hourglass_bottom_rounded : Icons.auto_awesome_rounded),
      label: Text(
        isProcessing
            ? 'PROCESSING ${tool.label.toUpperCase()}'
            : 'RUN ${tool.label.toUpperCase()} • ${creditCost.toStringAsFixed(0)} CREDITS',
      ),
      style: FilledButton.styleFrom(
        backgroundColor: PeraXColors.cyan,
        foregroundColor: PeraXColors.darkBlue,
        disabledBackgroundColor: Colors.white10,
        disabledForegroundColor: Colors.white30,
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _ProcessingState extends StatelessWidget {
  const _ProcessingState();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      radius: 24,
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PeraXColors.cyan,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Backend is confirming Credits and processing the AI task...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final AiDocumentResultDto result;

  const _ResultPanel({required this.result});

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
              Expanded(
                child: Text(
                  result.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '${result.score.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: getAiScoreColor(result.score),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.summary,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 12),
          Text(
            '${result.creditCost.toStringAsFixed(0)} Credits charged',
            style: const TextStyle(
              color: PeraXColors.cyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...result.findings.map(
            (finding) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: PeraXColors.cyan, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      finding,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PeraXColors.surfaceBlue.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PeraXColors.glassBorder),
            ),
            child: Text(
              result.output,
              style: const TextStyle(color: Colors.white70, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
