import 'dart:convert';
import 'dart:typed_data';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

enum AiDocumentTool {
  detector(label: 'AI Detector', apiValue: 'ai_detector', pexCost: 6),
  plagiarism(
    label: 'Plagiarism Checker',
    apiValue: 'plagiarism_checker',
    pexCost: 8,
  ),
  humanizer(label: 'Humanizer AI', apiValue: 'humanizer', pexCost: 10);

  final String label;
  final String apiValue;
  final double pexCost;

  const AiDocumentTool({
    required this.label,
    required this.apiValue,
    required this.pexCost,
  });
}

class AiDocumentResultDto {
  final String title;
  final String summary;
  final double score;
  final double pexCost;
  final List<String> findings;
  final String output;

  const AiDocumentResultDto({
    required this.title,
    required this.summary,
    required this.score,
    required this.pexCost,
    required this.findings,
    required this.output,
  });

  factory AiDocumentResultDto.fromJson(Map<String, dynamic> json) {
    return AiDocumentResultDto(
      title: json['title']?.toString() ?? 'Document Result',
      summary: json['summary']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      pexCost: (json['pexCost'] as num?)?.toDouble() ?? 6,
      findings:
          (json['findings'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      output: json['output']?.toString() ?? '',
    );
  }
}

class AiService {
  final ApiClient _apiClient;

  AiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AiDocumentResultDto> analyzeDocument({
    required AiDocumentTool tool,
    required String fileName,
    required Uint8List fileBytes,
    String? pastedText,
  }) async {
    if (AppConfig.enableMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return _mockResult(tool, fileName);
    }

    final response = await _apiClient.post(
      '/ai/documents/analyze',
      body: {
        'tool': tool.apiValue,
        'fileName': fileName,
        'fileBase64': base64Encode(fileBytes),
        'text': pastedText,
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
          pexCost: tool.pexCost,
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
          summary:
              '$fileName has a low-to-moderate similarity profile in the demo scan.',
          score: 18,
          pexCost: tool.pexCost,
          findings: const [
            'Several common phrases matched public web language.',
            'No full-section duplicate detected in mock mode.',
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
          pexCost: tool.pexCost,
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
