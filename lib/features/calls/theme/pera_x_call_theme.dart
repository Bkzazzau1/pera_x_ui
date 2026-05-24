import 'package:flutter/material.dart';

class PeraXCallTheme {
  PeraXCallTheme._();

  static const Color background = Color(0xFF020617);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFF1E293B);

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color deepBlue = Color(0xFF172554);
  static const Color accentCyan = Color(0xFF38BDF8);

  static const Color successGreen = Color(0xFF22C55E);
  static const Color dangerRed = Color(0xFFDC2626);
  static const Color warningAmber = Color(0xFFF59E0B);

  static const Color white = Colors.white;
  static const Color textMuted = Colors.white54;
  static const Color textSoft = Colors.white70;
  static const Color border = Colors.white10;

  static const LinearGradient pageGradient = LinearGradient(
    colors: [Color(0xFF020617), Color(0xFF071A35), Color(0xFF020617)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient premiumCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF172554), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration pageDecoration() {
    return const BoxDecoration(gradient: pageGradient);
  }

  static BoxDecoration premiumCardDecoration({double radius = 26}) {
    return BoxDecoration(
      gradient: premiumCardGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.18),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static BoxDecoration surfaceDecoration({
    double radius = 22,
    Color color = surface,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
    );
  }

  static TextStyle titleStyle({double size = 22}) {
    return TextStyle(
      color: white,
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.3,
    );
  }

  static const TextStyle subtitleStyle = TextStyle(
    color: textMuted,
    fontSize: 13,
    height: 1.3,
  );

  static ButtonStyle primaryButtonStyle({double radius = 18}) {
    return ElevatedButton.styleFrom(
      backgroundColor: successGreen,
      foregroundColor: white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
    );
  }

  static ButtonStyle outlineButtonStyle({double radius = 18}) {
    return OutlinedButton.styleFrom(
      foregroundColor: white,
      side: const BorderSide(color: border),
      padding: const EdgeInsets.symmetric(vertical: 17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );
  }
}
