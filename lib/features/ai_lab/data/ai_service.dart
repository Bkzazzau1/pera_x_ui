import 'dart:convert';
import 'dart:typed_data';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

enum AiDocumentTool {
  detector(
    label: 'AI Detector',
    apiValue: 'ai_detector',
    fallbackCreditCost: 6,
  ),
  plagiarism(
    label: 'Plagiarism Checker',
    apiValue: 'plagiarism_checker',
    fallbackCreditCost: 8,
  ),
  humanizer(
    label: 'Humanizer AI',
    apiValue: 'humanizer',
    fallbackCreditCost: 10,
  );

  final String label;
  final String apiValue;
  final double fallbackCreditCost;

  const AiDocumentTool({
    required this.label,
    required this.apiValue,
    required this.fallbackCreditCost,
  });
}

class AiDocumentResultDto {
  final String title;
  final String summary;
  final double score;
  final double creditCost;
  final List<String> findings;
  final String output;

  const AiDocumentResultDto({
    required this.title,
    required this.summary,
    required this.score,
    required this.creditCost,
    required this.findings,
    required this.output,
  });

  factory AiDocumentResultDto.fromJson(Map<String, dynamic> json) {
    return AiDocumentResultDto(
      title: json['title']?.toString() ?? 'Document Result',
      summary: json['summary']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      findings:
          (json['findings'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      output: json['output']?.toString() ?? '',
    );
  }
}

class AiAccessCheckDto {
  final bool allowed;
  final double creditCost;
  final double creditBalance;
  final double remainingCredits;
  final String message;

  const AiAccessCheckDto({
    required this.allowed,
    required this.creditCost,
    required this.creditBalance,
    required this.remainingCredits,
    required this.message,
  });

  factory AiAccessCheckDto.fromJson(Map<String, dynamic> json) {
    return AiAccessCheckDto(
      allowed: json['allowed'] == true,
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
      creditBalance: (json['creditBalance'] as num?)?.toDouble() ?? 0,
      remainingCredits: (json['remainingCredits'] as num?)?.toDouble() ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}

class AiService {
  final ApiClient _apiClient;

  AiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AiAccessCheckDto> checkAccess({
    required AiDocumentTool tool,
    required double creditBalance,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final remaining = creditBalance - tool.fallbackCreditCost;
      return AiAccessCheckDto(
        allowed: remaining >= 0,
        creditCost: tool.fallbackCreditCost,
        creditBalance: creditBalance,
        remainingCredits: remaining,
        message: remaining >= 0
            ? 'Credit access confirmed.'
            : 'Insufficient Credits for this AI task.',
      );
    }

    final response = await _apiClient.post(
      '/ai/access/check',
      body: {'tool': tool.apiValue, 'creditBalance': creditBalance},
    );

    return AiAccessCheckDto.fromJson(response as Map<String, dynamic>);
  }

  Future<AiDocumentResultDto> analyzeDocument({
    required AiDocumentTool tool,
    String? fileName,
    Uint8List? fileBytes,
    String? pastedText,
  }) async {
    final sourceName = fileName ?? 'Pasted Text';

    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return _mockResult(tool, sourceName);
    }

    final response = await _apiClient.post(
      '/ai/documents/analyze',
      body: {
        'tool': tool.apiValue,
        'fileName': fileName,
        'fileBase64': fileBytes == null ? null : base64Encode(fileBytes),
        'text': pastedText,
        'inputMode': fileBytes == null ? 'text' : 'document',
      },
    );

    return AiDocumentResultDto.fromJson(response as Map<String, dynamic>);
  }

  AiDocumentResultDto _mockResult(AiDocumentTool tool, String fileName) {
    switch (tool) {
      case AiDocumentTool.detector:
        return AiDocumentResultDto(
          title: 'AI Detection Report',
          summary:
              '$fileName shows mixed authorship signals with several machine-patterned sections.',
          score: 72,
          creditCost: tool.fallbackCreditCost,
          findings: const [
            'High predictability in three body paragraphs.',
            'Low sentence variation around repeated claims.',
            'Human-like introduction and conclusion structure.',
          ],
          output:
              'Recommendation: revise flagged sections with more original examples, varied sentence rhythm, and specific source-backed claims.',
        );
      case AiDocumentTool.plagiarism:
        return AiDocumentResultDto(
          title: 'Plagiarism Check Report',
          summary: '$fileName has a low-to-moderate similarity profile.',
          score: 18,
          creditCost: tool.fallbackCreditCost,
          findings: const [
            'Several common phrases matched public web language.',
            'No full-section duplicate detected.',
            'Citation review recommended for statistical claims.',
          ],
          output:
              'Recommendation: add citations for factual claims and rewrite generic matching phrases before submission.',
        );
      case AiDocumentTool.humanizer:
        return AiDocumentResultDto(
          title: 'Humanized Draft',
          summary:
              '$fileName was rewritten for clearer rhythm, natural tone, and less formulaic phrasing.',
          score: 91,
          creditCost: tool.fallbackCreditCost,
          findings: const [
            'Reduced repetitive transitions.',
            'Improved sentence variety.',
            'Kept the original meaning and structure intact.',
          ],
          output:
              'Humanized sample: The document now reads with a more natural academic voice, using clearer transitions and more specific phrasing while preserving the original intent.',
        );
    }
  }
}
