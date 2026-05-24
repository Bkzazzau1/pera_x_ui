import 'package:flutter/material.dart';

class CallNumberDisplay extends StatelessWidget {
  final bool isInternational;
  final String phoneNumber;

  const CallNumberDisplay({
    super.key,
    required this.isInternational,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            isInternational
                ? 'Enter international phone number'
                : 'Enter local phone number',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            phoneNumber.isEmpty ? '+' : phoneNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
