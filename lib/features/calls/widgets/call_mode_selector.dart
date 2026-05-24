import 'package:flutter/material.dart';

class CallModeSelector extends StatelessWidget {
  final bool isInternational;
  final ValueChanged<bool> onChanged;

  const CallModeSelector({
    super.key,
    required this.isInternational,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _ModeButton(
            title: 'Local Call',
            icon: Icons.phone_rounded,
            active: !isInternational,
            onTap: () => onChanged(false),
          ),
          _ModeButton(
            title: 'International',
            icon: Icons.public_rounded,
            active: isInternational,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: active ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
