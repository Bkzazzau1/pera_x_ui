import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/service_providers.dart';
import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../pricing/data/pricing_service.dart';
import '../wallet/state/wallet_provider.dart';
import 'data/credit_service.dart';

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
        return 'Pay with stablecoin and receive Credits.';
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

  CreditFundingMethodDto get dto {
    switch (this) {
      case CreditFundingMethod.pex:
        return CreditFundingMethodDto.pex;
      case CreditFundingMethod.card:
        return CreditFundingMethodDto.card;
      case CreditFundingMethod.stablecoin:
        return CreditFundingMethodDto.stablecoin;
      case CreditFundingMethod.virtualAccount:
        return CreditFundingMethodDto.virtualAccount;
    }
  }

  String get assetCode {
    switch (this) {
      case CreditFundingMethod.pex:
        return 'PEX';
      case CreditFundingMethod.stablecoin:
        return 'USDT';
      case CreditFundingMethod.card:
      case CreditFundingMethod.virtualAccount:
        return 'FIAT_USD';
    }
  }
}

class BuyCreditsView extends ConsumerStatefulWidget {
  const BuyCreditsView({super.key});

  @override
  ConsumerState<BuyCreditsView> createState() => _BuyCreditsViewState();
}

class _BuyCreditsViewState extends ConsumerState<BuyCreditsView> {
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  final CreditService _creditService = CreditService();
  CreditFundingMethod selectedMethod = CreditFundingMethod.pex;
  bool isProcessing = false;
  BuyCreditsResultDto? lastQuote;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get creditAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  CreditExchangeRateModel? _rateFor(
    List<CreditExchangeRateModel>? rates,
    CreditFundingMethod method,
  ) {
    if (rates == null) return null;
    for (final rate in rates) {
      if (rate.assetCode == method.assetCode) return rate;
    }
    return null;
  }

  double _creditsPerUnit(List<CreditExchangeRateModel>? rates) =>
      _rateFor(rates, selectedMethod)?.creditsPerUnit ?? 100;

  double _assetRequired(List<CreditExchangeRateModel>? rates) {
    final creditsPerUnit = _creditsPerUnit(rates);
    if (creditAmount <= 0 || creditsPerUnit <= 0) return 0;
    return creditAmount / creditsPerUnit;
  }

  bool _canBuy(WalletState wallet, List<CreditExchangeRateModel>? rates) {
    if (isProcessing || creditAmount <= 0) return false;
    if (selectedMethod == CreditFundingMethod.pex) {
      return wallet.pex >= _assetRequired(rates);
    }
    return true;
  }

