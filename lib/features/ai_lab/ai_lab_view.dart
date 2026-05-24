import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/service_providers.dart';
import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../wallet/state/wallet_provider.dart';
import 'data/ai_service.dart';
import 'widgets/ai_access_status_card.dart';
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
  bool isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

    if (isProcessing || file == null || bytes == null) return;

    if (wallet.pex < selectedTool.pexCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient PEX for this AI document service.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      result = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final notes = _notesController.text.trim();
      final toolInstructions = selectedTool == AiDocumentTool.humanizer
          ? 'Humanizer tone: $selectedTone${notes.isEmpty ? '' : '\n$notes'}'
          : notes;

      final response = await aiService.analyzeDocument(
        tool: selectedTool,
        fileName: file.name,
        fileBytes: bytes,
        pastedText: toolInstructions.trim().isEmpty ? null : toolInstructions.trim(),
      );

      if (!mounted) return;

      ref.read(walletProvider.notifier).burnPex(response.pexCost);
      ref
          .read(transactionProvider.notifier)
          .addAiPrompt(model: selectedTool.label, pexCost: response.pexCost);
      ref
          .read(transactionProvider.notifier)
          .addAiBurn(model: selectedTool.label, pexAmount: response.pexCost);

      setState(() {
        result = response;
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _AiLabHeader(walletBalance: wallet.pex),
            const SizedBox(height: 20),
            _ToolSelector(
              selectedTool: selectedTool,
              onSelected: (tool) => setState(() {
                selectedTool = tool;
                result = null;
              }),
            ),
            const SizedBox(height: 16),
            AiAccessStatusCard(
              walletBalance: wallet.pex,
              selectedTool: selectedTool,
            ),
            const SizedBox(height: 16),
            AiToolFlowCard(
              tool: selectedTool,
              walletBalance: wallet.pex,
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
            ),
            const SizedBox(height: 16),
            _RunPanel(
              tool: selectedTool,
              hasDocument: selectedFile != null,
              isProcessing: isProcessing,
              onRun: _runTool,
            ),
            const SizedBox(height: 20),
            if (isProcessing) const _ProcessingState(),
            if (result != null) _ResultPanel(result: result!),
          ],
        ),
      ),
    );
  }
}

class _AiLabHeader extends StatelessWidget {
  final double walletBalance;

  const _AiLabHeader({required this.walletBalance});

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
                'AI Detector, Humanizer AI, and Plagiarism Checker with token-gated access.',
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
        GlassCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '${walletBalance.toInt()} PEX',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolSelector extends StatelessWidget {
  final AiDocumentTool selectedTool;
  final ValueChanged<AiDocumentTool> onSelected;

  const _ToolSelector({required this.selectedTool, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AiDocumentTool.values.map((tool) {
        final isActive = selectedTool == tool;
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
                    '${tool.pexCost.toInt()} PEX',
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: isActive
                        ? PeraXColors.cyan
                        : PeraXColors.surfaceBlue.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? Colors.white24 : PeraXColors.glassBorder,
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
                  selected?.name ?? 'Upload document',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selected == null
                      ? 'PDF, DOC, DOCX, or TXT'
                      : '${(selected.size / 1024).toStringAsFixed(1)} KB ready',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: selected == null ? 'Upload' : 'Remove',
            onPressed: selected == null ? onPickDocument : onClear,
            icon: Icon(
              selected == null ? Icons.add_rounded : Icons.close_rounded,
              color: Colors.white,
            ),
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

  const _OptionalNotes({
    required this.controller,
    required this.selectedTool,
    required this.selectedTone,
  });

  @override
  Widget build(BuildContext context) {
    final hintText = selectedTool == AiDocumentTool.humanizer
        ? 'Optional instructions for $selectedTone tone...'
        : 'Optional instructions or pasted text...';

    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: PeraXColors.darkBlue.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _RunPanel extends StatelessWidget {
  final AiDocumentTool tool;
  final bool hasDocument;
  final bool isProcessing;
  final VoidCallback onRun;

  const _RunPanel({
    required this.tool,
    required this.hasDocument,
    required this.isProcessing,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: hasDocument && !isProcessing ? onRun : null,
      icon: Icon(
        isProcessing ? Icons.hourglass_bottom : Icons.play_arrow_rounded,
      ),
      label: Text(
        isProcessing
            ? 'PROCESSING DOCUMENT'
            : 'RUN ${tool.label.toUpperCase()} // ${tool.pexCost.toInt()} PEX',
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
      radius: 22,
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Backend is confirming token access and processing the AI task.',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
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
    final reportText = _formatReport(result);

    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.all(20),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${result.score.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: PeraXColors.cyan,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.summary,
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 16),
          ...result.findings.map(
            (finding) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: PeraXColors.cyan,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      finding,
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.35,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PeraXColors.glassBorder),
            ),
            child: Text(
              result.output,
              style: const TextStyle(color: Colors.white, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ResultActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy Result',
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: result.output));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI output copied.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              _ResultActionButton(
                icon: Icons.article_outlined,
                label: 'Copy Report',
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: reportText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Full AI report copied.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              _ResultActionButton(
                icon: Icons.download_rounded,
                label: 'Download Later',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download export will be connected with backend storage.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatReport(AiDocumentResultDto result) {
    final findingsText = result.findings
        .map((finding) => '- $finding')
        .join('\n');

    return '''${result.title}

Score: ${result.score.toStringAsFixed(0)}%
PEX Cost: ${result.pexCost.toStringAsFixed(0)} PEX

Summary:
${result.summary}

Findings:
$findingsText

Output:
${result.output}
''';
  }
}

class _ResultActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ResultActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: PeraXColors.cyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PeraXColors.cyan.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: PeraXColors.cyan, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: PeraXColors.cyan,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
