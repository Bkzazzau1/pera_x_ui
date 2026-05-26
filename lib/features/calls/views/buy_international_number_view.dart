import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../wallet/state/wallet_provider.dart';
import '../data/call_service.dart';
import '../models/international_number_model.dart';
import '../models/number_pricing_model.dart';
import '../routes/call_routes.dart';

class BuyInternationalNumberView extends ConsumerStatefulWidget {
  const BuyInternationalNumberView({super.key});

  @override
  ConsumerState<BuyInternationalNumberView> createState() =>
      _BuyInternationalNumberViewState();
}

class _BuyInternationalNumberViewState
    extends ConsumerState<BuyInternationalNumberView> {
  final CallService service = CallService();

  bool isLoading = true;
  bool isSubmitting = false;
  int selectedNumberIndex = 0;
  String selectedPlan = 'Monthly';
  String? reservedPhoneNumber;
  String? pricingWarning;
  List<InternationalNumberModel> numbers = [];
  List<NumberPricingModel> pricing = [];

  InternationalNumberModel? get selectedNumber {
    if (numbers.isEmpty) return null;
    return numbers[selectedNumberIndex];
  }

  NumberPricingModel? get selectedPricing {
    final number = selectedNumber;
    if (number == null) return null;

    for (final item in pricing) {
      if (item.country == number.country && item.numberType == 'local') {
        return item;
      }
    }

    return null;
  }

  double get setupFee {
    final price = selectedPricing;
    final number = selectedNumber;
    return price?.setupFeeCredits ?? number?.setupFeeCredit ?? 0;
  }

  double get subscriptionFee {
    final price = selectedPricing;
    final number = selectedNumber;

    if (selectedPlan == 'Annual') {
      return price?.annualFeeCredits ?? ((number?.monthlyFeeCredit ?? 0) * 10);
    }

    return price?.monthlyFeeCredits ?? number?.monthlyFeeCredit ?? 0;
  }

  double get monthlyFee {
    final price = selectedPricing;
    final number = selectedNumber;
    return price?.monthlyFeeCredits ?? number?.monthlyFeeCredit ?? 0;
  }

  double get totalDue => setupFee + subscriptionFee;

  @override
  void initState() {
    super.initState();
    loadNumbers();
  }

  Future<void> loadNumbers() async {
    try {
      final loadedNumbers = await service
          .getInternationalNumbers()
          .timeout(const Duration(seconds: 3));

      List<NumberPricingModel> loadedPricing = [];
      String? warning;

      try {
        loadedPricing = await service
            .getNumberPricing()
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        warning =
            'Using cached display prices. Backend will still confirm the final subscription charge.';
      }

      if (!mounted) return;

      setState(() {
        numbers = loadedNumbers;
        pricing = loadedPricing;
        pricingWarning = warning;
        final popularIndex = numbers.indexWhere((number) => number.popular);
        selectedNumberIndex = popularIndex == -1 ? 0 : popularIndex;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        pricingWarning = 'Unable to load number inventory. Please try again.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> confirmPurchase() async {
    final number = selectedNumber;
    if (number == null) return;

    final wallet = ref.read(walletProvider);

    if (wallet.credits < totalDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient Credits. Buy Credits before reserving this number.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      context.go('/credits');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final response = await service.purchaseInternationalNumber(
        country: number.country,
        number: number.sampleNumber,
        plan: selectedPlan,
        creditBalance: wallet.credits,
      );

      if (!mounted) return;

      setState(() => isSubmitting = false);

      if (!response.reserved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isEmpty
                  ? 'Global number reservation was rejected.'
                  : response.message,
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
        return;
      }

      ref.read(walletProvider.notifier).spendCredits(response.creditCost);
      setState(() => reservedPhoneNumber = response.phoneNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response.phoneNumber} reserved. ${response.creditCost.toStringAsFixed(0)} Credits charged. Subscription renews monthly.',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void openMessages(String phoneNumber) {
    context.push(
      CallRoutes.smsInbox,
      extra: SmsInboxArgs(phoneNumber: phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creditBalance = ref.watch(walletProvider).credits;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF020617),
              Color(0xFF071A35),
              Color(0xFF052E2B),
              Color(0xFF020617),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 22),
                      _buildHeroCard(creditBalance),
                      if (pricingWarning != null) ...[
                        const SizedBox(height: 12),
                        _WarningPanel(message: pricingWarning!),
                      ],
                      if (reservedPhoneNumber != null) ...[
                        const SizedBox(height: 16),
                        _ReservedNumberCard(
                          phoneNumber: reservedPhoneNumber!,
                          onOpenMessages: () => openMessages(reservedPhoneNumber!),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const Text(
                        'Available Countries',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNumberList(),
                      const SizedBox(height: 22),
                      _buildPlanSelector(),
                      const SizedBox(height: 22),
                      _buildSummaryCard(creditBalance),
                      const SizedBox(height: 24),
                      _buildConfirmButton(creditBalance),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Global Number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Recurring monthly number subscription',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => context.go('/credits'),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.add_card_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(double creditBalance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF123D5A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sim_card_rounded, color: Color(0xFF38BDF8)),
              SizedBox(width: 8),
              Text(
                'Global Number Subscription',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Reserve a global number for calls and SMS. Pricing is controlled by backend settings and renews every month.',
            style: TextStyle(color: Colors.white, fontSize: 20, height: 1.25),
          ),
          const SizedBox(height: 16),
          Text(
            '${creditBalance.toStringAsFixed(0)} Credits available',
            style: const TextStyle(
              color: Color(0xFF5EEAD4),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroPill(label: 'Admin pricing'),
              _HeroPill(label: 'Monthly renewal'),
              _HeroPill(label: 'SMS ready'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberList() {
    if (numbers.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.public_off_rounded,
        title: 'No countries available',
        message: 'International number inventory will appear here.',
      );
    }

    return Column(
      children: List.generate(numbers.length, (index) {
        final number = numbers[index];
        final active = selectedNumberIndex == index;
        final itemPricing = pricing
            .where((item) => item.country == number.country && item.numberType == 'local')
            .cast<NumberPricingModel?>()
            .firstWhere((item) => item != null, orElse: () => null);
        final monthly = itemPricing?.monthlyFeeCredits ?? number.monthlyFeeCredit;

        return InkWell(
          onTap: () => setState(() => selectedNumberIndex = index),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF07111F).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active
                    ? const Color(0xFF14B8A6).withValues(alpha: 0.65)
                    : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    number.flag,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              number.country,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (number.popular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF14B8A6,
                                ).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Color(0xFF5EEAD4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${number.sampleNumber} • ${monthly.toStringAsFixed(0)} Credits/mo',
                        style: const TextStyle(
                          color: Color(0x80FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  active
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: active ? const Color(0xFF5EEAD4) : Colors.white24,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlanSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PlanButton(
                label: 'Monthly',
                subtitle: 'Renews every month',
                active: selectedPlan == 'Monthly',
                onTap: () => setState(() => selectedPlan = 'Monthly'),
              ),
              const SizedBox(width: 10),
              _PlanButton(
                label: 'Annual',
                subtitle: 'Admin-set annual price',
                active: selectedPlan == 'Annual',
                onTap: () => setState(() => selectedPlan = 'Annual'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double creditBalance) {
    final number = selectedNumber;
    if (number == null) return const SizedBox.shrink();

    final balanceAfter = creditBalance - totalDue;
    final hasEnoughCredits = balanceAfter >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Number', value: number.sampleNumber),
          _SummaryRow(
            label: 'Setup fee',
            value: '${setupFee.toStringAsFixed(0)} Credits',
          ),
          _SummaryRow(
            label: selectedPlan == 'Annual' ? 'Annual subscription' : 'Monthly subscription',
            value: '${subscriptionFee.toStringAsFixed(0)} Credits',
          ),
          _SummaryRow(
            label: 'Renewal amount',
            value: '${monthlyFee.toStringAsFixed(0)} Credits/month',
          ),
          const Divider(color: Colors.white10, height: 22),
          _SummaryRow(
            label: 'Total due today',
            value: '${totalDue.toStringAsFixed(0)} Credits',
            strong: true,
          ),
          _SummaryRow(
            label: 'Credits after purchase',
            value: hasEnoughCredits
                ? '${balanceAfter.toStringAsFixed(0)} Credits'
                : 'Insufficient Credits',
            strong: true,
            warning: !hasEnoughCredits,
          ),
          const SizedBox(height: 12),
          const Text(
            'The backend confirms the final charge. Admin can update setup and subscription prices from backend settings.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: number.capabilities
                .map((capability) => _CapabilityPill(label: capability))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double creditBalance) {
    final hasEnoughCredits = creditBalance >= totalDue;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting
            ? null
            : hasEnoughCredits
                ? confirmPurchase
                : () => context.go('/credits'),
        icon: isSubmitting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(hasEnoughCredits
                ? Icons.shopping_cart_checkout_rounded
                : Icons.add_card_rounded),
        label: Text(
          isSubmitting
              ? 'Confirming Subscription...'
              : hasEnoughCredits
                  ? 'Start Number Subscription'
                  : 'Buy Credits First',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF14B8A6),
          disabledBackgroundColor: const Color(
            0xFF14B8A6,
          ).withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ReservedNumberCard extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onOpenMessages;

  const _ReservedNumberCard({
    required this.phoneNumber,
    required this.onOpenMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF5EEAD4),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