  Future<void> _buyCredits() async {
    final wallet = ref.read(walletProvider);
    final rates = ref.read(creditExchangeRatesProvider).asData?.value;

    if (!_canBuy(wallet, rates)) {
      _showSnack(
        selectedMethod == CreditFundingMethod.pex
            ? 'Insufficient PEX to buy this amount of Credits.'
            : 'Enter a valid Credit amount.',
      );
      return;
    }

    setState(() => isProcessing = true);

    try {
      final response = await _creditService.buyCredits(
        method: selectedMethod.dto,
        creditAmount: creditAmount,
        pexBalance: wallet.pex,
      );

      if (!mounted) return;

      if (!response.accepted) {
        _showSnack(
          response.message.isEmpty
              ? 'Credit purchase was not accepted.'
              : response.message,
        );
        setState(() => isProcessing = false);
        return;
      }

      if (selectedMethod == CreditFundingMethod.pex) {
        ref.read(walletProvider.notifier).deductPex(response.pexRequired);
      }
      ref.read(walletProvider.notifier).addCredits(response.creditAmount);

      ref
          .read(transactionProvider.notifier)
          .addCreditPurchase(
            method: selectedMethod.title,
            credits: response.creditAmount,
          );

      _showSnack(
        response.message.isEmpty
            ? '${response.creditAmount.toStringAsFixed(0)} Credits added successfully.'
            : response.message,
      );
      setState(() {
        lastQuote = response;
        isProcessing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      _showSnack(error.toString());
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final exchangeRatesAsync = ref.watch(creditExchangeRatesProvider);
    final exchangeRates = exchangeRatesAsync.asData?.value;
    final canBuy = _canBuy(wallet, exchangeRates);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            const _CreditsHeader(),
            const SizedBox(height: 20),
            if (exchangeRatesAsync.isLoading) const _RateLoadingBanner(),
            if (exchangeRatesAsync.hasError) const _RateFallbackBanner(),
            if (exchangeRatesAsync.isLoading || exchangeRatesAsync.hasError)
              const SizedBox(height: 16),
            _BalanceOverview(wallet: wallet),
            const SizedBox(height: 18),
            _AmountCard(
              controller: _amountController,
              onChanged: () => setState(() => lastQuote = null),
            ),
            const SizedBox(height: 18),
            _FundingMethods(
              selectedMethod: selectedMethod,
              exchangeRates: exchangeRates,
              onSelected: (method) => setState(() {
                selectedMethod = method;
                lastQuote = null;
              }),
            ),
            const SizedBox(height: 18),
            _CreditSummary(
              method: selectedMethod,
              creditAmount: creditAmount,
              wallet: wallet,
              rate: _rateFor(exchangeRates, selectedMethod),
              assetRequired: _assetRequired(exchangeRates),
              lastQuote: lastQuote,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: canBuy ? _buyCredits : null,
              icon: Icon(
                isProcessing
                    ? Icons.hourglass_bottom_rounded
                    : Icons.add_card_rounded,
              ),
              label: Text(
                isProcessing
                    ? 'PROCESSING CREDIT PURCHASE'
                    : selectedMethod == CreditFundingMethod.pex
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

class _RateLoadingBanner extends StatelessWidget {
  const _RateLoadingBanner();
  @override
  Widget build(BuildContext context) => const GlassCard(
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
            'Loading Credit exchange rates...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _RateFallbackBanner extends StatelessWidget {
  const _RateFallbackBanner();
  @override
  Widget build(BuildContext context) => const GlassCard(
    radius: 18,
    padding: EdgeInsets.all(14),
    child: Row(
      children: [
        Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Displaying estimated exchange rates. Final conversion is confirmed before crediting.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _CreditsHeader extends StatelessWidget {
  const _CreditsHeader();
  @override
  Widget build(BuildContext context) => const Column(
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

class _BalanceOverview extends StatelessWidget {
  final WalletState wallet;
  const _BalanceOverview({required this.wallet});
  @override
  Widget build(BuildContext context) => GlassCard(
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
            value: '${wallet.pex.toStringAsFixed(2)} PEX',
            icon: Icons.token_outlined,
          ),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => Container(
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

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _AmountCard({required this.controller, required this.onChanged});
  @override
  Widget build(BuildContext context) => GlassCard(
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

class _FundingMethods extends StatelessWidget {
  final CreditFundingMethod selectedMethod;
  final List<CreditExchangeRateModel>? exchangeRates;
  final ValueChanged<CreditFundingMethod> onSelected;
  const _FundingMethods({
    required this.selectedMethod,
    required this.exchangeRates,
    required this.onSelected,
  });
  CreditExchangeRateModel? _rateFor(CreditFundingMethod method) {
    if (exchangeRates == null) return null;
    for (final rate in exchangeRates!) {
      if (rate.assetCode == method.assetCode) return rate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
    children: CreditFundingMethod.values.map((method) {
      final isActive = method == selectedMethod;
      final rate = _rateFor(method);
      final rateText = rate == null
          ? 'Rate pending'
          : '${rate.creditsPerUnit.toStringAsFixed(0)} Credits / ${rate.unitLabel}';
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
                      const SizedBox(height: 4),
                      Text(
                        rateText,
                        style: const TextStyle(
                          color: PeraXColors.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: PeraXColors.cyan,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

class _CreditSummary extends StatelessWidget {
  final CreditFundingMethod method;
  final double creditAmount;
  final WalletState wallet;
  final CreditExchangeRateModel? rate;
  final double assetRequired;
  final BuyCreditsResultDto? lastQuote;
  const _CreditSummary({
    required this.method,
    required this.creditAmount,
    required this.wallet,
    required this.rate,
    required this.assetRequired,
    required this.lastQuote,
  });
  @override
  Widget build(BuildContext context) {
    final finalAssetRequired = lastQuote?.assetRequired ?? assetRequired;
    final finalCreditAmount = lastQuote?.creditAmount ?? creditAmount;
    final finalCreditsPerUnit =
        lastQuote?.creditsPerUnit ?? rate?.creditsPerUnit ?? 100;
    final finalAssetCode = lastQuote?.assetCode.isNotEmpty == true
        ? lastQuote!.assetCode
        : method.assetCode;
    final pexAfter = method == CreditFundingMethod.pex
        ? wallet.pex - finalAssetRequired
        : wallet.pex;
    final afterCredits =
        wallet.credits + (finalCreditAmount > 0 ? finalCreditAmount : 0);
    final assetLabel = method == CreditFundingMethod.pex
        ? 'PEX Required'
        : method == CreditFundingMethod.stablecoin
        ? 'Stablecoin Required'
        : 'Fiat Equivalent';
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
            label: 'Exchange Rate',
            value:
                '${finalCreditsPerUnit.toStringAsFixed(0)} Credits / ${rate?.unitLabel ?? '1 $finalAssetCode'}',
          ),
          _SummaryRow(
            label: 'Credits to Receive',
            value: '${finalCreditAmount.toStringAsFixed(0)} Credits',
          ),
          _SummaryRow(
            label: assetLabel,
            value: '${finalAssetRequired.toStringAsFixed(4)} $finalAssetCode',
            isWarning: method == CreditFundingMethod.pex && pexAfter < 0,
          ),
          _SummaryRow(
            label: 'PEX After Purchase',
            value: method == CreditFundingMethod.pex
                ? '${pexAfter.toStringAsFixed(4)} PEX'
                : 'No PEX deduction',
            isWarning: pexAfter < 0,
          ),
          _SummaryRow(
            label: 'Credit Balance After',
            value: '${afterCredits.toStringAsFixed(0)} Credits',
          ),
          if (lastQuote != null) ...[
            const Divider(color: Colors.white10, height: 22),
            _SummaryRow(label: 'Status', value: lastQuote!.status),
          ],
          const SizedBox(height: 10),
          const Text(
            'Rates may vary before final confirmation.',
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
  Widget build(BuildContext context) => Padding(
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
            color: isWarning ? Colors.orangeAccent : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
