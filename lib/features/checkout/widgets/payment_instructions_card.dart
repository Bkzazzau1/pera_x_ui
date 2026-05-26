import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/payment_method.dart';

class PaymentInstructionsCard extends StatelessWidget {
  final PaymentMethodType method;
  final double totalUsd;

  const PaymentInstructionsCard({
    super.key,
    required this.method,
    required this.totalUsd,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _contentFor(method),
      ),
    );
  }

  Widget _contentFor(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.pexToken:
        return _InstructionLayout(
          key: const ValueKey('pex'),
          icon: Icons.qr_code_2,
          accent: PeraXColors.cyan,
          title: 'Pay with Pera-X Token',
          subtitle:
              'Connect wallet or scan QR to authorize the Pera-X equivalent. This method gives the best discount and supports the burn engine.',
          footer:
              'Estimated payable: \$${totalUsd.toStringAsFixed(2)} after Pera-X discount',
          showQr: true,
        );
      case PaymentMethodType.stablecoin:
        return const _InstructionLayout(
          key: ValueKey('stablecoin'),
          icon: Icons.currency_exchange_outlined,
          accent: Color(0xFF7CFFB2),
          title: 'Pay with Stablecoin',
          subtitle:
              'Choose USDT or USDC later, send the exact amount, and wait for confirmation before service delivery.',
          footer:
              'Stablecoin checkout will support wallet address and QR confirmation.',
        );
      case PaymentMethodType.card:
        return const _InstructionLayout(
          key: ValueKey('card'),
          icon: Icons.credit_card_outlined,
          accent: Color(0xFFFFD166),
          title: 'Pay with Card',
          subtitle:
              'Continue to checkout. After approval, Pera-X records the utility payment and applies account rules.',
          footer: 'Card payment does not require the user to hold Pera-X.',
        );
      case PaymentMethodType.virtualAccountNg:
        return const _InstructionLayout(
          key: ValueKey('va'),
          icon: Icons.account_balance_outlined,
          accent: Color(0xFF9DB7FF),
          title: 'Bank Transfer / VA',
          subtitle:
              'Generate an eligible-country virtual account with exact amount and expiry timer. Service activates after transfer confirmation.',
          footer: 'Available in eligible countries only.',
        );
    }
  }
}

class _InstructionLayout extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String footer;
  final bool showQr;

  const _InstructionLayout({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.footer,
    this.showQr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: accent, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        if (showQr) ...[
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.qr_code_2,
                color: PeraXColors.darkBlue,
                size: 104,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          child: Text(
            footer,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
