import 'package:flutter/material.dart';

Color getAiScoreColor(double score) {
  if (score >= 70) {
    return const Color(0xFFEF4444);
  }
  if (score >= 40) {
    return const Color(0xFFF59E0B);
  }
  return const Color(0xFF22C55E);
}
