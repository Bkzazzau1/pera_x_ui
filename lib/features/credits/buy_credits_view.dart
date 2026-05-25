import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../wallet/state/wallet_provider.dart';

enum CreditFundingMethod {
  pex,
  card,
  stablecoin,
  virtualAccount;

  String get title {
    switch (this) {
      case CreditFundingMethod.pex:
        return 'Pay with PEX';
      case CreditFundingMethod.card:
        return 'Card Payment';
      case CreditFundingMethod.stablecoin:
        return 'Stablecoin';
      case CreditFundingMethod.virtualAccount:
        return 'Bank Transfer / VA';
    }
  }

  String get subtitle {
    switch (this) {
      case CreditFundingMethod.pex:
        return 'Convert PEX into spendable platform Credits.';
      case CreditFundingMethod.card:
        return 'Buy Credits with debit or credit card.';
      case CreditFundingMethod.stablecoin:
        return 'Pay with USDT or USDC and receive Credits.';
      case CreditFundingMethod.virtualAccount:
        return 'Available in eligible countries only.';
    }
  }

  IconData get icon {
    switch (this) {
      case CreditFundingMethod.pex:
        return Icons.token_outlined;
      case CreditFundingMethod.card:
        return Icons.credit_card_outlined;
      case CreditFundingMethod.stablecoin:
        return Icons.currency_exchange_outlined;
      case CreditFundingMethod.virtualAccount:
        return Icons.account_balance_outlined;
    }
  }
}

class BuyCreditsView extends ConsumerStatefulWidget {
  const BuyCreditsView({super.key});

  @override
  ConsumerState<BuyCreditsView> createState() => _BuyCreditsViewState();
}

class _BuyCreditsViewState extends ConsumerState<BuyCreditsView> {
  final TextEditingController _amountController = TextEditingController(text: '100');
  CreditFundingMethod selectedMethod = CreditFundingMethod.pex;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get creditAmount => double.tryParse(_amountController.text.trim()) ?? 0;

  bool _canBuy(WalletState wallet) {
    if (creditAmount <= 0) return false;
    if (selectedMethod == CreditFundingMethod.pex) {
      return wallet.pex >= creditAmount;
    }
    return true;
  }

  void _buyCredits() {
    final wallet = ref.read(walletProvider);

    if (!_canBuy(wallet)) {
      _showSnack(
        selectedMethod == CreditFundingMethod.pex
            ? 'Insufficient PEX to buy this amount of Credits.'
            : 'Enter a valid Credit amount.',
      );
      return;
    }

    if (selectedMethod == CreditFundingMethod.pex) {
      ref.read(walletProvider.notifier).buyCreditsWithPex(creditAmount);
    } else {
      ref.read(walletProvider.notifier).addCredits(creditAmount);
    }

    ref.read(transactionProvider.notifier).addCreditPurchase(
          method: selectedMethod.title,
          credits: creditAmount,
        );

    _showSnack('${creditAmount.toStringAsFixed(0)} Credits added successfully.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final canBuy = _canBuy(wallet);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            const _CreditsHeader(),
            const SizedBox(height: 20),
            _BalanceOverview(wallet: wallet),
            const SizedBox(height: 18),
            _AmountCard(
              controller: _amountController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 18),
            _FundingMethods(
              selectedMethod: selectedMethod,
              onSelected: (method) => setState(() => selectedMethod = method),
            ),
            const SizedBox(height: 18),
            _CreditSummary(
              method: selectedMethod,
              creditAmount: creditAmount,
              wallet: wallet,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: canBuy ? _buyCredits : null,
              icon: const Icon(Icons.add_card_rounded),
              label: Text(
                selectedMethod == CreditFundingMethod.pex
                    ? 'BUY CREDITS WITH PEX'
                    : 'CONTINUE TO PAYMENT',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditsHeader extends StatelessWidget {
  const _CreditsHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buy Credits',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Credits are the internal spending balance for AI tools, calls, bills, virtual numbers, and platform services. PEX remains the ecosystem token.',
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.45),
        ),
      ],
    );
  }
}

class _BalanceOverview extends StatelessWidget {
  final WalletState wallet;

  const _BalanceOverview({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _BalanceMetric(
              label: 'Credit Balance',
              value: wallet.credits.toStringAsFixed(0),
              icon: Icons.local_activity_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BalanceMetric(
              label: 'PEX Balance',
              value: '${wallet.pex.toStringAsFixed(0)} PEX',
              icon: Icons.token_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BalanceMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PeraXColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PeraXColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PeraXColors.cyan),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _AmountCard({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => onChanged(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
        decoration: const InputDecoration(
          labelText: 'Credit Amount',
          labelStyle: TextStyle(color: Colors.white54),
          suffixText: 'Credits',
          suffixStyle: TextStyle(color: PeraXColors.cyan),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _FundingMethods extends StatelessWidget {
  final CreditFundingMethod selectedMethod;
  final ValueChanged<CreditFundingMethod> onSelected;

  const _FundingMethods({
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: CreditFundingMethod.values.map((method) {
        final isActive = method == selectedMethod;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => onSelected(method),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? PeraXColors.cyan.withValues(alpha: 0.14)
                    : PeraXColors.surfaceBlue.withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive ? PeraXColors.cyan : PeraXColors.glassBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method.icon,
                    color: isActive ? PeraXColors.cyan : Colors.white54,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    const Icon(Icons.check_circle_rounded, color: PeraXColors.cyan),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CreditSummary extends StatelessWidget {
  final CreditFundingMethod method;
  final double creditAmount;
  final WalletState wallet;

  const _CreditSummary({
    required this.method,
    required this.creditAmount,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final afterPex = method == CreditFundingMethod.pex
        ? wallet.pex - creditAmount
        : wallet.pex;
    final afterCredits = wallet.credits + (creditAmount > 0 ? creditAmount : 0);

    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credit Purchase Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Funding Method', value: method.title),
          _SummaryRow(
            label: 'Credits to Receive',
            value: '${creditAmount.toStringAsFixed(0)} Credits',
          ),
          _SummaryRow(
            label: 'PEX After Purchase',
            value: method == CreditFundingMethod.pex
                ? '${afterPex.toStringAsFixed(0)} PEX'
                : 'No PEX deduction',
            isWarning: afterPex < 0,
          ),
          _SummaryRow(
            label: 'Credit Balance After',
            value: '${afterCredits.toStringAsFixed(0)} Credits',
          ),
          const SizedBox(height: 10),
          const Text(
            'Trading company settlement, provider payment, buyback, burn, liquidity support, and operating margin will be handled by backend policy.',
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isWarning ? Colors.orange : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
